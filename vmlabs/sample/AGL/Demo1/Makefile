#
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.
#

#------------------------------------------------------------------------------

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

CXXFLAGS = -g -Wall -c -Os -Wno-reorder -frepo

########################

OBJS = sample.o aglHelloWorld.o sampleFunctions.o sampleTestData.o palettes.o

LIBS = -lNuonAGL -lAGLEffects -lAGL -lmml2d -lm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: sample.cof
	coffpack -o cd_app.cof sample.cof

sample.cof: $(OBJS)
	$(CXX) -o sample.cof $(OBJS) $(LIBS)

########################

load: sample.cof
	mload -! -w -w -w -w -p3 -n sample.cof -r -m

clean:
	-$(RM) *.o
	-$(RM) *.rpo
	-$(RM) *.cof
	-$(RM) NUON.CD

########################

LIBS_DEBUG = -lNuonAGLDebug -lAGLEffectsDebug -lAGLDebug -lmml2d -lm

load-debug: clean $(OBJS)
	$(CC) -o sample.cof $(OBJS) $(LIBS_DEBUG)
	mload -! -w -w -w -w -p3 -fs -n sample.cof -r -m
