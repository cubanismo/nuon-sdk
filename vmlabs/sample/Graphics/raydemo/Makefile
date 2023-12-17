#
# Makefile for graphics demo
# Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.

include $(VMLABS)/util/nuon_build_tools.mk

#
# platform independent stuff
#
LIBS = -lmutil -lterm
DEFINES = 

CFLAGS = -Os $(DEFINES) -Wall

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: demo.cof
	coffpack -o cd_app.cof demo.cof

demo.cof: demo.o raybox.o ray.o mandel.o menu.o sky.o $(LIBOBJS)
	$(CC) -o demo.cof demo.o raybox.o ray.o mandel.o menu.o sky.o $(LIBS)

ray.o: ray/main.s ray/merlin.i ray/raydata.s ray/raydefs.h ray/raymain.s ray/raytrace.s ray/rsqrtlo.s ray/scene.s
	$(AS) -Iraytrace -o foo.o ray/main.s
	vmstrip -o ray.o foo.o
	$(RM) foo.o

raybox.o: raybox/main.s raybox/raydata.s raybox/raydefs.h raybox/raymain.s raybox/raytrace.s raybox/rsqrtlo.s raybox/scene.s raybox/move.s raybox/logo.s raybox/box.s
	$(AS) -Iraytrace -o foo.o raybox/main.s
	vmstrip -o raybox.o foo.o
	$(RM) foo.o

mandel.o: mandel/mandel.s mandel/recip.s mandel/reciplut.i mandel/mandel.h
	$(AS) -o mandel.o mandel/mandel.s

demo.o: demo.c ray/raydefs.h mandel/mandel.h

load: demo.cof
	mload -! -w -w -w -w -p3 -n demo.cof -r

clean:
	-$(RM) *.o
	-$(RM) *.cof
	-$(RM) NUON.CD
