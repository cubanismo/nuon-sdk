#   Copyright (C) 2001 VM Labs, Inc. 
#
#    NOTICE: VM Labs permits you to use, modify, and distribute this
#    file in accordance with the terms of the VM Labs license agreement
#    accompanying it. If you have received this file from a source other
#    than VM Labs, then your use, modification, or distribution of it
#    requires the prior written permission of VM Labs.
#
#   All rights reserved.

# Makefile for utils executables
# build using Microsoft C
#################################

ifeq ($(BUILDHOST),LINUX)

CC = gcc
CFLAGS = -O2

else

CC = cl
CFLAGS = /Ox
RM = erase

endif

#################################

ifeq ($(BUILDHOST),LINUX)
all-linux: ana240 ana480 mkjpeg mkmidi
endif

all-windows: ana240.exe ana480.exe mkjpeg.exe mkmidi.exe

ana240.exe: ana240.obj image.obj libjpeg.lib
	$(CC) $(CFLAGS) $^ /Fo$@ 

ana480.exe: ana480.obj image.obj libjpeg.lib
	$(CC) $(CFLAGS) $^ /Fo$@ 

mkjpeg.exe: mkjpeg.obj
	$(CC) $(CFLAGS) $^ /Fo$@ 

mkmidi.exe: mkmidi.obj
	$(CC) $(CFLAGS) $^ /Fo$@ 

%.obj: %.c ; $(CC) $(CFLAGS) /c $^ /Fo$@

clean:
	-$(RM) *.exe
	-$(RM) *.obj

# Targets for Linux Build

ana240: ana240.o image.o
	$(CC) $(LDFLAGS) -o ana240 $^ -ljpeg

ana480: ana480.o image.o
	$(CC) $(LDFLAGS) -o ana480 $^ -ljpeg

mkjpeg: mkjpeg.o
	$(CC) $(LDFLAGS) -o mkjpeg $^

mkmidi: mkmidi.o
	$(CC) $(LDFLAGS) -o mkmidi $^
