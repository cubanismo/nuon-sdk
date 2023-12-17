#
# Makefile for TimerTest sample
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

OBJ = timertest.o

LIBS = -lmltxt -lmml2d -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: timertest.cof
	coffpack -o cd_app.cof timertest.cof

timertest.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o timertest.cof $(OBJ) $(LIBS)

########################

load: timertest.cof
	mload -! -w -w -w -w -p3 -n timertest.cof -r -m

load2: timertest.cof
	mload -! -w -w -w -w -fs -p3 -n timertest.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
