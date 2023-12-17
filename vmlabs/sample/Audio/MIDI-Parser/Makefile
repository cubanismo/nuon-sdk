#
# Makefile for MIDI-Parser sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS = -Xlinker -T -Xlinker synthwav=0x80600000:0x0015FFFF

########################

OBJ = play.o data.o

LIBS = -lsynth -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: play.cof
	coffpack -o cd_app.cof play.cof

play.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o play.cof $(OBJ) $(LIBS)

########################

data.o: data.s Ricercare_3.mid
	$(AS) -o data.o data.s

########################

load: play.cof
	mload -! -w -w -w -w -p3 -n play.cof -r -m

load2: play.cof
	mload -! -w -w -w -w -fs -p3 -n play.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
