#
# Makefile for SameGame sample

# Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.



###############################

include $(VMLABS)/util/nuon_build_tools.mk

###############################

CFLAGS = -g -O -Wall -DNUON

###############################

OBJS = sg.o sg_xtract.o tga2.o animate.o delete_group.o demo.o determine_group.o game.o gamestats.o hilight.o initialize.o mycopy.o mycopy2.o togglecolour.o pause.o parser.o playagain.o score.o sound.o titlescreen.o auxvid2.o 

LIBS = -lmml2d -lmltxt -lm -lnise

NUON.CD: cd_app.cof
	CreateNuonCD

cd_app.cof: sg.cof
	coffpack -o cd_app.cof sg.cof

sg.cof: $(OBJS)
	$(CC) -mpe3 -mrom -o sg.cof $(OBJS) $(LIBS)

###############################

COLORS = Contents\Colors\sg.dat
SHAPES = Contents\Shapes\sg.dat
GAME_TYPE = $(SHAPES)

ifeq ($(BUILDHOST),LINUX)
  GAME_TYPE:=$(subst \,/,$(GAME_TYPE))
endif

sg.dat: $(GAME_TYPE)
	$(CP) $(GAME_TYPE) .

###############################

sg.o: sg.c sg.h sg_xtract.h sg.dat init_nuon.c

$(OBJS): sg.h

parser.o tga2.o sound.o sg_xtract.o: sg_xtract.h

###############################

load: cd_app.cof
	mload -! -w -w -w -p3 -n cd_app.cof -r

load2: cd_app.cof
	mload -! -w -w -w -p3 -n -fs cd_app.cof -r

clean:
	-$(RM) *.o
	-$(RM) *.cof
	-$(RM) NUON.CD
