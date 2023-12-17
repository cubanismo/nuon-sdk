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

# $Id: Makefile,v 1.20 2001/10/19 20:10:12 stuchinsky Exp $

include $(VMLABS)/util/nuon_build_tools.mk

S_HDRS=_reciplut.i _rsqrtlut.i _sinelut.i macros.i macros1.i mrp.i
S_SRCS=aaline1.s aaline2.s aaline3.s aaline4.s aaline5.s aaline6.s aln3clut.s aln5clut.s aln6clut.s aln7clut.s biosdma.s circlut.s cpyfst16.s dma.s drawpt.s lin3clut.s lin5clut.s lin6clut.s lin7clut.s loadr.s math_tab.s odma.s ol_circle.s ol_dmacmd.s ol_line1.s ol_line2.s ol_line3.s ol_line4.s ol_line5.s ol_line6.s recip.s rsqrt.s sincos.s sqrt.s
C_HDRS=biosdma.h mrpproto.h mrptypes.h parblock.h pixmacro.h version.h
C_SRCS=bicopy.c clrcv16.c colrcvrt.c copdflt.c copsdclut.c copsdram.c copun0r.c copun1r.c copuns.c copy32.c copy8.c copyclut.c copytile8.c cvrtbb.c cvrttran.c drawline.c fill.c fillclut.c fillmpeg.c loadcoff.c movepix.c mrp456.c mrp56.c mrp6.c mrp6in.c mrpsetup.c pcmdo.c scrollup.c txtalpha.c txtblend.c txtblt.c

RELEASE_SRCS = $(S_HDRS) $(S_SRCS) $(C_HDRS) $(C_SRCS) Makefile

DEFINES := -DARIES

#CFLAGS = -Wall $(DEFINES)
CFLAGS = -O3 -mreopt -Wall $(DEFINES) -g
ASFLAGS := $(ASFLAGS) $(DEFINES)
ASFLAGS += -O1

ifeq ($(MAKECMDGOALS),bb)
    ASFLAGS += -O1
    CFLAGS += -DBB
endif

#------------------------------------------------------------------------------
# OBJS are the event modules
#------------------------------------------------------------------------------
OBJS =	copsdram.o	mrpsetup.o	bicopy.o	mrp6.o		mrp456.o	mrp56.o		\
		colrcvrt.o	fill.o		dma.o		sincos.o	recip.o		sqrt.o		\
		rsqrt.o		math_tab.o	ol_line1.o	ol_line2.o	ol_line3.o	ol_line4.o	\
		ol_line5.o	ol_line6.o	ol_circle.o	odma.o		drawline.o	cvrttran.o	\
		loadr.o		loadcoff.o	copuns.o	copdflt.o	copun1r.o	clrcv16.o	\
		copun0r.o	txtalpha.o	txtblt.o	txtblend.o	lin3clut.o	lin7clut.o	\
		circlut.o	copy32.o	fillmpeg.o	pcmdo.o		scrollup.o	drawpt.o	\
		movepix.o	copyclut.o	fillclut.o	copsdclut.o copy8.o

ifeq ($(MAKECMDGOALS),native)
    OBJS += copytile8.o cpyfst16.o
endif

#------------------------------------------------------------------------------
# OBJSL are the modules for mml2dLite
#------------------------------------------------------------------------------
OBJSL =	copsdram.o	mrpsetup.o	bicopy.o	mrp6.o		mrp456.o	mrp56.o		\
		colrcvrt.o	fill.o	cvrttran.o	\
		copuns.o	copdflt.o	copun1r.o	clrcv16.o	\
		copun0r.o 	copy32.o	\
		copyclut.o	fillclut.o	copsdclut.o copy8.o copytile8.o cpyfst16.o

#------------------------------------------------------------------------------

native: libmrp.a

bb: libmrp.a

libmrp.a: $(OBJS)
	$(AR) rs ../Mlsource/libmml2d.a $(OBJS)

lite: libmrpL.a

libmrpL.a: $(OBJSL)
	$(AR) rs ../Mlsource/libmml2dL.a $(OBJSL)

src:
	@-$(MKDIR) $(RELEASE_ROOT)/mrplib
	$(CP) -p $(RELEASE_SRCS) $(RELEASE_ROOT)/mrplib
