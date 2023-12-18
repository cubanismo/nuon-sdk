#
# Makefile for "dataread" sample
# Copyright (c) 2000 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall -mrom -mpe3
CXXFLAGS = -mrom -mpe3 $(DEFINES) -Wall -Os -Wno-reorder
LDFLAGS = -mrom -mpe3

########################

OBJ = dataread.o

LIBS = -lmml2d -lmutil

dataread.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o dataread.cof $(OBJ) $(LIBS)

########################

load: dataread.cof
	mload -! -w -w -w -w -p3 -n -fs -ms 2048 -me nuon.dat dataread.cof -r -m

load2: dataread.cof
	mload -! -w -w -w -w -p3 -n dataread.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o

