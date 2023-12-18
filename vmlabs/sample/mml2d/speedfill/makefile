#
# Makefile for "speedfill" sample
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

OBJ = speedfill.o aux2d.o auxvid.o auxtext.o

LIBS = -lmltxt -lmml2d -lmutil -lm

speedfill.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o speedfill.cof $(OBJ) $(LIBS)

########################

load: speedfill.cof
	mload -! -w -w -w -w -p3 -n speedfill.cof -r -m

load2: speedfill.cof
	mload -! -w -w -w -w -p3 -n -fs speedfill.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o

