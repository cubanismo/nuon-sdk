#
# Makefile for MIDI-Custom-Bank sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS = -Xlinker -T -Xlinker synthwav=0x80600000:0x0015FFFF

########################

OBJ = banktest.o data.o

LIBS = -lsynth -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: banktest.cof
	coffpack -o cd_app.cof banktest.cof

banktest.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o banktest.cof $(OBJ) $(LIBS)

########################

data.o: data.s test.sbi
	$(AS) -o data.o data.s

########################

load: banktest.cof
	mload -! -w -w -w -w -p3 -n banktest.cof -r -m

load2: banktest.cof
	mload -! -w -w -w -w -fs -p3 -n banktest.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
