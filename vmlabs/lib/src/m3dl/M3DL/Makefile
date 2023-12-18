#
# Copyright 1995-2000 VM Labs, Inc. All rights reserved.
# These materials may be used or reproduced solely under an express
# written license from VM Labs, Inc.
#

# $Id: Makefile,v 1.3 2000/12/12 04:20:28 lreeber Exp $

include $(VMLABS)/util/vml_make.mk

ifndef	RELEASE_ROOT
	RELEASE_ROOT = $(SDK_WORK)
endif

RELEASE_HDRS = dma.h m3dl.h mbm.h pixel.h mdrand.h mdtypes.h
ifdef	VMLABS_LOCAL
    INSTALL_DIR = $(VMLABS_LOCAL)
else
    INSTALL_DIR = $(VMLABS)
endif

default:
	@echo Nothing to do for M3DL includes.

export:
	@echo Nothing to export for M3DL includes.

install:
	-$(MKDIR) $(INSTALL_DIR)/include/m3dl
	$(CP) -p $(RELEASE_HDRS) $(INSTALL_DIR)/include/m3dl

release:
	-$(MKDIR) $(RELEASE_DIR)/include/m3dl
	$(CP) -p $(RELEASE_HDRS) $(RELEASE_DIR)/include/m3dl

include $(VMLABS)/util/vml_make_targets.mk

