#ifndef MEX_DSOLVE_HPP
#define MEX_DSOLVE_HPP

#include <cstdio>
#include "mex.h"
#include <string>

#include "globals.hpp"

/**
 * This function scales a matrix on the left of right side with a diagonal:
 *
 * anju('dsolve', 'L/R', 'pathToX', 'Y/N', D, 'Y/N', 'pathToXD', 'Y/N');
 *
 * CAVEAT: Not checking the dimensions. Assuming it's right.
 */
void dsolve (int numOutputs,
             mxArray** outputArray,
             int numInputs,
             const mxArray** inputArray) {
  const char* usage = "Usage\n\
anju('dsolve','L/R','pathToX','Y/N',D,'Y/N','pathToXD','Y/N');\n";

  /* 0. Check that everything is right with the parameters */
  if (0 != numOutputs) {
    mexPrintf ("This function has no outputs\n%s", usage);
    return;
  } else if (8 != numInputs) {
    mexPrintf ("Incorrect number of input parameters (need 8)\n%s", usage);
    return;
  }

  /* 1. Figure out if we are applying from the left or the right */
  std::string direction = getString (inputArray[1]);
  mexPrintf ("Application direction = %s\n", direction.c_str());

  /* 2. Get the name of the file that we need */
  std::string fileNameX = getString (inputArray[2]);
  mexPrintf ("File for X = %s\n", fileNameX.c_str());

  /* 3. Get the caching information */
  std::string cacheX = getString (inputArray[3]);
  mexPrintf ("Caching X? %s\n", cacheX.c_str());

  /* 4. Write out the entries of the diagonal matrix */
  if ((false == mxIsSparse(inputArray[4])) ||
      (mxGetM(inputArray[4]) != mxGetN(inputArray[4]) ||
      (mxGetM(inputArray[4]) != mxGetNzmax(inputArray[4])))) {
    mexPrintf ("D has to be a sparse diagonal matrix\n");
    return;
  }
  std::string fileNameD = fileNameX + "-D";
  double* elementsOfD = mxGetPr(inputArray[4]);
  int numElementsInD = mxGetNzmax(inputArray[4]);
  writeMatrix (numElementsInD, 1, elementsOfD, fileNameD);
  mexPrintf ("File for D = %s\n", fileNameD.c_str());

  /* 5. Get the caching information */
  std::string cacheD = getString (inputArray[5]);
  mexPrintf ("Caching D? %s\n", cacheD.c_str());

  /* 6. Get the name of the file to output to */
  std::string fileNameXD = getString (inputArray[6]);
  mexPrintf ("File for XD = %s\n", fileNameXD.c_str());

  /* 7. Get the caching information */
  std::string cacheXD = getString (inputArray[7]);
  mexPrintf ("Caching XD? %s\n", cacheXD.c_str());

  /* 8. Combine everything into one request */
  std::string request("dsolve ");
  request += direction + " ";
  request += fileNameX + " ";
  request += cacheX + " ";
  request += fileNameD + " ";
  request += cacheD + " ";
  request += fileNameXD + " ";
  request += cacheXD;

  /* 7. Send it away for multiplication */
  mexPrintf ("Request = %s\n", request.c_str());
  sendRequest (request);
}

#endif // MEX_DSOLVE_HPP
