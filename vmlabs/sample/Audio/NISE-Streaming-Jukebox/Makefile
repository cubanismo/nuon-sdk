#
# Makefile for NISE-Streaming sample
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

OBJ = stream.o

LIBS = -lnise -lmml2d -lmltxt -lmutil -lm

stream.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o stream.cof $(OBJ) $(LIBS)

########################

load: stream.cof
	mload -! -w -w -w -w -p3 -n stream.cof -r -m

load2: stream.cof
	mload -! -w -w -w -w -fs -p3 -n stream.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o
