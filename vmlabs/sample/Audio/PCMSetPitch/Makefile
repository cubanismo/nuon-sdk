#
# Makefile for PCMSetPitch sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS =

########################

OBJ = pcm3.o pcmdata.o

LIBS = -lnise -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: pcm3.cof
	coffpack -o cd_app.cof pcm3.cof

pcm3.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o pcm3.cof $(OBJ) $(LIBS)

########################

pcmdata.o: pcmdata.s sin500.pcm
	$(AS) -o pcmdata.o pcmdata.s

########################

load: pcm3.cof
	mload -! -w -w -w -w -p3 -n pcm3.cof -r -m

load2: pcm3.cof
	mload -! -w -w -w -w -fs -p3 -n pcm3.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
