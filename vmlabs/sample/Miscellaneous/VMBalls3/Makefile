#
# Makefile for "vmballs" sample
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.


########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall
LDFLAGS =

########################

OBJ = vmballs.o  graphics.o sprite.o

LIBS = -lmml2d -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: vmballs.cof
	coffpack -o cd_app.cof vmballs.cof

vmballs.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o vmballs.cof $(OBJ) $(LIBS)

########################

vmballs.o:vmballs.c

graphics.o:graphics.c

sprite.o:sprite.s vball.ycrcb vmlogo.ycrcb
	$(AS) -o sprite.o sprite.s

vball.ycrcb: vball.raw
	rgb2ycrcb -f_e888Alpha -a2 -o vball.ycrcb vball.raw

vmlogo.ycrcb: vmlogo.raw
	rgb2ycrcb -f_e888Alpha -a2 -o vmlogo.ycrcb vmlogo.raw

########################

load: vmballs.cof
	mload -! -w -w -w -w -p3 -n vmballs.cof -r -m

load2: vmballs.cof
	mload -! -w -w -w -w -p3 -n -fs vmballs.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) *.ycrcb
	-$(RM) NUON.CD
