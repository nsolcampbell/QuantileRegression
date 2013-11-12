/**
 * @author: pkambadu
 */
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <sys/stat.h>
#include <utility>
#include <ext/hash_map>
#include <ext/hash_set>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 
#include <arpa/inet.h>

#include <elemental.hpp>

#include "globals.hpp"
#include "syrk.hpp"
#include "dscale.hpp"
#include "dsolve.hpp"
#include "dgemv.hpp"

/* MPI related global variables */
int mpi_rank;
int mpi_size;

/* Service related global variables */
int server_sockfd;

/* Other global variables */
repl_dataset_map_t repl_dataset_map;
dist_dataset_map_t dist_dataset_map;

/* Files to use for stdout and stderr */
char STDOUT[1024];
char STDERR[1024];

bool work(char*);

/****************************************************************************/
/*                   CODE TO CREATE SERVER TO THE MATLAB SIDE               */
void initialize (int port) {
  struct sockaddr_in serv_addr;
  socklen_t serv_addr_len = sizeof(struct sockaddr_in);
 
  server_sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (0>server_sockfd) { 
    fprintf (stderr, "Error opening the socket\n"); 
    MPI_Abort (MPI_COMM_WORLD, 3); 
  }
 
  bzero ((char*)&serv_addr, serv_addr_len);
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(port);
  serv_addr.sin_addr.s_addr = INADDR_ANY;
  
  int reuse = 1;
  setsockopt (server_sockfd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(int));

  if (0>bind (server_sockfd, 
              (struct sockaddr*)&serv_addr, 
              serv_addr_len)){
    fprintf (stderr, "Error binding to port %d\n", serv_addr.sin_port);
    MPI_Abort (MPI_COMM_WORLD, 3); 
  }

  if (0>listen (server_sockfd, 100)) {
    fprintf (stderr, "Error listening\n");
    MPI_Abort (MPI_COMM_WORLD, 3);
  }

  if (0>getsockname (server_sockfd, 
                     (struct sockaddr*)&serv_addr, 
                     &serv_addr_len)){
    fprintf (stderr, "Error getting port information\n");
    MPI_Abort (MPI_COMM_WORLD, 3); 
  }
}

/****************************************************************************/
/*                   CODE TO CLOSE SERVER TO THE MATLAB SIDE                */
void finalize () { close (server_sockfd); }

/****************************************************************************/
/*                   CODE TO GET WORK PACKET FROM MATLAB                    */
void get_requests () {
  int client_sockfd;
  struct sockaddr_in client_addr;
  socklen_t client_len = sizeof(client_addr);
  char request[1024];
  const char* response = "DONE";
  bool terminate = false;

  while (false == terminate) {
    if (0>listen (server_sockfd, 100)) {
      fprintf (stderr, "Error listening\n");
      MPI_Abort (MPI_COMM_WORLD, 3);
    } else {
      printf ("Listening\n");
    }

    client_sockfd = accept (server_sockfd,
                            (struct sockaddr*)&client_addr,
                            &client_len);

    if (0>client_sockfd) {
      fprintf (stderr, "Could not connect to client\n");
      MPI_Abort (MPI_COMM_WORLD, 3);
    }

    bzero (request, 1024);
    int num_read = read (client_sockfd, request, 1024);
    if (0>num_read) {
      fprintf (stderr, "Could not read client request\n");
      MPI_Abort (MPI_COMM_WORLD, 3);
    }
    chomp (request);
    printf ("Processing %s\n", request);
    terminate = work (request);

    int num_written = write (client_sockfd, response, strlen(response));
    if (0>num_written) {
      fprintf (stderr, "Could not write client response\n");
      MPI_Abort (MPI_COMM_WORLD, 3);
    }

    close (client_sockfd);
  }
}

void just_work () { 
  bool terminate = false;
  while (false == terminate) terminate = work (NULL);
}

bool work(char* root_request) {
  char request[1024];
  if (ROOT==mpi_rank) strcpy (request, root_request);
  MPI_Bcast (request, 1024, MPI_CHAR, ROOT, MPI_COMM_WORLD);

  /*****************************************************************/
  /*             Handle the request appropriately                  */
  /*****************************************************************/
  if ('k' == request[0] &&
      'i' == request[1] &&
      'l' == request[2] &&
      'l' == request[3]) {
    return true;
  } else if ('s' == request[0] && 
             'y' == request[1] &&
             'r' == request[2] &&
             'k' == request[3]) {
    return (true != syrk (request));
  } else if ('d' == request[0] && 
             's' == request[1] &&
             'c' == request[2] &&
             'a' == request[3] &&
             'l' == request[4] &&
             'e' == request[5]) { 
    return (true != dscale (request));
  } else if ('d' == request[0] && 
             's' == request[1] &&
             'o' == request[2] &&
             'l' == request[3] &&
             'v' == request[4] &&
             'e' == request[5]) { 
    return (true != dsolve (request));
  } else if ('d' == request[0] && 
             'g' == request[1] &&
             'e' == request[2] &&
             'm' == request[3] &&
             'v' == request[4]) { 
    return (true != dgemv (request));
  } else { /* illegal request */
    return false;
  }

  return false;
}

int main(int argc, char **argv) {
  /** Initialize Elemental, which will also initialize MPI processes */
  elem::Initialize(argc,argv);

  /** Find out a few things about this MPI process */
  MPI_Comm_rank(MPI_COMM_WORLD,&mpi_rank);
  MPI_Comm_size(MPI_COMM_WORLD,&mpi_size);

  if (argc != 4) {
    if (ROOT == mpi_rank) printf("Syntax: ./server stdout stderr port\n");
    MPI_Abort(MPI_COMM_WORLD,1);
  }

  /* Close STDOUT and STDERR and make it something else */
  fclose (stdout);
  fclose (stderr);
  sprintf (STDOUT, "%s.%d.out", argv[1], mpi_rank);
  sprintf (STDERR, "%s.%d.err", argv[2], mpi_rank);
  stdout = fopen (STDOUT,"w");
  stderr = fopen (STDERR,"w");

  /* Create a socket and send the information out */
  if (ROOT == mpi_rank) {
    int port = atoi(argv[3]);
    initialize (port);
    fprintf(stdout, "Starting up at port %d\n", port);
    fflush(stdout);
  }

  /* Work till requested not to */
  if (ROOT == mpi_rank) get_requests();
  else just_work ();

  /* Finalize socket */
  if (ROOT == mpi_rank) finalize ();

  /* Close everything */
  fclose (stdout);
  fclose (stderr);

  /** Terminate MPI */
  elem::Finalize();
}
