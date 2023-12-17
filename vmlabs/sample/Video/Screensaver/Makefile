#
# Makefile for SCREENSAVER sample
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

OBJ = main.o graphics.o screensaver.o data.o

LIBS = -lmml2d -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: saver.cof
	coffpack -o cd_app.cof saver.cof

saver.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o saver.cof $(OBJ) $(LIBS)

########################

main.o: main.c proto.h progdefs.h

graphics.o: graphics.c proto.h progdefs.h

screenbuffers.o: screenbuffers.c proto.h progdefs.h

data.o: data.s vmlogo.ycrcb
	$(AS) -o data.o data.s

vmlogo.ycrcb: vmlogo.raw
	rgb2ycrcb -f_e888Alpha -a2 -o vmlogo.ycrcb vmlogo.raw

########################

load: saver.cof
	mload -! -w -w -w -w -p3 -n saver.cof -r -m

load2: saver.cof
	mload -! -w -w -w -w -fs -p3 -n saver.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) *.ycrcb
	-$(RM) NUON.CD
