#
# Makefile for Impulse
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#
#------------------------------------------------------------------------------

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

CXX = mgcc
CXXFLAGS = -g -Wall -Wno-reorder -DDEBUG

########################

OBJS = sample.o aglHelloWorld.o sampleFunctions.o sampleTestData.o palettes.o

LIBS = -lAGL -lNuonAGL -lNuonImpulseDebug -lImpulseEffects -lImpulse -lmml2d -lm

sample.cof: $(OBJS)
	$(CC) -o sample.cof $(OBJS) $(LIBS)

########################

load: sample.cof
	mload -! -w -w -w -w -p3 -fs -n sample.cof -r -m

clean:
	$(RM) *.o
	$(RM) *.cof
