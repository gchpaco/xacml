# Makefile for XACML extensions to CUDD
# Kathi Fisler

# EDIT HERE 
# make CUDIR equal the file path to where you have CUDD installed.
# For example, if CUDD is at /pro/xacml/summer2004/cudd/cudd-2.4.0/,

CUDIR = /pro/xacml/summer2004/cudd/cudd-2.4.0/

# Now replace /pro/xacml/summer2004/cudd/cudd-2.4.0/ with where 
# you have CUDD installed.
# Another example: CUDIR = /home/kfisler/VerifTools/cudd-2.4.0/

# No need to edit anything below here

BDDINCLUDE = ${CUDIR}/include/

all : xacmlCudd.so

xacmlCudd.o : xacmlCudd.c
	mzc ++ccf -I${BDDINCLUDE} --cc xacmlCudd.c

xacmlCudd.so : xacmlCudd.o
	mzc --ld xacmlCudd.so xacmlCudd.o \
	${CUDIR}/cudd/*.o ${CUDIR}/util/*.o ${CUDIR}/mtr/*.o ${CUDIR}/st/*.o \
	${CUDIR}/epd/*.o

clean : 
	rm -f *.so
	rm -f *.o


