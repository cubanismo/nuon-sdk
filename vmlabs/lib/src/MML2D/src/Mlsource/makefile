#
# Makefile for 2D MML library

# Copyright (C) 1996-2001 VM Labs, Inc. 

# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.

# All rights reserved.

#------------------------------------------------------------------------------
# Makefile for Mlsource
#------------------------------------------------------------------------------

include $(VMLABS)/util/nuon_build_tools.mk


DEFINES = -DARIES

ifeq ($(MAKECMDGOALS),native)
    bb:= DEFINES += -DBB
endif

CFLAGS = -Os -mreopt -Wall -g $(DEFINES) 
ASFLAGS := $(ASFLAGS) $(DEFINES) -O1

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
MMLHDRS = m2config.h
MMLSRCS = arrow.c execprim.c m2d.c m2ddraw.c mlcolorf.c mlcolor.c mlpixmap.c \
          mlseq.c mlvideo.c quickbox.c speed.c version.c execprimL.c mlsafec.s
RELEASE_SRCS= $(MMLHDRS) $(MMLSRCS) makefile

MMLOBJS = m2d.o      mlcolorf.o mlcolor.o  mlpixmap.o mlvideo.o  arrow.o    \
          m2ddraw.o  mlseq.o    speed.o    execprim.o quickbox.o version.o \
	  mlsafec.o

MMLOBJSL = m2d.o mlcolor.o  mlpixmap.o mlvideo.o \
          execprimL.o version.o

default: native

native: libmml2d.a

bb: libmml2d.a

lite: libmml2dL.a

libmml2d.a: $(MMLOBJS)
	$(AR) rs libmml2d.a $(MMLOBJS)

libmml2dL.a: $(MMLOBJSL)
	$(AR) rs libmml2dL.a $(MMLOBJSL)

src:
	@-$(MKDIR) $(RELEASE_ROOT)/Mlsource
	$(CP) -p $(RELEASE_SRCS) $(RELEASE_ROOT)/Mlsource
