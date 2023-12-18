# Makefile for building all of the Terminal-Emulator samples
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

COMPONENTS = Hello-World Sky

%.default:
	@$(MAKE) -C $(*F)

%.clean:
	@$(MAKE) -C $(*F) clean

default: $(foreach dir,$(COMPONENTS),$(dir).default)

clean: $(foreach dir,$(COMPONENTS),$(dir).clean)
