#
# Makefile for MML 3D library
#
#
# Copyright (C) 1995-2001 VM Labs, Inc.
# 
#  NOTICE: VM Labs permits you to use, modify, and distribute this file
#  in accordance with the terms of the VM Labs license agreement
#  accompanying it. If you have received this file from a source other
#  than VM Labs, then your use, modification, or distribution of it
#  requires the prior written permission of VM Labs.
#
# All rights reserved.
#
# $Id: Makefile,v 1.40 2001/10/18 22:28:13 ersmith Exp $

#
# set INCLUDE_EDGEAA to 1 when the edge-antialiasing
# code is finished
#
INCLUDE_EDGEAA = 0

DEFINES = -DINCLUDE_EDGEAA=$(INCLUDE_EDGEAA)

include $(VMLABS)/util/nuon_build_tools.mk

ifndef	RELEASE_ROOT
	RELEASE_ROOT = $(SDK_WORK)
endif
RELEASE_DIR = $(RELEASE_ROOT)
RELEASE_LIBS = libmml3d.a
RELEASE_HDRS = m3d.h m3dbuf.h m3dmat.h m3dtypes.h
RELEASE_SRCS = *.i *.s *.h *.c Makefile fluff128.jpg

SDK_INCLUDE = $(INSTALL_DIR)/include/nuon
SDK_LIB = $(INSTALL_DIR)/lib

#
# Common definitions
#
CFLAGS = $(DEFINES) -O2 -Wall -mreopt
LDFLAGS = -mrom -mpe3
#LDFLAGS = -mpe3

LIBS = -lmml3d -lmml2d -ljpeg -lmutil -lm

#
# 3D library files
#

ifeq ($(INCLUDE_EDGEAA),1)
AAOBJS = aaend.o
else
AAOBJS = 
endif

LIBOBJS = m3dbuf.o m3dmat.o m3djpeg.o m3dlite.o m3dcamera.o m3dmatrix.o \
	load3d.o pieces.o version.o m3dadd.o $(AAOBJS)

OBJS = $(LIBOBJS) testparm.o

default: libmml3d.a

all: test.cof # mpegtest.cof

test.cof: libmml3d.a test.o textures.o
	$(CC) $(LDFLAGS) -o $@ test.o textures.o $(LIBS)

mpegtest.cof: libmml3d.a mpegtest.o
	$(CC) $(LDFLAGS) -Xlinker -T -Xlinker sdram=0x40200000 -o $@ mpegtest.o $(LIBS)

libmml3d.a: $(OBJS)
	$(AR) rs libmml3d.a $(OBJS)

pieces.o: pieces.s pipeline.s reciplo.s reciphi.s \
	loadpoly.s xformlo.s clip.s light.s \
	persp.s poly.s param.s global.s doclip.i \
	pixel.s bilerp.s \
	aapoly.s aabilerp.s mpegpix.s

export:
	@echo Nothing to export for MML3D.

install: 
	@-$(MKDIR) $(SDK_INCLUDE)
	@-$(MKDIR) $(SDK_LIB)
	$(CP) m3d.h m3dbuf.h m3dmat.h m3dtypes.h $(SDK_INCLUDE)
	$(CP) libmml3d.a $(SDK_LIB)

includes:
	@-$(MKDIR) $(RELEASE_DIR)/include/nuon
	$(CP) -p $(RELEASE_HDRS) $(RELEASE_DIR)/include/nuon

src:
	@-$(MKDIR) $(RELEASE_DIR)/lib/src/MML3D
	$(CP) -p $(RELEASE_SRCS) $(subst \,/,$(RELEASE_DIR)/lib/src/MML3D)

release: src includes
	@-$(MKDIR) $(RELEASE_DIR)/lib
	$(CP) -p $(RELEASE_LIBS) $(RELEASE_DIR)/lib

clean:
	-$(RM) libmml3d.a
	-$(RM) *.o
