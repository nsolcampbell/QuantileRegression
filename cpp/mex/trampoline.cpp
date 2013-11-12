#include <cstdio>
#include "mex.h"
#include <string>

#include "globals.hpp"
#include "syrk.hpp"
#include "dscale.hpp"
#include "dsolve.hpp"
#include "dgemv.hpp"
#include "write.hpp"
#include "read.hpp"

/**
 * This function exists merely to trampoline into many other functions based
 * on the first argument that is called. Other that that, no useful function
 * is performed. The call is made using:
 *
 * [A, B, ...] = anju ('functionName', X, Y, Z, ...);
 *
 */
void mexFunction (int numOutputs,
                  mxArray** outputArray,
                  int numInputs,
                  const mxArray** inputArray) {
  const char* usage = "Usage\n\
[A, B, ...] = anju ('functionName', X, Y, Z, ...);\n\
where function name is syrk or \n";

  /* 1. Figure out which function is needed */
  std::string functionName = getString (inputArray[0]);
  mexPrintf ("Calling function: %s\n", functionName.c_str());

  /* 2. Dispatch */
  if (0 == functionName.compare("syrk")) {
    syrk (numOutputs, outputArray, numInputs, inputArray);
  } else if (0 == functionName.compare("dscale")) {
    dscale (numOutputs, outputArray, numInputs, inputArray);
  } else if (0 == functionName.compare("dsolve")) {
    dsolve (numOutputs, outputArray, numInputs, inputArray);
  } else if (0 == functionName.compare("dgemv")) {
    dgemv (numOutputs, outputArray, numInputs, inputArray);
  } else if (0 == functionName.compare("write")) {
    write (numOutputs, outputArray, numInputs, inputArray);
  } else if (0 == functionName.compare("read")) {
    read (numOutputs, outputArray, numInputs, inputArray);
  } else {
    mexPrintf ("Incorrect function name\n%s", usage);
  }

  return;
}
