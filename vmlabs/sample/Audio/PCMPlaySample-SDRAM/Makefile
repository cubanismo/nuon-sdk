#
# Makefile for PCMPlaySample sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS = -Xlinker -T -Xlinker pcmdata=0x40400000

########################

OBJ = pcm.o pcmdata.o

LIBS = -lnise -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: pcm.cof
	coffpack -o cd_app.cof pcm.cof

pcm.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o pcm.cof $(OBJ) $(LIBS)

########################

pcmdata.o: pcmdata.s spacecat.pcm
	$(AS) -o pcmdata.o pcmdata.s

########################

load: pcm.cof
	mload -! -w -w -w -w -p3 -n pcm.cof -r -m

load2: pcm.cof
	mload -! -w -w -w -w -fs -p3 -n pcm.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD