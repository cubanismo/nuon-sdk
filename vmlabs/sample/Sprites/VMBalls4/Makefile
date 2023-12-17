#
# Makefile for "vmballs" sample
# Copyright (c) 2000 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

DEFINES =
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall -mrom -mpe3
CXXFLAGS = -mrom -mpe3 $(DEFINES) -Wall -Os -Wno-reorder
LDFLAGS = -mrom -mpe3

########################

OBJ = vmballs.o  graphics.o sprite.o

LIBS = -lsprite -lmml2d -lmutil

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
	$(RM) *.cof
	$(RM) *.o
	$(RM) *.ycrcb


