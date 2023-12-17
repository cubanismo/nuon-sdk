#
# Makefile for 2D MML library test
# Copyright (C) 1996-2001 VM Labs, Inc. 

# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.

# All rights reserved.

#------------------------------------------------------------------------------

# $Id: Makefile,v 1.17 2001/10/19 20:18:27 stuchinsky Exp $

include $(VMLABS)/util/nuon_build_tools.mk

ifeq ($(OSTYPE),linux) 
    EXTRALIB = /usr/local/lib/gcc-lib/merlin-local/2.8.0/
endif

CLEAN_LIBS = libmltxt.a


#------------------------------------------------------------------------------
INC1 = ../fonts

#CFLAGS = -g -O3 -Wall -I$(INC1)
CFLAGS = -g -O3 -mreopt -Wall -I$(INC1)

OBJS = glyfpack.o m2txt.o font.o ufnt.o version.o
MLTXT_SRC = glyfpack.c m2txt.c ufnt.c version.c
MLTXT_HDRS = mltxtpriv.h ufnt.h
FONTS = font.o
T2KLIB = libmltxtBase.a
RELEASE_SRCS= $(MLTXT_SRC) $(MLTXT_HDRS) $(T2KLIB) Makefile readme.txt $(FONTS)

#------------------------------------------------------------------------------
default: libmltxt.a

native: libmltxt.a

bb: libmltxt.a

libmltxt.a: copylib $(OBJS)
	$(AR) -rs libmltxt.a $(OBJS)

copylib:
	$(CP) $(T2KLIB) libmltxt.a

src:
	@-$(MKDIR) $(RELEASE_ROOT)/mltxt
	@-chmod a+w $(RELEASE_ROOT)/mltxt/$(FONTS)
	$(CP) -p $(RELEASE_SRCS) $(RELEASE_ROOT)/mltxt
	chmod a-w $(RELEASE_ROOT)/mltxt/$(FONTS)
