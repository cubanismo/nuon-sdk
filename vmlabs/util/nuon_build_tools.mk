#
# Makefile Include to specify program names
#
# Copyright (c) 2000-2001 VM Labs, Inc. All rights reserved.
#
#  NOTICE: VM Labs permits you to use, modify, and distribute this file
#  in accordance with the terms of the VM Labs license agreement
#  accompanying it. If you have received this file from a source other
#  than VM Labs, then your use, modification, or distribution of it
#  requires the prior written permission of VM Labs.
#

########################
CC = mgcc
CXX = mg++
AS = llama -fcoff -nologo -c -g $(DEFINES)
LD = collect2 
AR = vmar

########################
ifeq ($(BUILDHOST),LINUX)

ROOT = /usr/local/merlin-local
RM = rm -f
CP = cp

else

ROOT = /vmlabs
RM = erase
CP = copy

endif

########################
# Provide build rule for C++ files that use ".cpp" extension instead of ".C" or ".cc"

.SUFFIXES: .cpp .o

.cpp.o:
	$(CXX) -c -o $@ $(CXXFLAGS) $<


########################
# Provide default rule for C source files

.c.o:
	$(CC) $(CFLAGS) -c $< -o $*.o


########################
# Provide default rule for Assembly source files

.s.o:
	$(AS) -o $@ $<


