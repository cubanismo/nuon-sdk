# Makefile for Independent JPEG Group's software
# MODIFIED by VM Labs Inc., to run on NUON. These modifications are
# copyright 1998, 2000-2001 VM Labs, Inc.; all rights reserved.

include $(VMLABS)/util/nuon_build_tools.mk
ifndef	RELEASE_ROOT
	RELEASE_ROOT = $(SDK_WORK)
endif
RELEASE_DIR = $(RELEASE_ROOT)

# This makefile is suitable for Unix-like systems with ANSI-capable compilers.
# If you have a non-ANSI compiler, makefile.unix is a better starting point.

# Read installation instructions before saying "make" !!

# The name of your C compiler:
# CC= merlin-local-gcc

# options for NUON building
DEFINES =

CCFLAGS= -Wstrict-prototypes
ifdef	VMLABS_LOCAL
    INSTALL_DIR = $(VMLABS_LOCAL)
else
    INSTALL_DIR = $(VMLABS)
endif
RELEASE_LIBS= libjpeg.a
SDK_INCLUDE=$(INSTALL_DIR)/include/jpeg
SDK_LIB=$(INSTALL_DIR)/lib

# RELEASE_HDRS is defined later.

# You may need to adjust these cc options:
CFLAGS=$(DEFINES) -Wall -O2 -mrom -mpe3

# Generally, we recommend defining any configuration symbols in jconfig.h,
# NOT via -D switches here.

# Link-time cc options:
LDFLAGS =  -mrom -mpe3

# To link any special libraries, add the necessary -l commands here.
LDLIBS= -lrombios 

# Put here the object file name for the correct system-dependent memory
# manager file.  For Unix this is usually jmemnobs.o, but you may want
# to use jmemansi.o or jmemname.o if you have limited swap space.
SYSDEPMEM= jmemnobs.o

# miscellaneous OS-dependent stuff
# linker
LN= $(CC)

# file deletion command
# RM= rm -f
# library (.a) file creation command
# AR= merlin-local-ar rc
# second step in .a creation (use "touch" if not needed)
AR2= touch

# End of configurable options.


# source files: JPEG library proper
LIBSOURCES= jcapimin.c jcapistd.c jccoefct.c jccolor.c jcdctmgr.c jchuff.c \
        jcinit.c jcmainct.c jcmarker.c jcmaster.c jcomapi.c jcparam.c \
        jcphuff.c jcprepct.c jcsample.c jctrans.c jdapimin.c jdapistd.c \
        jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c jddctmgr.c jdhuff.c \
        jdinput.c jdmainct.c jdmarker.c jdmaster.c jdmerge.c jdphuff.c \
        jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c jfdctfst.c \
        jfdctint.c jidctflt.c jidctfst.c jidctint.c jidctred.c jquant1.c \
        jquant2.c jutils.c jmemmgr.c
# memmgr back ends: compile only one of these into a working library
SYSDEPSOURCES= jmemansi.c jmemname.c jmemnobs.c jmemdos.c jmemmac.c
# source files: cjpeg/djpeg/jpegtran applications, also rdjpgcom/wrjpgcom
APPSOURCES= cjpeg.c djpeg.c jpegtran.c cdjpeg.c rdcolmap.c rdswitch.c \
        rdjpgcom.c wrjpgcom.c rdppm.c wrppm.c rdgif.c wrgif.c rdtarga.c \
        wrtarga.c rdbmp.c wrbmp.c rdrle.c wrrle.c
SOURCES= $(LIBSOURCES) $(SYSDEPSOURCES) $(APPSOURCES)
# files included by source files
INCLUDES= jchuff.h jdhuff.h jdct.h jerror.h jinclude.h jmemsys.h jmorecfg.h \
        jpegint.h jpeglib.h jversion.h cdjpeg.h cderror.h jconfig.h
# files included in NUON release.
RELEASE_HDRS= cderror.h   jconfig.h   jerror.h    jmorecfg.h  jversion.h \
              cdjpeg.h    jdct.h      jinclude.h  jpegint.h   jchuff.h \
		      jdhuff.h    jmemsys.h   jpeglib.h

# documentation, test, and support files
DOCS= README install.doc usage.doc cjpeg.1 djpeg.1 jpegtran.1 \
	rdjpgcom.1 \
        wrjpgcom.1 wizard.doc example.c libjpeg.doc structure.doc \
        coderules.doc filelist.doc
MKFILES= configure makefile.cfg makefile.ansi makefile.unix makefile.bcc \
        makefile.mc6 makefile.dj makefile.wat makcjpeg.st makdjpeg.st \
        makljpeg.st maktjpeg.st makefile.manx makefile.sas makefile.mms \
        makefile.vms makvms.opt
