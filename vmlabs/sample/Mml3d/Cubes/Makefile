#
# Makefile for MML3D "Cubes" sample
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.
 
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS =

########################

OBJ = test3d.o

LIBS = -lmml3d -lmml2d -lmutil -lm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: test3d.cof
	coffpack -o cd_app.cof test3d.cof

test3d.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o test3d.cof $(OBJ) $(LIBS)

load: test3d.cof
	mload -! -w -w -w -w -p3 -n test3d.cof -r -m

load2: test3d.cof
	mload -! -w -w -w -w -p3 -n -fs test3d.cof -r -m

clean:
	-$(RM)	*.cof
	-$(RM)	*.o
	-$(RM)	NUON.CD
