#
# Copyright 1995-2000 VM Labs, Inc. All rights reserved.
# These materials may be used or reproduced solely under an express
# written license from VM Labs, Inc.
#

# $Id: makefile,v 1.15 2001/01/25 23:53:44 lreeber Exp $

include $(VMLABS)/util/vml_make.mk

ASGPU = llama -fcoff -nologo -v
OPT = -O3 -mreopt -fomit-frame-pointer

LOCAL_CFLAGS  = $(DEFINES)

ifndef	RELEASE_ROOT
	RELEASE_ROOT = $(SDK_WORK)
endif

RELEASE_LIB = libm3dl.a
RELEASE_HDRS = dma.h m3dl.h mbm.h pixel.h mdrand.h mdtypes.h
RELEASE_SRCS = *.c *.s makefile *.C inloop M3DL

#
# object files for the project itself
#

LIBOBJS = extra.o mpr.o mprdata.o mprbrkdr.o mprscrbf.o mprsncdr.o mprxtrcl.o mprtmode.o mprimg.o mprtile.o mprsprc.o mprsprca.o mprsprcs.o mprtri.o mprtria.o mprtris.o mprscrcv.o mbm.o setup.o removmpr.o rendobj.o robjdata.o robjdamb.o setscbuf.o setcolor.o settrans.o scrconv.o drawprim.o drawsync.o mpt.o nearclip.o light.o math.o scrmode.o mprinltb.o version.o


#
# How to build the application
#

libm3dl.a: $(LIBOBJS)
	$(AR) rs libm3dl.a $(LIBOBJS)

extra.o: extra.s

mpr.o: mpr.s
	$(ASGPU) -o $@ mpr.s
mprscrbf.o: mprscrbf.s
	$(ASGPU) -o $@ mprscrbf.s
mprscrcv.o: mprscrcv.s
	$(ASGPU) -o $@ mprscrcv.s
mprxtrcl.o: mprxtrcl.s
	$(ASGPU) -o $@ mprxtrcl.s
mprtmode.o: mprtmode.s
	$(ASGPU) -o $@ mprtmode.s
mprtile.o: mprtile.s
	$(ASGPU) -o $@ mprtile.s
mprimg.o: mprimg.s
	$(ASGPU) -o $@ mprimg.s
mprsprc.o: mprsprc.s
	$(ASGPU) -o $@ mprsprc.s
mprsprca.o: mprsprca.s
	$(ASGPU) -o $@ mprsprca.s
mprsprcs.o: mprsprcs.s
	$(ASGPU) -o $@ mprsprcs.s
mprsprb.o: mprsprb.s
	$(ASGPU) -o $@ mprsprb.s
mprtri.o: mprtri.s
	$(ASGPU) -o $@ mprtri.s
mprtria.o: mprtria.s
	$(ASGPU) -o $@ mprtria.s
mprtris.o: mprtris.s
	$(ASGPU) -o $@ mprtris.s
mprinltb.o: mprinltb.s
	$(ASGPU) -o $@ mprinltb.s

mprdata.o: mprdata.s

setup.o: setup.c
	$(CC) -Wall $(OPT) -c -o $@ setup.c

mbm.o: mbm.c
	$(CC) -Wall $(OPT) -c -o $@ mbm.c

rendobj.o: rendobj.c
	$(CC) -Wall $(OPT) -c -o $@ rendobj.c

aabb.o: aabb.c
	$(CC) -Wall $(OPT) -c -o $@ aabb.c

scrmode.o: scrmode.c
	$(CC) -Wall $(OPT) -c -o $@ scrmode.c

version.o: version.c


matrix.o: matrix.c
copytex.o: copytex.s
mpe0dma.o: mpe0dma.s
setscbuf.o: setscbuf.s
setcolor.o: setcolor.s
settrans.o: settrans.s
scrconv.o: scrconv.s
mpt.o: mpt.s
math.o: math.s
robjdata.o: robjdata.s
robjdamb.o: robjdamb.s
light.o: light.s
drawprim.o: drawprim.s
drawsync.o: drawsync.s

export:
	@echo Nothing to export for M3DL

install:
	@-$(MKDIR) $(INSTALL_DIR)/lib
	$(CP) $(RELEASE_LIB) $(INSTALL_DIR)/lib

includes:
	@$(MAKE) -C M3DL release RELEASE_ROOT=$(RELEASE_DIR)

src:
	$(MKDIR) $(RELEASE_ROOT)/lib/src/m3dl
	$(CP) -rp $(RELEASE_SRCS) $(RELEASE_ROOT)/lib/src/m3dl

release: includes src
	@-$(MKDIR) $(RELEASE_ROOT)/lib
# Don't want to use the library we built; Mike Fulton has one with bug fix
#	$(CP) $(RELEASE_LIB) $(RELEASE_ROOT)/lib

include $(VMLABS)/util/vml_make_targets.mk
