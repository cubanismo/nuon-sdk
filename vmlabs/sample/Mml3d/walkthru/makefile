#
# Makefile for MML walkthrouh test
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

OBJS = walk.o model.o
LIBS = -lmml3d -lmml2d -lmutil -lm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: walk.cof
	coffpack -o cd_app.cof walk.cof

walk.cof: $(OBJS)
	$(CC) $(LDFLAGS) -o walk.cof $(OBJS) $(LIBS)

########################

load: walk.cof
	mload -! -w -w -w -w -p3 -n walk.cof -r 

load2: walk.cof
	mload -! -w -w -w -w -p3 -n -fs walk.cof -r 

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
