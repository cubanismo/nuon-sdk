# Makefile for blend sample
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES = 
CFLAGS=$(DEFINES) -Wall -O2 -g
LDFLAGS=

########################

OBJS = data.o main.o

LIBS = -lmgl -ljpeg -lmml2d -lmutil -lm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: blend.cof
	coffpack -o cd_app.cof blend.cof

blend.cof: $(OBJS)
	$(CC) $(LDFLAGS) -o blend.cof $(OBJS) $(LIBS)

########################

load: blend.cof
	mload -! -w -w -w -w -p3 -n blend.cof -r

load2: blend.cof
	mload -! -w -w -w -w -p3 -n -fs blend.cof -r

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
