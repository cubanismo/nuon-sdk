#   Copyright (C) 2001 VM Labs, Inc. 
#
#    NOTICE: VM Labs permits you to use, modify, and distribute this
#    file in accordance with the terms of the VM Labs license agreement
#    accompanying it. If you have received this file from a source other
#    than VM Labs, then your use, modification, or distribution of it
#    requires the prior written permission of VM Labs.
#
#   All rights reserved.

#
# Makefile for "SlideShow" sample NUON.CD app
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

####### include user's configuration data

include ../user.dat

########################

DEFINES = -DVIEWTIME_SECONDS=$(VIEWTIME) -DHI_RES=$(HIRES) -DMIDI_PLAYBACK=$(MIDIPLAY)
CFLAGS = -O3 -g -mreopt $(DEFINES) -Wall

ifeq ($(MIDIPLAY),1)        

LDFLAGS = -mrom -mpe3 -Xlinker -T -Xlinker synthwav=0x80600000:0x0015FFFF
OBJ = main.o ir_remote.o midiplay.o jpeg.o video.o jpegfiles.o midifiles.o
LIBS = -ljpeg -lmml2d -lsynth -lmutil -lm

else

LDFLAGS =
OBJ = main.o ir_remote.o jpeg.o video.o jpegfiles.o
LIBS = -ljpeg -lmml2d -lmutil -lm

endif

########################

NUON.CD: SlideShow.cof
	coffpack -o packed.cof SlideShow.cof
	CreateNuonCD packed.cof
	$(CP) NUON.CD ..\release

SlideShow.cof: $(OBJ) ../user.dat
	$(CC) $(LDFLAGS) -o SlideShow.cof $(OBJ) $(LIBS)

########################

ifeq ($(MIDIPLAY),1)
midifiles.s: ../midifiles.lst
	../utils/mkmidi ../midifiles.lst
endif

jpegfiles.s: ../jpegfiles.lst
	../utils/mkjpeg ../jpegfiles.lst


########################

load: SlideShow.cof
	mload -! -w -w -w -w -p3 -n SlideShow.cof -r -m

load2: SlideShow.cof
	mload -! -w -w -w -w -p3 -n -fs SlideShow.cof -r -m

clean:
	-$(RM) *.cof
	-$(RM) *.o
	-$(RM) jpegfiles.s
	-$(RM) midifiles.s
	-$(RM) NUON.CD
	-$(RM) ..\release\NUON.CD
