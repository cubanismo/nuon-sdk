#
# Makefile for fstest sample
# Copyright (c) 2000 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall -mrom -mpe3
LDFLAGS = -mrom -mpe3

########################

OBJ = fstest.o

LIBS = 

fstest.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o fstest.cof $(OBJ) $(LIBS)

########################

load: fstest.cof
	mload -! -w -w -w -w -p3 -n -fs fstest.cof -r -m

load2: fstest.cof
	mload -! -w -w -w -w -p3 -n -fs fstest.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o
