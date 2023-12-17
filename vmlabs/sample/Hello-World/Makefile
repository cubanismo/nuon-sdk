#
# Makefile for "Hello World" sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#
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

OBJ = hello.o

LIBS = -lmml2d -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: hello.cof
	coffpack -o cd_app.cof hello.cof

hello.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o hello.cof $(OBJ) $(LIBS)

########################

load: hello.cof
	mload -! -w -w -w -w -p3 -n hello.cof -r -m

load2: hello.cof
	mload -! -w -w -w -w -p3 -n -fs hello.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
