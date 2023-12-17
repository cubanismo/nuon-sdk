#
# Makefile for RECTANGLE2 sample
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
CFLAGS = -g -O $(DEFINES) -Wall
LDFLAGS =

########################

OBJS = rectangle2.o

LIBS = -lmml2d -lmutil

########################

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: rectangle2.cof
	coffpack -o cd_app.cof rectangle2.cof

rectangle2.cof: $(OBJS)
	$(CC) $(LDFLAGS) -o rectangle2.cof $(OBJS) $(LIBS)

load: rectangle2.cof
	mload -! -w -w -w -w -p3 -n rectangle2.cof -r

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
