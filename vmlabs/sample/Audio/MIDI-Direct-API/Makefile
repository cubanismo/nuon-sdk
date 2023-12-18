#
# Makefile for MIDI-Direct-API sample
# Copyright (c) 2000 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall -mrom -mpe3
LDFLAGS = -mrom -mpe3 -Xlinker -T -Xlinker synthwav=0x80600000:0x0015FFFF

########################

OBJ = apitest.o

LIBS = -lsynth -lmutil

apitest.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o apitest.cof $(OBJ) $(LIBS)

########################

load: apitest.cof
	mload -! -w -w -w -w -p3 -n apitest.cof -r -m

load2: apitest.cof
	mload -! -w -w -w -w -fs -p3 -n apitest.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o
