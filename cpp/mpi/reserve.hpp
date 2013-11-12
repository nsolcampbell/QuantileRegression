#ifndef RESERVE_HPP
#define RESERVE_HPP

#include <elemental.hpp>

#include "globals.hpp"

/**
 * This function exists to reserve a dense matrix from memory distributed.
 */
static inline bool reserveGlobal (std::string fileName, int M, int N) {
  /* 1. If this dataset does not exist, return error */
  dist_dataset_map_t::iterator find_result = dist_dataset_map.find(fileName);
  if (dist_dataset_map.end() != find_result) {
    fprintf(stderr,
            "Dataset %s is already present in our map\n", fileName.c_str());
    return false;
  }

  /* 2. Get the matrix and reserve it */
  fprintf (stdout, "Reserving %s\n", fileName.c_str());
  dist_matrix_t* matrix = new dist_matrix_t (M, N); 

  /* 3. Put the entry in the map */
  dist_dataset_map [fileName] = matrix;

  return true;
}

/**
 * This function exists to reserve a dense matrix from memory
 */
static inline bool reserveLocal (std::string fileName, int M, int N) {
  /* 1. If this dataset does not exist, return error */
  repl_dataset_map_t::iterator find_result = repl_dataset_map.find(fileName);
  if (repl_dataset_map.end() != find_result) {
    fprintf(stderr,
            "Dataset %s is already present in our map\n", fileName.c_str());
    return false;
  }

  /* 2. Get the matrix and reserve it */
  fprintf (stdout, "Reserving %s\n", fileName.c_str());
  matrix_t* matrix = new matrix_t (M, N); 

  /* 3. Put the entry in the map */
  repl_dataset_map [fileName] = matrix;

  return true;
}

#endif