CONFIGFILES= jconfig.cfg jconfig.manx jconfig.sas jconfig.st jconfig.bcc \
        jconfig.mc6 jconfig.dj jconfig.wat jconfig.vms
OTHERFILES= jconfig.doc ckconfig.c ansi2knr.c ansi2knr.1 jmemdosa.asm
TESTFILES= testorig.jpg testimg.ppm testimg.gif testimg.jpg testprog.jpg \
        testimgp.jpg
DISTFILES= $(DOCS) $(MKFILES) $(CONFIGFILES) $(SOURCES) $(INCLUDES) \
        $(OTHERFILES) $(TESTFILES)
# merlin/nuon specific files
SYSDEP_HDR = jconfig.h
NUONSOURCE = memdata.c jidctint.s
NUONDOCS = README.NUON

RELEASE_SRCS= $(DOCS) Makefile $(SOURCES) $(INCLUDES) $(TESTFILES) $(OTHERFILES) $(RELEASE_HDRS) $(NUONSOURCE) $(NUONDOCS) $(SYSDEP_HDR)

# library object files common to compression and decompression
COMOBJECTS= jcomapi.o jutils.o jerror.o jmemmgr.o $(SYSDEPMEM)
# compression library object files
CLIBOBJECTS= jcapimin.o jcapistd.o jctrans.o jcparam.o jdatadst.o jcinit.o \
        jcmaster.o jcmarker.o jcmainct.o jcprepct.o jccoefct.o jccolor.o \
        jcsample.o jchuff.o jcphuff.o jcdctmgr.o jfdctfst.o jfdctflt.o \
        jfdctint.o
# decompression library object files
DLIBOBJECTS= jdapimin.o jdapistd.o jdtrans.o jdatasrc.o jdmaster.o \
        jdinput.o jdmarker.o jdhuff.o jdphuff.o jdmainct.o jdcoefct.o \
        jdpostct.o jddctmgr.o jidctfst.o jidctflt.o jidctint.o jidctred.o \
        jdsample.o jdcolor.o jquant1.o jquant2.o jdmerge.o
# merlin/nuon specific object files
NUONOBJECTS = memdata.o jidctint.o

# These objectfiles are included in libjpeg.a
LIBOBJECTS= $(CLIBOBJECTS) $(DLIBOBJECTS) $(COMOBJECTS) $(NUONOBJECTS)

# object files for sample applications (excluding library files)
COBJECTS= cjpeg.o rdppm.o rdgif.o rdtarga.o rdrle.o rdbmp.o rdswitch.o \
        cdjpeg.o
DOBJECTS= djpeg.o wrppm.o wrgif.o wrtarga.o wrrle.o wrbmp.o rdcolmap.o \
        cdjpeg.o
TROBJECTS= jpegtran.o rdswitch.o cdjpeg.o

COFS= cjpeg.cof djpeg.cof jpegtran.cof rdjpgcom.cof wrjpgcom.cof

default: libjpeg.a

all: libjpeg.a $(COFS)

# Compiler bug workaround; fails on this file with -O2 optimization
jdcoefct.o: jdcoefct.c
	$(CC) -c $(VML_INCLUDE_PATH) -Wall -O1 -o $@ $<

libjpeg.a: $(LIBOBJECTS)
	-$(RM) libjpeg.a
	$(AR) rs libjpeg.a  $(LIBOBJECTS)

cjpeg.cof: $(COBJECTS) libjpeg.a
	$(LN) $(LDFLAGS) -o cjpeg.cof $(COBJECTS) -ljpeg $(LDLIBS)

djpeg.cof: $(DOBJECTS) libjpeg.a
	$(LN) $(LDFLAGS) -o djpeg.cof $(DOBJECTS) -ljpeg $(LDLIBS)

jpegtran.cof: $(TROBJECTS) libjpeg.a
	$(LN) $(LDFLAGS) -o jpegtran.cof $(TROBJECTS) -ljpeg $(LDLIBS)

rdjpgcom.cof: rdjpgcom.o
	$(LN) $(LDFLAGS) -o rdjpgcom.cof rdjpgcom.o $(LDLIBS)

wrjpgcom.cof: wrjpgcom.o
	$(LN) $(LDFLAGS) -o wrjpgcom.cof wrjpgcom.o $(LDLIBS)

jconfig.h: jconfig.doc
	echo You must prepare a system-dependent jconfig.h file.
	echo Please read the installation directions in install.doc.
	exit 1

