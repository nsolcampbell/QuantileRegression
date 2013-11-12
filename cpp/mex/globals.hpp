#ifndef MEX_GLOBALS_HPP
#define MEX_GLOBALS_HPP

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h> 
#include <string>
#include <sstream>

#include "mex.h"
#include <fstream>

static inline std::string getString (const mxArray* stringArray) {
  std::string mexString;
  const int mexStringLength = mxGetN(stringArray) + 1;
  mexString.reserve(mexStringLength);
  mexString.resize((mexStringLength-1));
  mxGetString (stringArray, 
               const_cast<char*>(mexString.c_str()), 
               mexStringLength);
  return mexString;
}

static inline double getDouble (const mxArray* doubleArray) {
  double retVal = 0.0;
  const int M = mxGetM(doubleArray) + 1;
  const int N = mxGetN(doubleArray) + 1;

  //if (1 != M || 1 != N) {
  //  mexPrintf ("Passed parameter is not a double (%d,%d)\n", M, N);
  //} else {
    retVal = mxGetPr(doubleArray)[0];
  //}
  return retVal;
}

static inline void readMatrix (mxArray** outputArray,
                               std::string fileName) {
  /* 1. Open the file */
  std::ifstream in (fileName.c_str(), std::ios::binary);
  if (false == in.is_open()) {
    mexPrintf ("Could not open %s to read\n", fileName.c_str());
    return;
  }

  /* 2. Read the dimensions */
  int M = -1;
  int N = -1;
  in.read ((char*)&M, sizeof(int));
  in.read ((char*)&N, sizeof(int));
  if (0 > M || 0 > N) {
    mexPrintf ("Dimensions (%d,%d) are messed up\n", M, N);
    in.close();
    return;
  }

  /* 3. Allocate the buffer for this */
  *outputArray = mxCreateDoubleMatrix (M, N, mxREAL);
  double* values = mxGetPr(*outputArray);

  /* 4. Read everything in */
  for (int element=0; element<(N*M); ++element) 
    in.read ((char*)&(values[element]), sizeof(double));

  /* 5. Close everything */
  in.close();
}

static inline void writeMatrix (int M,
                                int N,
                                double* values,
                                std::string fileName) {
  /* 1. Open the file */
  std::ofstream out (fileName.c_str(), std::ios::binary);
  if (false == out.is_open()) {
    mexPrintf ("Could not open %s to read\n", fileName.c_str());
    return;
  }

  /* 2. Write the dimensions */
  out.write ((const char*)&M, sizeof(int));
  out.write ((const char*)&N, sizeof(int));

  /* 4. Write everything out */
  for (int element=0; element<(N*M); ++element) 
    out.write ((const char*)&(values[element]), sizeof(double));

  /* 5. Close everything */
  out.close();
}

static inline void sendRequest (std::string request,
                                std::string hostname="127.0.0.1") { 

  /* 1. Get the port number*/
  int port = 3456;

  /* 2. Create an empty socket */
  int serverSocket = socket(AF_INET, SOCK_STREAM, 0);
  if (0 > serverSocket) {

  }

  /* 3. Get the server structure by name */
  struct hostent* server = gethostbyname (hostname.c_str());
  if (NULL == server) {

  }
  struct sockaddr_in serverAddress;
  bzero((char *) &serverAddress, sizeof(serverAddress));
  serverAddress.sin_family = AF_INET;
  bcopy((char *)server->h_addr, 
        (char *)&serverAddress.sin_addr.s_addr,
        server->h_length);
  serverAddress.sin_port = htons(port);

  /* 4. Connect to the server */
  if (0 > connect (serverSocket, 
                   (struct sockaddr *)&serverAddress,
                   sizeof(serverAddress)))  {

  }

  /* 5. Write the message out */
  if (request.size() != write(serverSocket, request.c_str(), request.size())) {

  }

  /* 6. Wait for the response */
  std::string response;
  response.resize(5);
  if (response.size() != 
    read(serverSocket, (char*)response.c_str(), response.size())) {

  }
  mexPrintf ("Response = %s\n", response.c_str());

  /* 7. Close everything */
  close (serverSocket);
}

#endif // MEX_GLOBALS_HPP
