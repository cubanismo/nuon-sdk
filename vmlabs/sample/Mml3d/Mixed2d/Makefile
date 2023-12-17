#
# Makefile for MML3D "Mixed2d" sample
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
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

OBJ = mixed.o

LIBS = -lmml3d -lmml2d -lmutil -lm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: mixed.cof
	coffpack -o cd_app.cof mixed.cof

mixed.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o mixed.cof $(OBJ) $(LIBS)

load: mixed.cof
	mload -! -w -w -w -w -p3 -n mixed.cof -r

load2: mixed.cof
	mload -! -w -w -w -w -p3 -n -fs mixed.cof -r

clean:
	-$(RM)	*.cof
	-$(RM)	*.o
	-$(RM)   NUON.CD 
