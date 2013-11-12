#ifndef MEX_SYRK_HPP
#define MEX_SYRK_HPP

#include <cstdio>
#include "mex.h"
#include <string>

#include "globals.hpp"

/**
 * This function exists to speed up AA' or A'A, where A is a very large dense
 * rectangular matrix:
 *
 * anju ('syrk', 'T/N', 'pathToA', 'Y/N', 'pathToAA', 'Y/N');
 *
 * CAVEAT: Not checking the dimensions. Assuming it's right.
 */
void syrk (int numOutputs,
           mxArray** outputArray,
           int numInputs,
           const mxArray** inputArray) {
  const char* usage = "Usage\n\
anju ('syrk', 'T/N', 'pathToA', 'Y/N', 'pathToAA', 'Y/N');\n";

  /* 0. Check that everything is right with the parameters */
  if (0 != numOutputs) {
    mexPrintf ("This function has no outputs\n%s", usage);
    return;
  } else if (6 != numInputs) {
    mexPrintf ("Incorrect number of input parameters (need 6)\n%s", usage);
    return;
  }

  /* 1. Figure out if we want to transpose or not */
  std::string transpose = getString (inputArray[1]);
  mexPrintf ("Transposing A? %s\n", transpose.c_str());

  /* 2. Get the name of the file that we need */
  std::string fileNameA = getString (inputArray[2]);
  mexPrintf ("File for A = %s\n", fileNameA.c_str());

  /* 3. Get the caching information */
  std::string cacheA = getString (inputArray[3]);
  mexPrintf ("Caching A? %s\n", cacheA.c_str());

  /* 4. Get the name of the file to output to */
  std::string fileNameAA = getString (inputArray[4]);
  mexPrintf ("File for A = %s\n", fileNameAA.c_str());

  /* 5. Get the caching information */
  std::string cacheAA = getString (inputArray[5]);
  mexPrintf ("Caching AA? %s\n", cacheAA.c_str());

  /* 6. Combine everything into one request */
  std::string request("syrk ");
  request += transpose + " ";
  request += fileNameA + " ";
  request += cacheA + " ";
  request += fileNameAA + " ";
  request += cacheAA;

  /* 7. Send it away for multiplication */
  mexPrintf ("Request = %s\n", request.c_str());
  sendRequest (request);
}

#endif // MEX_SYRK_HPP
