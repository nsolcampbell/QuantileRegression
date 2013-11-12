SOFTWARE=${HOME}/ANJU/Software
MKLROOT=${SOFTWARE}/mkl/lib
CC=mpic++
INCLUDE=-I${SOFTWARE}/include/
INCLIBS=-L${SOFTWARE}/lib \
        -lelemental \
        -Wl,--start-group \
        ${MKLROOT}/intel64/libmkl_intel_lp64.a \
        ${MKLROOT}/intel64/libmkl_gnu_thread.a \
        ${MKLROOT}/intel64/libmkl_core.a \
        -Wl,--end-group \
        -ldl \
        -lgomp \
        -lpthread \
        -lm
CFLAGS=-fPIC -O3 -Wno-deprecated -Wno-unsigned -fopenmp

HEADERS=syrk.hpp \
        dsolve.hpp \
        dscale.hpp \
        dgemv.hpp \
        load.hpp \
        unload.hpp \
        globals.hpp \
        reserve.hpp \
        flush.hpp 

all: server

server: server.cpp ${HEADERS}
	${CC} ${CFLAGS} ${INCLUDE} $< -o $@ ${INCLIBS}

temp: temp.cpp
	${CC} ${CFLAGS} ${INCLUDE} $< -o $@ ${INCLIBS}

clean:
	rm -rf server *core* *.o *.dSYM *.port *.out* *.err*
	rm -rf stdout stderr error console.* *.serialized temp
