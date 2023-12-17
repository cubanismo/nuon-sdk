#
# Makefile for PlayWav sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS =

########################

OBJ = wave.o pcmdata.o

LIBS = -lnise -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: wave.cof
	coffpack -o cd_app.cof wave.cof

wave.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o wave.cof $(OBJ) $(LIBS)

########################

pcmdata.o: pcmdata.s bassscale.wav organscale.wav whyscale.aif brassstringsscale.aif
	$(AS) -o pcmdata.o pcmdata.s

########################

load: wave.cof
	mload -! -w -w -w -w -p3 -n wave.cof -r -m

load2: wave.cof
	mload -! -w -w -w -w -fs -p3 -n wave.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
