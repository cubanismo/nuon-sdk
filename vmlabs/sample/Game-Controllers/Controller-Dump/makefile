#
# Makefile for Controller-Dump sample
# 
# Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.

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

OBJ = controller.o graphics.o screenbuffers.o data.o

LIBS = -lmltxt -lmml2d -lmutil

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: controller.cof
	coffpack -o cd_app.cof controller.cof

controller.cof: $(OBJ)
	$(CC) $(LDFLAGS) -o controller.cof $(OBJ) $(LIBS)

########################

controller.o:controller.c proto.h controller.h

graphics.o:graphics.c proto.h controller.h

screenbuffers.o:screenbuffers.c proto.h controller.h

data.o:data.s background.ycrcb
	$(AS) -o data.o data.s

background.ycrcb: background.raw
	rgb2ycrcb -f_e888Alpha -a2 -o background.ycrcb background.raw

########################

load: controller.cof
	mload -! -w -w -w -w -p3 -n controller.cof -r -m

load2: controller.cof
	mload -! -w -w -w -w -p3 -n -fs controller.cof -r -m

strip: controller.cof
	vmstrip -F -o nuon.run controller.cof
	
clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) *.ycrcb
	-$(RM) NUON.CD
