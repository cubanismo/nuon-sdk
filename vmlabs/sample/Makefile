# Makefile for building all samples
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

COMPONENTS = AGL \
	Audio \
	BIOS-Stuff \
	Diagnostics \
	File-Server \
	Game-Controllers \
	Games \
	Graphics \
	Hello-World \
	Impulse \
	Jpeg \
	m3dl \
	Media-Access \
	mgl \
	Miscellaneous \
	mml2d \
	Mml3d \
	Multi-Processor \
	NUON-Programming-Series \
	Outline-Text \
	Slide-Show \
	Sprites \
	Terminal-Emulator \
	Video

%.default:
	@-$(MAKE) -C $(*F)

%.clean:
	@-$(MAKE) -C $(*F) clean

default: $(foreach dir,$(COMPONENTS),$(dir).default)

clean: $(foreach dir,$(COMPONENTS),$(dir).clean)
