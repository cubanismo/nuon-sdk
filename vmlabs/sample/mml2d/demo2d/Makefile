#
# Makefile for "demo2d" sample
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

OBJ = demo2d.o aux2d.o

LIBS = -lmltxt -lmml2d -lmutil -lm

demo2d.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o demo2d.cof $(OBJ) $(LIBS)

########################

load: demo2d.cof
	mload -! -w -w -w -w -p3 -n demo2d.cof -r -m

load2: demo2d.cof
	mload -! -w -w -w -w -p3 -n -fs demo2d.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o

