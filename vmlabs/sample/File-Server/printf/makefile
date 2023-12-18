#
# Makefile for printf sample
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

OBJ = printf.o

LIBS = 

printf.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o printf.cof $(OBJ) $(LIBS)

########################

load: printf.cof
	mload -! -w -w -w -w -p3 -n -fs printf.cof -r -m

load2: printf.cof
	mload -! -w -w -w -w -p3 -n -fs printf.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o