test: cjpeg djpeg jpegtran
	$(RM) testout*
	./djpeg -dct int -ppm -outfile testout.ppm  testorig.jpg
	./djpeg -dct int -gif -outfile testout.gif  testorig.jpg
	./cjpeg -dct int -outfile testout.jpg  testimg.ppm
	./djpeg -dct int -ppm -outfile testoutp.ppm testprog.jpg
	./cjpeg -dct int -progressive -opt -outfile testoutp.jpg testimg.ppm
	./jpegtran -outfile testoutt.jpg testprog.jpg
	cmp testimg.ppm testout.ppm
	cmp testimg.gif testout.gif
	cmp testimg.jpg testout.jpg
	cmp testimg.ppm testoutp.ppm
	cmp testimgp.jpg testoutp.jpg
	cmp testorig.jpg testoutt.jpg


jcapimin.o: jcapimin.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcapistd.o: jcapistd.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jccoefct.o: jccoefct.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jccolor.o: jccolor.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcdctmgr.o: jcdctmgr.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jchuff.o: jchuff.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jchuff.h
jcinit.o: jcinit.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcmainct.o: jcmainct.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcmarker.o: jcmarker.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcmaster.o: jcmaster.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcomapi.o: jcomapi.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcparam.o: jcparam.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcphuff.o: jcphuff.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jchuff.h
jcprepct.o: jcprepct.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jcsample.o: jcsample.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jctrans.o: jctrans.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdapimin.o: jdapimin.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdapistd.o: jdapistd.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdatadst.o: jdatadst.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h
jdatasrc.o: jdatasrc.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h
jdcoefct.o: jdcoefct.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdcolor.o: jdcolor.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jddctmgr.o: jddctmgr.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jdhuff.o: jdhuff.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdhuff.h
jdinput.o: jdinput.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdmainct.o: jdmainct.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdmarker.o: jdmarker.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdmaster.o: jdmaster.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdmerge.o: jdmerge.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdphuff.o: jdphuff.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdhuff.h
jdpostct.o: jdpostct.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdsample.o: jdsample.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jdtrans.o: jdtrans.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jerror.o: jerror.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jversion.h jerror.h
jfdctflt.o: jfdctflt.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jfdctfst.o: jfdctfst.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jfdctint.o: jfdctint.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jidctflt.o: jidctflt.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jidctfst.o: jidctfst.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jidctint.o: jidctint.s jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jidctred.o: jidctred.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jdct.h
jquant1.o: jquant1.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jquant2.o: jquant2.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jutils.o: jutils.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h
jmemmgr.o: jmemmgr.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jmemsys.h
jmemansi.o: jmemansi.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jmemsys.h
jmemname.o: jmemname.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jmemsys.h
jmemnobs.o: jmemnobs.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jmemsys.h
jmemdos.o: jmemdos.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jmemsys.h
jmemmac.o: jmemmac.c jinclude.h jconfig.h jpeglib.h jmorecfg.h jpegint.h jerror.h jmemsys.h
cjpeg.o: cjpeg.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h jversion.h
djpeg.o: djpeg.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h jversion.h
jpegtran.o: jpegtran.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h jversion.h
cdjpeg.o: cdjpeg.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
rdcolmap.o: rdcolmap.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
rdswitch.o: rdswitch.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
rdjpgcom.o: rdjpgcom.c jinclude.h jconfig.h
wrjpgcom.o: wrjpgcom.c jinclude.h jconfig.h
rdppm.o: rdppm.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
wrppm.o: wrppm.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
rdgif.o: rdgif.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
wrgif.o: wrgif.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
rdtarga.o: rdtarga.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
wrtarga.o: wrtarga.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
rdbmp.o: rdbmp.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
wrbmp.o: wrbmp.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
rdrle.o: rdrle.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h
wrrle.o: wrrle.c cdjpeg.h jinclude.h jconfig.h jpeglib.h jmorecfg.h jerror.h cderror.h

	
install:
	@-$(MKDIR) $(SDK_INCLUDE)
	@-$(MKDIR) $(SDK_LIB)
	
	$(CP) $(RELEASE_HDRS) $(SDK_INCLUDE)
	$(CP) $(RELEASE_LIBS) $(SDK_LIB)
export:
	@echo Nothing to export from JPEG.

includes:
	@-$(MKDIR) $(RELEASE_DIR)/include/jpeg
	$(CP) $(RELEASE_HDRS) $(RELEASE_DIR)/include/jpeg

src:	
	@-$(MKDIR) $(RELEASE_DIR)/lib/src/jpeg
	$(CP) $(RELEASE_SRCS) $(RELEASE_DIR)/lib/src/jpeg

release: src includes
	@-$(MKDIR) $(RELEASE_DIR)/lib
	$(CP) $(RELEASE_LIBS) $(RELEASE_DIR)/lib

clean:
	-$(RM) libjpeg.a
	-$(RM) *.o
