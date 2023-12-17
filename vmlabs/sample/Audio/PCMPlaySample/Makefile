#
# Makefile for PCMPlaySample sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS =

########################

OBJ = pcm1.o pcmdata.o

LIBS = -lnise -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: pcm1.cof
	coffpack -o cd_app.cof pcm1.cof

pcm1.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o pcm1.cof $(OBJ) $(LIBS)

########################

pcmdata.o: pcmdata.s spacecat.pcm
	$(AS) -o pcmdata.o pcmdata.s

########################

load: pcm1.cof
	mload -! -w -w -w -w -p3 -n pcm1.cof -r -m

load2: pcm1.cof
	mload -! -w -w -w -w -fs -p3 -n pcm1.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
