#
# Makefile for "transparency" sample
# Copyright (c) 2000 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.
#
#
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall 
LDFLAGS = 

########################

OBJ = transparency.o datafile.o

LIBS = -lm3dl -lmutil


NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: transparency.cof
	coffpack -o cd_app.cof transparency.cof

transparency.cof: ckrbd.mbi $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $(OBJ) $(LIBS)

########################

ckrbd.mbi: ckrbd.bmp
	bmp2mbm -IMG -YCRCB -16 -NM ckrbd.bmp

load: transparency.cof
	mload -! -w -w -w -w -p3 -n transparency.cof -r -m

load2: transparency.cof
	mload -! -w -w -w -w -p3 -n -fs transparency.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) NUON.CD
