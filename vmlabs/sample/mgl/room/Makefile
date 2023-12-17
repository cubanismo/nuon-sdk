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
CFLAGS=$(DEFINES) -Wall -O2 -g
LDFLAGS =

########################

OBJS = main.o room.o drawroom.o

LIBS = -lmgl -ljpeg -lmml2d -lmutil -lm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: room.cof
	coffpack -o cd_app.cof room.cof

room.cof: $(OBJS)
	$(CC) $(LDFLAGS) -o room.cof $(OBJS) $(LIBS)

########################

load: room.cof
	mload -! -w -w -w -w -p3 -n room.cof -r

load2: room.cof
	mload -! -w -w -w -w -p3 -n -fs room.cof -r

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
