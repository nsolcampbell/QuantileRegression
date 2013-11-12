/**
 * @author: pkambadu
 */
#include <mpi.h>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <elemental.hpp>
#include <sys/time.h>

static double micro_time () {
  /** Use gettimeofday() to return the time in milliseconds */
  struct timeval tp;
  gettimeofday(&tp, NULL);
  return (double)tp.tv_sec + tp.tv_usec*1.e-6;
}


int main(int argc, char **argv) {
  /** Initialize Elemental, which will also initialize MPI processes */
  elem::Initialize(argc,argv);

  if (argc != 3) {
    printf("Syntax: ./temp <m> <n>\n");
    MPI_Abort(MPI_COMM_WORLD,1);
  }

  /* Work till requested not to */
  int M = atoi(argv[1]);
  int N = atoi(argv[2]);
  elem::DistMatrix<double> A(M,N);
  elem::DistMatrix<double> AA(N,N);
  elem::DistMatrix<double> x(N,1);
  //elem::Uniform(A);

  double time = micro_time ();
  elem::Syrk(elem::UPPER, elem::TRANSPOSE, 1.0, A, 0.0, AA);
  time = micro_time () - time;
  int mpi_rank;
  MPI_Comm_rank (MPI_COMM_WORLD, &mpi_rank);
  if (0==mpi_rank) printf ("SYRK took %lf (seconds)\n", time);

  /** Terminate MPI */
  MPI_Finalize();
}
