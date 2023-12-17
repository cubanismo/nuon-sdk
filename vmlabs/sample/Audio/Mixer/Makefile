#
# Makefile for MIDI-Parser sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS =

########################

OBJ = mixer.o data.o

LIBS = -lsynth -lmml2d -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: mixer.cof
	coffpack -o cd_app.cof mixer.cof

mixer.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o mixer.cof $(OBJ) $(LIBS)

########################

data.o: data.s sin500.pcm LittleGMinorFugue.mid
	$(AS) -o data.o data.s

########################

load: mixer.cof
	mload -! -w -w -w -w -p3 -n mixer.cof -r -m

load2: mixer.cof
	mload -! -w -w -w -w -fs -p3 -n mixer.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
