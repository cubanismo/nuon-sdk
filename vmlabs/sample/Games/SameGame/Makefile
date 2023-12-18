#
# Makefile for SameGame sample
# Copyight (c) 1998-2001 VM Labs, Inc. All ights eseved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

CFLAGS = -g -O -Wall
LIBS = -lmml2d  -lmltxt -lm -lnise

########################

OBJS = sg.o tga2.o animate.o delete_group.o demo.o determine_group.o game.o gamestats.o hilight.o initialize.o mycopy.o mycopy2.o togglecolour.o pause.o parser.o playagain.o score.o sound.o titlescreen.o auxvid2.o 

SameGame.cof: $(OBJS)
	$(CC) -o SameGame.cof $(OBJS) $(LIBS)

########################

sg.o: sg.c sg.h animate.c determine_group.c hilight.c delete_group.c init_nuon.c score.c initialize.c game.c parser.c playagain.c titlescreen.c pause.c mycopy.c mycopy2.c sound.c gamestats.c

########################

load: SameGame.cof
	mload -! -w -w -w -fs -p3 -n SameGame.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o
