
#Copyright (C) 1996-2001 VM Labs, Inc. 

# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.

# All rights reserved.

include $(VMLABS)/util/nuon_build_tools.mk

#
# local definitions
#

ifndef	RELEASE_ROOT
	RELEASE_ROOT = $(SDK_WORK)
endif

RELEASE_HDRS = gl.h gltypes.h
RELEASE_LIBS = libmgl.a
RELEASE_SRCS = *.c *.h *.s Makefile

LOCAL_CFLAGS = -O2
#LOCAL_CFLAGS = -g -DDEBUG

LOBJS		= api.o \
			  begend.o \
			  bmp.o \
			  clip.o \
			  globals.o \
			  glmutils.o \
			  glutils.o \
			  jpg.o \
			  light.o \
			  lighting.o \
			  loadpoly.o \
			  matrix.o \
			  mgl.o \
			  mpe_data.o \
			  mpe_manage.o \
			  pipeline.o \
			  raster.o \
			  rasterp.o \
			  rasterpk.o \
			  render.o \
			  trivia.o \
			  version.o \
			  xform.o
	
#
# local targets
#

libmgl.a: $(LOBJS)
	$(AR) crs libmgl.a $(LOBJS)

install: $(RELEASE_HDRS) $(RELEASE_LIBS)
	@-$(MKDIR) $(INSTALL_DIR)/include/nuon
	@-$(MKDIR) $(INSTALL_DIR)/lib
	$(CP) $(RELEASE_HDRS) $(INSTALL_DIR)/include/nuon
	$(CP) $(RELEASE_LIBS) $(INSTALL_DIR)/lib

export:
	@echo Nothing to export for mgl.

doc:
	$(CP) -p libmgl.doc $(DOC_LOCATION)/libmgl.doc
	$(CP) -p release.txt $(DOC_LOCATION)/mgl_release.txt

includes:
	@-$(MKDIR) $(RELEASE_ROOT)/include/nuon
	$(CP) -p $(RELEASE_HDRS) $(RELEASE_ROOT)/include/nuon

src:
	@-$(MKDIR) $(RELEASE_ROOT)/lib/src/mgl
	$(CP) -p $(RELEASE_SRCS) $(subst \,/,$(RELEASE_ROOT)/lib/src/mgl)

release: includes src
	@-$(MKDIR) $(RELEASE_ROOT)/lib
	$(CP) -p $(RELEASE_LIBS) $(RELEASE_ROOT)/lib

clean:
	-$(RM) libmgl.a
	-$(RM) *.o
