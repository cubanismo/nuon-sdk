#
# Makefile for "dataread" sample
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

OBJ = dataread.o

LIBS = -lmml2d -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: dataread.cof
	coffpack -o cd_app.cof dataread.cof

dataread.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o dataread.cof $(OBJ) $(LIBS)

########################

load: dataread.cof
	mload -! -w -w -w -w -p3 -n -fs -ms 2048 -me datafile dataread.cof -r -m

load2: dataread.cof
	mload -! -w -w -w -w -p3 -n dataread.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
