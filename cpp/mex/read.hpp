#ifndef MEX_READ_HPP
#define MEX_READ_HPP

void read (int numOutputs,
           mxArray** outputArray,
           int numInputs,
           const mxArray** inputArray) {
  const char* usage = "Usage:\n\
B = anju('read', 'fileNameB');\n";

  /* 0. Check that everything is right with the parameters */
  if (1 != numOutputs) {
    mexPrintf ("Incorrect number of output parameters\n%s", usage);
    return;
  } else if (2 != numInputs) {
    mexPrintf ("Incorrect number of input parameters\n%s", usage);
    return;
  }

  /* 1. Get the name of the file that we need */
  std::string fileNameB = getString (inputArray[1]);
  mexPrintf ("Reading from: %s\n", fileNameB.c_str());

  /* 2. Read in the matrix */
  readMatrix (&(outputArray[0]), fileNameB);
}

#endif // MEX_READ_HPP
