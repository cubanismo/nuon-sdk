# Makefile for building all of the Outline-Text samples
# Copyright (c) 2001 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
#

########################

include $(VMLABS)/util/nuon_build_tools.mk

########################

COMPONENTS = truetype txdemo

%.default:
	@$(MAKE) -C $(*F)

%.clean:
	@$(MAKE) -C $(*F) clean

default: $(foreach dir,$(COMPONENTS),$(dir).default)

clean: $(foreach dir,$(COMPONENTS),$(dir).clean)
