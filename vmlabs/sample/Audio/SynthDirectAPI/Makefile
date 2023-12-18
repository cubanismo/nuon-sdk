#
# Makefile for the "SynthDirectAPI" sample
# Copyright (c) 1998-2001 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

CFLAGS = -O -g
ifeq ($(MAKECMDGOALS),high)
    CFLAGS += -DHIGHLEVEL=1
endif

ifeq ($(MAKECMDGOALS),midi)
    CFLAGS += -DMIDIDIRECT=1
endif

ifeq ($(MAKECMDGOALS),low)
    CFLAGS += -DLOWLEVEL=1
endif

ifeq ($(MAKECMDGOALS),loadtest)
    CFLAGS += -DLOADTEST=1
endif
LDFLAGS=

########################

APIOBJS = apitest.o

LIBS = -lsynth -lmutil

default:
	@echo please use one of the following
	@echo    gmake high
	@echo    gmake midi
	@echo    gmake loadtest

high: apitest.cof
midi: apitest.cof
loadtest: apitest.cof

apitest.cof: $(APIOBJS)
	$(CC) $(LDFLAGS) -o $@ $(APIOBJS) $(LIBS)

########################

load: apitest.cof
	mload -! -w -w -w -w -p3 -n -fs apitest.cof -r -m

clean:
	$(RM) *.cof
	$(RM) *.o
