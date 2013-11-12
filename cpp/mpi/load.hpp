#ifndef LOAD_HPP
#define LOAD_HPP

#include <elemental.hpp>
#include "globals.hpp"

/**
 * This function exists to load a dense matrix into memory. Make sure that the
 * file that is passed actually exists and contains the matrix in the following
 * format: 
 * <M(int)><N(int)>[values in double precision in column-major order]
 * 
 * At the end of the operation, the matrix is loaded in a Matrix<T> and then a
 * <key,value> pair is inserted into repl_dataset_map. As everything is
 * replicated, please make sure that something small is being loaded.
 */
static inline bool loadLocal (std::string fileName) {
  /* 1. If this dataset is already loaded, don't do anything */
  repl_dataset_map_t::iterator find_result = repl_dataset_map.find(fileName);
  if (repl_dataset_map.end() != find_result) {
    fprintf (stderr, "Local dataset %s is already loaded\n", fileName.c_str());
    return true;
  }

  /* 2. Load this dataset and keep it in a Matrix<double> */
  fprintf (stdout, "Loading %s\n", fileName.c_str());

  int dimensions[2] = {-1, -1};
  matrix_t* localMatrix;
  if (ROOT == mpi_rank) {
    /* 2.1 Check for validity of arguments */
    if (false == is_file (fileName.c_str())) {
      fprintf (stderr, "Dataset %s is not a file!\n", fileName.c_str());
      MPI_Abort (MPI_COMM_WORLD, 3);
      return false;
    }
 
    /* 2.2 File is valid, simply read in the matrix */
    std::ifstream in (fileName.c_str(), std::ios::binary);
    if (false == in.is_open()) {
      fprintf (stderr, "Could not open %s to read\n", fileName.c_str());
      MPI_Abort (MPI_COMM_WORLD, 3);
      return false;
    }
 
    in.read ((char*)&(dimensions[0]), sizeof(int));
    in.read ((char*)&(dimensions[1]), sizeof(int));
    if (0 > dimensions[0] || 0 > dimensions[1]) {
      fprintf (stderr, "Dimensions (%d,%d) are messed up\n", 
                                  dimensions[0], dimensions[1]);
      MPI_Abort (MPI_COMM_WORLD, 3);
      in.close();
      return false;
    } else {
      MPI_Bcast (dimensions, 2, MPI_INT, ROOT, MPI_COMM_WORLD);
    }

    localMatrix = new matrix_t (dimensions[0], dimensions[1]);
    double* values = localMatrix->Buffer();
    for (int element=0; element<(dimensions[0]*dimensions[1]); ++element) 
      in.read ((char*)&(values[element]), sizeof(double));
    in.close();

    /* 2.3 Broadcast this to everyone */
    MPI_Bcast (values, 
               dimensions[0]*dimensions[1], 
               MPI_DOUBLE, 
               ROOT, 
               MPI_COMM_WORLD);

  } else {
    /* 2.1 Get the dimensions */
    MPI_Bcast (dimensions, 2, MPI_INT, ROOT, MPI_COMM_WORLD);
    if (0 > dimensions[0] || 0 > dimensions[1]) {
      fprintf (stderr, "Dimensions (%d,%d) are messed up\n", 
                                  dimensions[0], dimensions[1]);
      MPI_Abort (MPI_COMM_WORLD, 3);
      return false;
    } 

    /* 2.2 Allocate enough memory and get the values */
    localMatrix = new matrix_t (dimensions[0], dimensions[1]);
    double* values = localMatrix->Buffer();
    MPI_Bcast (values, 
               dimensions[0]*dimensions[1], 
               MPI_DOUBLE, 
               ROOT, 
               MPI_COMM_WORLD);
  }

  /* 2.3 Inset things in */
  repl_dataset_map [fileName] = localMatrix;

  return true;
}

/**
 * This function exists to load a dense matrix into memory. Make sure that the
 * file that is passed actually exists and contains the matrix in the following
 * format: 
 * <M(int)><N(int)>[values in double precision in column-major order]
 * 
 * At the end of the operation, the matrix is loaded in a Matrix<T> and then
 * a <key,value> pair is inserted into dataset_map. Basically, a local load 
 * is performed first. Then, we load it into memory as we need.
 */
static inline bool loadGlobal (std::string fileName) {
  /* 1. If this dataset is already loaded, don't do anything */
  dist_dataset_map_t::iterator find_result = dist_dataset_map.find(fileName);
  if (dist_dataset_map.end() != find_result) {
    fprintf (stderr, "Distributed dataset %s is loaded\n", fileName.c_str());
    return true;
  }

  /* 2. Load this dataset and keep it in a Matrix<double> */
  fprintf (stdout, "Loading %s\n", fileName.c_str());

  /* 2.1 Load the local matrix */
  if (false == loadLocal(fileName)) return false;

  /* 2.2 Now, from the local matrices, make things global */
  matrix_t* localMatrix = (repl_dataset_map.find (fileName))->second;
  dist_matrix_t* globalMatrix=
    new dist_matrix_t(localMatrix->Height(), localMatrix->Width());

  for (int jLocal=0; jLocal<globalMatrix->LocalWidth(); ++jLocal) {
    const int j = globalMatrix->RowShift() + jLocal*globalMatrix->RowStride();
    for(int iLocal=0; iLocal<globalMatrix->LocalHeight(); ++iLocal) {
      const int i=globalMatrix->ColShift() + iLocal*globalMatrix->ColStride();
      globalMatrix->SetLocal(iLocal, jLocal, localMatrix->Get(i,j));
    }
  }

  /* 2.4 Delete the useless local matrix */
  repl_dataset_map.erase(fileName);
  delete localMatrix;

  /* 2.5 Add to the global dataset map */
  dist_dataset_map [fileName] = globalMatrix;

  return true;
}

#endif
