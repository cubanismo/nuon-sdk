#
# Makefile for SAFEAREA sample
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

OBJ = safearea.o

LIBS = -lmml2d -lmltxt -lmutil -lm

safearea.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o safearea.cof $(OBJ) $(LIBS)

########################

load: safearea.cof
	mload -! -w -w -w -w -p3 -n safearea.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o

