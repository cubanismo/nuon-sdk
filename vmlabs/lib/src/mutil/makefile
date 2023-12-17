#
# Makefile for Merlin utility library
#
#
# Copyright (C) 1996-2001 VM Labs, Inc.
# 
#  NOTICE: VM Labs permits you to use, modify, and distribute this file
#  in accordance with the terms of the VM Labs license agreement
#  accompanying it. If you have received this file from a source other
#  than VM Labs, then your use, modification, or distribution of it
#  requires the prior written permission of VM Labs.
#
# All rights reserved.

# $Id: Makefile,v 1.34 2001/10/18 22:49:05 ersmith Exp $

include $(VMLABS)/util/nuon_build_tools.mk

ifndef	RELEASE_ROOT
	RELEASE_ROOT = $(SDK_WORK)
endif
RELEASE_DIR = $(RELEASE_ROOT)
RELEASE_HDRS = mutil.h sdram.h msprintf.h
RELEASE_LIBS = libmutil.a
RELEASE_SRCS = *.i *.s *.h *.c Makefile

SDK_INCLUDE = $(INSTALL_DIR)/include/nuon
SDK_LIB = $(INSTALL_DIR)/lib


ifdef	VMLABS_LOCAL
    INSTALL_DIR = $(VMLABS_LOCAL)/lib
else
    INSTALL_DIR = $(VMLABS)/lib
endif

#
# Defines common to all versions
#
LDDIR = -L$(ROOT)/lib $(EXTRALIB)
LOCAL_CFLAGS = -Os -fomit-frame-pointer $(DEFINES)

#
# mutil library files
#
LIBOBJS =  msprintf.o plotpix.o debugws.o \
	runmpe.o mpedma.o \
	sincos.o fixdiv.o sqrt.o \
	sdram.o timer.o \
	vsync.o vidset.o \
	commr.o commglue.o \
	version.o

OBJS = $(LIBOBJS)

libmutil.a: $(OBJS)
	$(AR) rs libmutil.a $(OBJS)

install:
	@-$(MKDIR) $(SDK_INCLUDE)
	@-$(MKDIR) $(SDK_LIB)
	$(CP) -p mutil.h sdram.h msprintf.h $(SDK_INCLUDE)
	$(CP) -p libmutil.a $(SDK_LIB)

includes:
	@-$(MKDIR) $(RELEASE_DIR)/include/nuon
	$(CP) -p $(RELEASE_HDRS) $(RELEASE_DIR)/include/nuon

src:
	@-$(MKDIR) $(RELEASE_DIR)/lib/src/mutil
	$(CP) -p $(RELEASE_SRCS) $(subst \,/,$(RELEASE_DIR)/lib/src/mutil)

release: src includes
	@-$(MKDIR) $(RELEASE_DIR)/lib
	$(CP) -p $(RELEASE_LIBS) $(RELEASE_DIR)/lib

export:
	@echo Nothing to export for mutil.

