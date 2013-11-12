#ifndef DSCALE_HPP
#define DSCALE_HPP

#include <sstream>
#include <elemental.hpp>

#include "globals.hpp"
#include "load.hpp"
#include "flush.hpp"
#include "unload.hpp"
#include "reserve.hpp"

/**
 * "dscale L/R pathToX Y/N pathToD Y/N pathToXD Y/N"
 */
bool dscale (char* request) {
  /* 0. Chomp out the new line character */
  chomp (request);

  /* 1. Parse and figure out all the parameters */
  int requestCount = 0;
  std::string requestArray[8];
  std::stringstream requestStream(request);
  while (getline(requestStream, requestArray[requestCount++], ' '));
  if (8 != (requestCount-1)) {
    fprintf (stderr, "There are fewer than 8 arguments! (%d)\n", requestCount);
    return false;
  }

  /* 2. Load X and D into memory */
  if (false == loadGlobal (requestArray[2])) return false;
  if (false == loadGlobal (requestArray[4])) return false;

  /* 3. Perform the requested operation */
  /* 3.0 Get all the required matrices */
  dist_matrix_t* X = (dist_dataset_map.find (requestArray[2]))->second;
  dist_matrix_t* D = (dist_dataset_map.find (requestArray[4]))->second;

  /* 3.1 Make sure that D is a column vector */
  if (1 != D->Width()) {
    fprintf (stderr, "D is not a column vector (%d,%d)\n",
                                          D->Height(), D->Width());
    return false;
  }

  /* 3.2 Copy X into XD */
  dist_matrix_t* XD = new dist_matrix_t();
  elem::Copy ((*X), (*XD));
  dist_dataset_map[requestArray[6]] = XD;

  /* 3.3 Compute what is needed */
  elem::DiagonalScale ((0==(requestArray[1].compare("L"))? 
                          elem::LEFT: elem::RIGHT),
                       elem::NORMAL,
                       (*D),
                       (*XD));

  /* 5. Cache things that are needed */
  if (0 != requestArray[3].compare("Y")) 
    if (false == unloadGlobal (requestArray[2])) return false;
  if (0 != requestArray[5].compare("Y")) 
    if (false == unloadGlobal (requestArray[4])) return false;
  if (0 != requestArray[7].compare("Y")) {
    if (false == flushGlobal (requestArray[6])) return false;
  }

  return true;
}

#endif // DSCALE_HPP  
