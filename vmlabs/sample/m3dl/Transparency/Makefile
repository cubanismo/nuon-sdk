#
# Makefile for "Transparency" sample
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
# 
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
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall 
LDFLAGS = 

########################

OBJS = transparency.o datafile.o

LIBS = -lm3dl -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: transparency.cof
	coffpack -o cd_app.cof transparency.cof

transparency.cof: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

########################

datafile.o: datafile.s sprite.mbm sprite2.mbm sprite3.mbm bg.MBI

bg.MBI: bg.bmp
	bmp2mbm -YCRCB -16 -IMG bg.bmp

sprite.mbm: sprite.bmp
	bmp2mbm -YCRCB -4 -T255,255,255 -M4096 sprite.bmp

sprite2.mbm: sprite2.bmp
	bmp2mbm -YCRCB -4 -T255,255,255 -M4096 sprite2.bmp

sprite3.mbm: sprite3.bmp
	bmp2mbm -YCRCB -4 -T255,255,255 -M4096 sprite3.bmp

load: transparency.cof
	mload -! -w -w -w -w -p3 -n transparency.cof -r -fs -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
