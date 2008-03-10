# Makefile for XACML extensions to CUDD
# Kathi Fisler

# EDIT HERE 
# make CUDIR equal the file path to where you have CUDD installed.
# For example, if CUDD is at /pro/xacml/summer2004/cudd/cudd-2.4.0/,

CUDIR = ../../../cudd-2.4.1/
PLT=../../../plt/

# Now replace /pro/xacml/summer2004/cudd/cudd-2.4.0/ with where 
# you have CUDD installed.
# Another example: CUDIR = /home/kfisler/VerifTools/cudd-2.4.0/

# No need to edit anything below here

BDDINCLUDE = ${CUDIR}/include/

import.so : import.o cuddAddXacml.o
	$(PLT)/bin/mzc --ld import.so import.o \
	${CUDIR}/cudd/*.o ${CUDIR}/util/*.o ${CUDIR}/mtr/*.o ${CUDIR}/st/*.o \
	${CUDIR}/epd/*.o cuddAddXacml.o

xacmlplain : cuddAddXacml.c
	gcc -I${BDDINCLUDE} cuddAddXacml.c \
	${CUDIR}/cudd/*.o ${CUDIR}/util/*.o ${CUDIR}/mtr/*.o ${CUDIR}/st/*.o \
	${CUDIR}/epd/*.o -lm

cuddAddXacml.o : cuddAddXacml.c
	$(PLT)/bin/mzc ++ccf -I${BDDINCLUDE} --cc cuddAddXacml.c

cuddAddXacml.so : cuddAddXacml.o
	$(PLT)/bin/mzc --ld cuddAddXacml.so cuddAddXacml.o \
	${CUDIR}/cudd/*.o ${CUDIR}/util/*.o ${CUDIR}/mtr/*.o ${CUDIR}/st/*.o \
	${CUDIR}/epd/*.o

import.o : import.c
	$(PLT)/bin/mzc ++ccf -I${BDDINCLUDE} --cc import.c

clean : 
	rm -f *.so
	rm -f *.o


