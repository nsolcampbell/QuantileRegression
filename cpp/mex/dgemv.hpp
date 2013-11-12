#ifndef MEX_DGEMV_HPP
#define MEX_DGEMV_HPP

#include <cstdio>
#include "mex.h"
#include <string>

#include "globals.hpp"

/**
 * This function exists to speed up AA' or A'A, where A is a very large dense
 * rectangular matrix:
 *
 * anju ('dgemv','T/N',alpha,'pathToA','Y/N','pathToX','Y/N',pathToY,'Y/N');
 *
 * CAVEAT: Not checking the dimensions. Assuming it's right.
 */
void dgemv (int numOutputs,
            mxArray** outputArray,
            int numInputs,
            const mxArray** inputArray) {
  const char* usage = "Usage\n\
anju ('dgemv','T/N',alpha,'pathToA','Y/N',X,'Y/N',pathToY,'Y/N');\n";

  /* 0. Check that everything is right with the parameters */
  if (0 != numOutputs) {
    mexPrintf ("This function has no outputs\n%s", usage);
    return;
  } else if (9 != numInputs) {
    mexPrintf ("Incorrect number of input parameters (need 9)\n%s", usage);
    return;
  }

  /* 1. Figure out if we want to transpose or not */
  std::string transpose = getString (inputArray[1]);
  mexPrintf ("Transposing A? %s\n", transpose.c_str());

  /* 2. Figure out the value of alpha and put it in a string */
  const int alphaDbl = getDouble (inputArray[2]);
  if (0.0 == alphaDbl) return;
  std::stringstream s; s << alphaDbl;
  std::string alpha = s.str();
  mexPrintf ("Alpha = %s\n", alpha.c_str());

  /* 3. Get the name of the file that we need */
  std::string fileNameA = getString (inputArray[3]);
  mexPrintf ("File for A = %s\n", fileNameA.c_str());

  /* 4. Get the caching information */
  std::string cacheA = getString (inputArray[4]);
  mexPrintf ("Caching A? %s\n", cacheA.c_str());

  /* 5. Write out the entries of X */
  std::string fileNameX = fileNameA + "-X";
  {
    int M = mxGetM (inputArray[5]);
    int N = mxGetN (inputArray[5]);
    double* values = mxGetPr (inputArray[5]);
    writeMatrix (M, N, values, fileNameX);
  }

  /* 6. Get the caching information */
  std::string cacheX = getString (inputArray[6]);
  mexPrintf ("Caching X? %s\n", cacheX.c_str());

  /* 7. Get the name of the file that we need */
  std::string fileNameY = getString (inputArray[7]);
  mexPrintf ("File for Y = %s\n", fileNameY.c_str());

  /* 8. Get the caching information */
  std::string cacheY = getString (inputArray[8]);
  mexPrintf ("Caching Y? %s\n", cacheY.c_str());

  /* 9. Combine everything into one request */
  std::string request("dgemv ");
  request += transpose + " ";
  request += alpha + " ";
  request += fileNameA + " ";
  request += cacheA + " ";
  request += fileNameX + " ";
  request += cacheX + " ";
  request += fileNameY + " ";
  request += cacheY;

  /* 7. Send it away for multiplication */
  mexPrintf ("Request = %s\n", request.c_str());
  sendRequest (request);
}

#endif // MEX_DGEMV_HPP
