#ifndef UNLOAD_HPP
#define UNLOAD_HPP

#include <elemental.hpp>

#include "globals.hpp"

/**
 * This function exists to unload a dense matrix from memory
 */
static inline bool unloadGlobal (std::string fileName) {
  /* 1. If this dataset does not exist, return error */
  dist_dataset_map_t::iterator find_result = dist_dataset_map.find(fileName);
  if (dist_dataset_map.end() == find_result) {
    fprintf(stderr,"Dataset %s is not present in our map\n", fileName.c_str());
    return true;
  }

  /* 2. Get the matrix and unload it out */
  fprintf (stdout, "Unloading %s\n", fileName.c_str());
  dist_matrix_t* matrix = find_result->second;

  /* 3. Remove from the dataset map */
  dist_dataset_map.erase(fileName);
  delete matrix;

  return true;
}

/**
 * This function exists to unload a dense matrix from memory
 */
static inline bool unloadLocal (std::string fileName) {
  /* 1. If this dataset does not exist, return error */
  repl_dataset_map_t::iterator find_result = repl_dataset_map.find(fileName);
  if (repl_dataset_map.end() == find_result) {
    fprintf(stderr,"Dataset %s is not present in our map\n", fileName.c_str());
    return true;
  }

  /* 2. Get the matrix and unload it out */
  fprintf (stdout, "Unloading %s\n", fileName.c_str());
  matrix_t* matrix = find_result->second;

  /* 3. Remove from the dataset map */
  repl_dataset_map.erase(fileName);
  delete matrix;

  return true;
}

#endif
