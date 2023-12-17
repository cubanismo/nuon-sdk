
#
# Makefile for MML2D library

# Copyright (C) 1996-2001 VM Labs, Inc. 

# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.


# Possible targets are:
#
# native (the default): build libmml2d.a for linking
#    with NUON applications
# bb:  build special libmml2d.a for settop firmware
# lite: build lite version as base for Alphamask Graphics Library
#     does not include special effects lines and ovals

include $(VMLABS)/util/nuon_build_tools.mk

RELEASE_DIR = $(SDK_WORK)
ifdef	VMLABS_LOCAL
    INSTALL_DIR = $(VMLABS_LOCAL)
else
    INSTALL_DIR = $(VMLABS)
endif
RELEASE_LIB = $(RELEASE_ROOT)/lib
RELEASE_LIB_SRC = $(RELEASE_ROOT)/lib/src/MML2D/src
RELEASE_LIB_INCLUDE = $(RELEASE_ROOT)/lib/src/MML2D/nuon
RELEASE_SRCS = Makefile Readme.txt
RELEASE_INCLUDE = $(RELEASE_ROOT)/include/nuon
INSTALL_LIB = $(INSTALL_DIR)/lib
INSTALL_INCLUDE = $(INSTALL_DIR)/include/nuon

#------------------------------------------------------------------------------
# life would be so much easier if we could agree on slashes for directories
#------------------------------------------------------------------------------
#
MRPCODES_H     := ..$(SEP)nuon$(SEP)mrpcodes.h
MML2D_H        := ..$(SEP)nuon$(SEP)mml2d.h
LIBMML2D_A     := Mlsource$(SEP)libmml2d.a
LIBMLTXT_A     := mltxt$(SEP)libmltxt.a

COMPONENTS = mrplib Mlsource mltxt

COMPONENTSL = mrplib Mlsource


#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
.PHONY : default
.PHONY : help
.PHONY : native
.PHONY : dvd
.PHONY : bb
.PHONY : lite
.PHONY : clean
.PHONY : install	# copy headers and libraries to .../vmlabs/...

default: native

help:
	echo "please select one of the following targets:"
	echo "    native: library for NUON apps"
	echo "    bb:     special BB firmware library"
	echo "    lite:   special lighweight library for AGL base"

%.native:
	@$(MAKE) -C $(*F) native

%.bb:
	@$(MAKE) -C $(*F) bb
	
%.lite:
	@$(MAKE) -C $(*F) lite

.PHONY: native bb lite

native: $(foreach dir,$(COMPONENTS),$(dir).native)

bb: $(foreach dir,$(COMPONENTS),$(dir).bb)

lite: $(foreach dir,$(COMPONENTSL),$(dir).lite)

install:
	$(CP) $(MRPCODES_H) $(MML2D_H) $(INSTALL_INCLUDE)
	$(CP) $(LIBMML2D_A) $(LIBMLTXT_A)  $(INSTALL_LIB)

includes:
	@-$(MKDIR) $(RELEASE_INCLUDE)
	$(CP) $(MRPCODES_H) $(MML2D_H) $(RELEASE_INCLUDE)

src:
	@-$(MKDIR) $(RELEASE_LIB_SRC)
	@-$(MKDIR) $(RELEASE_LIB_INCLUDE)
	$(MAKE) -C Mlsource src RELEASE_ROOT=$(RELEASE_LIB_SRC)
	$(MAKE) -C mrplib src RELEASE_ROOT=$(RELEASE_LIB_SRC)
	$(MAKE) -C mltxt src RELEASE_ROOT=$(RELEASE_LIB_SRC)
	$(MAKE) -C Fonts src RELEASE_ROOT=$(RELEASE_LIB_SRC)
	$(CP) $(RELEASE_SRCS) $(RELEASE_LIB_SRC)
	$(CP) $(MRPCODES_H) $(MML2D_H) $(RELEASE_LIB_INCLUDE)

release: src includes
	@-$(MKDIR) $(RELEASE_LIB)
	$(CP) $(LIBMML2D_A) $(LIBMLTXT_A) $(RELEASE_LIB)
