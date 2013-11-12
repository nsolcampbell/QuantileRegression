# Comment if you are using OCTAVE instead of MATLAB
MEX=/gsa/yktgsa/projects/w/watapps/matlab/linux/R2009a/bin/mex
MEXFLAGS=

# Uncomment if you are using OCTAVE instead of MATLAB
#MEX=mkoctfile
#MEXFLAGS=--mex

SOFTWARE=${HOME}/Software
CC=mkoctfile
INCLUDE=-I${SOFTWARE}/include/
INCLIBS=-L${SOFTWARE}/lib \
        -llapack \
        -lblas 
CFLAGS=-mex

HEADERS=globals.hpp \
        syrk.hpp \
        write.hpp \
        read.hpp \
        dscale.hpp \
        dsolve.hpp \
        dgemv.hpp

all: anju

anju: trampoline.cpp ${HEADERS}
	${MEX} ${MEXFLAGS} $< -o $@

clean:
	rm -rf *core* *.o *.dSYM *.port *.mex *.oct *.out* *.err* *.mex*
