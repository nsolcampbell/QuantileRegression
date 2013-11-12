#ifndef SYRK_HPP
#define SYRK_HPP

#include <sstream>
#include <elemental.hpp>

#include "globals.hpp"
#include "load.hpp"
#include "flush.hpp"
#include "unload.hpp"
#include "reserve.hpp"

/**
 * "syrk T/N pathToA Y/N pathToAA Y/N"
 *
 * @param 'T' or 'N' If 'T', A'A is computed. If not, AA' is computed.
 * @param pathToA The file that contains A (column-major order).
 * @param cacheA This boolean tells us to cache A for posterity.
 * @param pathToAA This is where we will write out the matrix finally
 * 
 * @return A'A or AA'
 */
bool syrk (char* request) {
  /* 0. Chomp out the new line character */
  chomp (request);

  /* 1. Parse and figure out all the parameters */
  int requestCount = 0;
  std::string requestArray[6];
  std::stringstream requestStream(request);
  while (getline(requestStream, requestArray[requestCount++], ' '));
  if (6 != (requestCount-1)) {
    fprintf (stderr, "There are fewer than 5 arguments! (%d)\n", requestCount);
    return false;
  }

  /* 2. Load A into memory */
  if (false == loadGlobal (requestArray[2])) return false;
  dist_matrix_t* A = (dist_dataset_map.find (requestArray[2]))->second;

  /* 3. Perform the requested operation */
  /* 3.0 Reserve space for the AA */
  if (false == reserveGlobal (requestArray[4], 
               (0==(requestArray[1].compare("T"))?A->Width(): A->Height()),
               (0==(requestArray[1].compare("T"))?A->Width(): A->Height())))
    return false;
  dist_matrix_t* AA = (dist_dataset_map.find (requestArray[4]))->second;

  /* 3.1 Compute A'A or AA' */
  elem::Syrk (elem::UPPER,
              (0==(requestArray[1].compare("T"))?elem::TRANSPOSE:
                                                 elem::NORMAL),
              1.0,
              (*A),
              0.0,
              (*AA));

  /* 4. If caching is not requested, unload from memory */
  if (0 != requestArray[3].compare("Y")) 
    if (false == unloadGlobal (requestArray[2])) return false;
  if (0 != requestArray[5].compare("Y")) {
    if (false == flushGlobal (requestArray[4])) return false;
  }

  return true;
}

#endif
