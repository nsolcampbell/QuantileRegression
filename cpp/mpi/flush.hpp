#ifndef FLUSH_HPP
#define FLUSH_HPP

#include <elemental.hpp>

#include "globals.hpp"

/**
 * This function exists to flush a dense matrix into memory. The matrix is 
 * flushed to the file in the following format:
 * <M(int)><N(int)>[values in double precision in column-major order]
 */
static inline bool flushLocal (std::string fileName) {
  /* 1. If this dataset does not exist, return error */
  repl_dataset_map_t::iterator find_result = repl_dataset_map.find(fileName);
  if (repl_dataset_map.end() == find_result) {
    fprintf(stderr,"Dataset %s is not present in our map\n", fileName.c_str());
    return false;
  }

  /* 2. Get the matrix and flush it out */
  fprintf (stdout, "Flushing %s\n", fileName.c_str());
  matrix_t* matrix = find_result->second;

  /* 3. Open the file */
  std::ofstream out (fileName.c_str(), std::ios::binary);
  if (false == out.is_open()) {
    fprintf (stderr, "Could not open %s to read\n", fileName.c_str());
    MPI_Abort (MPI_COMM_WORLD, 3);
    return false;
  }

  /* 4. Write the dimensions */
  int M = matrix->Height();
  int N = matrix->Width();
  out.write ((const char*)&M, sizeof(int));
  out.write ((const char*)&N, sizeof(int));

  /* 5. Write everything out */
  const double* values = matrix->LockedBuffer();
  for (int element=0; element<(N*M); ++element) 
    out.write ((const char*)&(values[element]), sizeof(double));

  /* 6. Close everything */
  out.close();

  return true;
}

/**
 * This function exists to flush a dense matrix into memory. The matrix is 
 * flushed to the file in the following format:
 * <M(int)><N(int)>[values in double precision in column-major order]
 */
static inline bool flushGlobal (std::string fileName) {
  /* 1. If this dataset does not exist, return error */
  dist_dataset_map_t::iterator find_result = dist_dataset_map.find(fileName);
  if (dist_dataset_map.end() == find_result) {
    fprintf(stderr,"Dataset %s is not present in our map\n", fileName.c_str());
    return false;
  }

  /* 2. Get the matrix and flush it out */
  fprintf (stdout, "Flushing %s\n", fileName.c_str());
  dist_matrix_t* matrix = find_result->second;

  /* 3. Get everything into rank 0 --- every one else shut up! */
  elem::AxpyInterface<double> interface;
  interface.Attach (elem::GLOBAL_TO_LOCAL, (*matrix));

  if (ROOT == mpi_rank) {
    /* 0. Get everything from the global matrices */
    matrix_t local (matrix->Height(), matrix->Width());
    elem::MakeZeros (local);
    interface.Axpy (1.0, local, 0, 0);

    /* 1. Open the file */
    std::ofstream out (fileName.c_str(), std::ios::binary);
    if (false == out.is_open()) {
      fprintf (stderr, "Could not open %s to read\n", fileName.c_str());
      MPI_Abort (MPI_COMM_WORLD, 3);
      return false;
    }

    /* 2. Write the dimensions */
    int M = local.Height();
    int N = local.Width();
    out.write ((const char*)&M, sizeof(int));
    out.write ((const char*)&N, sizeof(int));

    /* 4. Write everything out */
    const double* values = local.LockedBuffer();
    for (int element=0; element<(N*M); ++element) 
      out.write ((const char*)&(values[element]), sizeof(double));

    /* 5. Close everything */
    out.close();
  }

  /* 6. Detach from the Axpy interface */
  interface.Detach();

  /* 6. Remove from the dataset map */
  dist_dataset_map.erase(fileName);
  delete matrix;

  return true;
}

#endif
