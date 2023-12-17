#
# Makefile for "showjpeg" sample
# Copyright (c) 2000 VM Labs, Inc. All rights reserved.
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

OBJ = main.o jpeg.o graphics.o screenbuffers.o data.o

LIBS = -ljpeg -lmml2d -lmutil -lm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: showjpeg.cof
	coffpack -o cd_app.cof showjpeg.cof

showjpeg.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o showjpeg.cof $(OBJ) $(LIBS)

########################

main.o:main.c showjpeg.h proto.h

graphics.o:graphics.c showjpeg.h proto.h

jpeg.o:jpeg.c showjpeg.h proto.h

screenbuffers.o:screenbuffers.c showjpeg.h proto.h

data.o:data.s bg720.jpg bg360.jpg
	$(AS) -o data.o data.s

########################

load: showjpeg.cof
	mload -! -w -w -w -w -p3 -n showjpeg.cof -r -m

load2: showjpeg.cof
	mload -! -w -w -w -w -p3 -n -fs showjpeg.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
