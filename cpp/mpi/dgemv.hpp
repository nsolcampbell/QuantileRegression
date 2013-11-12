#ifndef DGEMV_HPP
#define DGEMV_HPP

#include <sstream>
#include <elemental.hpp>

#include "globals.hpp"
#include "load.hpp"
#include "flush.hpp"
#include "unload.hpp"
#include "reserve.hpp"

/**
 * "dgemv T/N alpha pathToA Y/N pathToX Y/N pathToY Y/N"
 * Y = alpha* op(A) * X
 */
bool dgemv (char* request) {
  /* 0. Chomp out the new line character */
  chomp (request);

  /* 1. Parse and figure out all the parameters */
  int requestCount = 0;
  std::string requestArray[9];
  std::stringstream requestStream(request);
  while (getline(requestStream, requestArray[requestCount++], ' '));
  if (9 != (requestCount-1)) {
    fprintf (stderr, "There are fewer than 9 arguments! (%d)\n", requestCount);
    return false;
  }

  /* Get the alpha */
  const double alpha = atof (requestArray[2].c_str());

  /* 2. Load A and X into memory */
  if (false == loadGlobal (requestArray[3])) return false;
  if (false == loadGlobal (requestArray[5])) return false;

  /* 3. Perform the requested operation */
  /* 3.0 Get all the required matrices */
  dist_matrix_t* A = (dist_dataset_map.find (requestArray[3]))->second;
  dist_matrix_t* X = (dist_dataset_map.find (requestArray[5]))->second;

  /* 3.1 Make sure that X is a column vector */
  if (1 != X->Width()) {
    fprintf (stderr, "X is not a column vector (%d,%d)\n",
                                          X->Height(), X->Width());
    return false;
  }

  /* 3.2 Make sure that A and X match up */
  if (0 == requestArray[1].compare("T") && A->Height() != X->Height()) {
    fprintf (stderr, "Dimensions of A' and X don't match (%d,%d)x(%d)",
                                      A->Width(), A->Height(), X->Height());
    return false;
  } else if (0 != requestArray[1].compare("T") && A->Width() != X->Height()) {
    fprintf (stderr, "Dimensions of A and X don't match (%d,%d)x(%d)",
                                      A->Height(), A->Width(), X->Height());
    return false;
  }

  /* 3.3 Reserve space for Y */
  if (false == reserveGlobal (requestArray[7],
               (0==(requestArray[1].compare("T"))?A->Width(): A->Height()),
               1))
    return false;
  dist_matrix_t* Y = (dist_dataset_map.find (requestArray[7]))->second;

  /* 3.3 Compute what is needed */
  elem::Gemv ((0==(requestArray[1].compare("T"))? 
                   elem::TRANSPOSE : elem::NORMAL),
              alpha,
              (*A),
              (*X),
              0.0,
              (*Y));

  /* 5. Cache things that are needed */
  if (0 != requestArray[4].compare("Y")) 
    if (false == unloadGlobal (requestArray[3])) return false;
  if (0 != requestArray[6].compare("Y")) 
    if (false == unloadGlobal (requestArray[5])) return false;
  if (0 != requestArray[8].compare("Y")) {
    if (false == flushGlobal (requestArray[7])) return false;
  }

  return true;
}

#endif // DGEMV_HPP  
