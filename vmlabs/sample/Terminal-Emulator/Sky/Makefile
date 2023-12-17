#
# Makefile for "term-emulator" sample
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Lab

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

CFLAGS = -g -O3 -mreopt -Wall $(DEFINES)
LDFLAGS =

ifdef DEBUG
CFLAGS += -DDEBUG
endif

########################

OBJS = drawsky.o sky.o

LIBS = -lmml2d -lmutil -lterm

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: term-emulator.cof
	coffpack -o cd_app.cof term-emulator.cof

term-emulator.cof: $(OBJS)
	$(CC) $(LDFLAGS) -o term-emulator.cof $(OBJS) $(LIBS) 

########################

load: term-emulator.cof
	mload -! -w -w -w -w -p3 -n term-emulator.cof -r

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
