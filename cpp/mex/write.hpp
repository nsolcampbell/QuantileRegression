#ifndef MEX_WRITE_HPP
#define MEX_WRITE_HPP

void write (int numOutputs,
            mxArray** outputArray,
            int numInputs,
            const mxArray** inputArray) {
  const char* usage = "Usage:\n\
anju ('write', B, 'fileNameB');\n";

  /* 0. Check that everything is right with the parameters */
  if (0 != numOutputs) {
    mexPrintf ("Incorrect number of output parameters\n%s", usage);
    return;
  } else if (3 != numInputs) {
    mexPrintf ("Incorrect number of input parameters\n%s", usage);
    return;
  }

  /* 1. Get the elements */
  int M = mxGetM (inputArray[1]);
  int N = mxGetN (inputArray[1]);
  double* values = mxGetPr (inputArray[1]);

  /* 2. Get the name of the file that we need */
  std::string fileNameB = getString (inputArray[2]);
  mexPrintf ("Writing to: %s\n", fileNameB.c_str());

  /* 3. Write out the matrix */
  writeMatrix (M, N, values, fileNameB);
}


#endif // MEX_WRITE_HPP
