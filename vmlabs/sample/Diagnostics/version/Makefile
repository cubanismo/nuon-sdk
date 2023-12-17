#
# Makefile for version sample
#
# Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS =

########################

OBJ = version.o

LIBS = -lmml3d -lmltxt -lmml2d -ljpeg -lnise -lsynth -lmgl -lmutil -lm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: version.cof
	coffpack -o cd_app.cof version.cof

version.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o version.cof $(OBJ) $(LIBS)

########################

load: version.cof
	mload -! -w -w -w -w -p3 -n version.cof -r -m

load2: version.cof
	mload -! -w -w -w -w -fs -p3 -n version.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
