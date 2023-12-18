#
# Copyright (c) 2000 VM Labs, Inc.
# All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS= $(DEFINES) -Wall -mrom -mpe3
CCFLAGS= -Wstrict-prototypes -mrom -mpe3
LDFLAGS = -mrom -mpe3

########################

#
# object files for the project itself
#

OBJS = vidoverlay.o graphics.o

#
# How to build the application
#

vidoverlay.cof: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) -lmml2d -lmutil -lm

vidoverlay.o: vidoverlay.c vidoverlay.h

graphics.o: graphics.c vidoverlay.h

load: vidoverlay.cof
	mload -! -w -w -w -w -p3 -n vidoverlay.cof -r -m

load2: vidoverlay.cof
	mload -p3 -n vidoverlay.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o

