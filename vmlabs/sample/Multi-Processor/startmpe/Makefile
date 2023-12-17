#
# Makefile for STARTMPE sample
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

OBJS = multi.o mpecode.o

LIBS = -lmml2d -lmutil -lm

########################

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: multi.cof
	coffpack -o cd_app.cof multi.cof

multi.cof: $(OBJS)
	$(CC) $(LDFLAGS) -o multi.cof $(OBJS) $(LIBS)

load: multi.cof
	mload -! -w -w -w -w -p3 -n multi.cof -r -m -fs

clean:
	-$(RM)	*.cof
	-$(RM)	*.o
	-$(RM)	NUON.CD
