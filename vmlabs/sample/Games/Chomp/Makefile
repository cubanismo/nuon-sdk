#
# Makefile for Chomp
#
# Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.

###############################

include $(VMLABS)/util/nuon_build_tools.mk

###############################

DEFINES =
CFLAGS = -g -O3 -Wall $(DEFINES)
LDFLAGS = 

###############################

OBJS = chomp.o data.o wave.o

LIBS = -lterm -lsprite -lmutil -lnise

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: chomp.cof
	coffpack -o cd_app.cof chomp.cof

chomp.cof: $(OBJS) data.s levels.h
	$(CC) $(LDFLAGS) -o chomp.cof $(OBJS) $(LIBS)

###############################

load run: chomp.cof
	mload -! -w -w -w -p3 -n chomp.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
