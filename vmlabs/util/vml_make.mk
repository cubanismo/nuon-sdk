# Copyright (c) 1996-2000 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
# These materials may be used or reproduced solely under
# an express written license from VM Labs, Inc.

# $Id: vml_make.mk,v 1.25 2001/04/12 19:57:33 lreeber Exp $


#------------------------------------------------------------------------------

ifndef VML_MAKE_MK

# look to see if we're using a local file already
ifdef VMLABS_LOCAL
    ifneq ($(wildcard $(VMLABS_LOCAL)/util/vml_make.mk),)
        ifeq ($(VML_MAKE_LOCAL),yes)
                # already included, don't do it again
            VML_MAKE_LOCAL := no
        else
            VML_MAKE_LOCAL := yes
        endif
    else
            # not there, don't include
        VML_MAKE_LOCAL := no
    endif
else
        # no VMLABS_LOCAL, don't include
    VML_MAKE_LOCAL := no
endif

ifeq ($(VML_MAKE_LOCAL),yes)

include $(VMLABS_LOCAL)/util/vml_make.mk

else	# use the stuff in this file

VML_MAKE_MK = 1

include $(VMLABS)/util/vml_make_os.mk

ifdef VMLABS_LOCAL
	INCLUDE_DIRS += -I$(VMLABS_LOCAL)/include -I$(VMLABS_LOCAL)/include/nuon
endif


#------------------------------------------------------------------------------
AS = llama 
ASFLAGS = -fcoff -nologo -c
CC = mgcc
AR = vmar
LD = vmld
CXX = mgcc
SED = sed
ECHO = echo


#------------------------------------------------------------------------------
VML_EXPORTDIR = export


#------------------------------------------------------------------------------
ifeq ($(BUILDHOST),WINDOWS_NT)
	ROOT := $(VMLABS)
	MKDIR = mkdir -p
	RMDIR = rm -rf
	RM    = rm
	RMEX  = rm -r -f
	SEP   = /#
	ISEP  = /#
	CLS   = cls
	CP    = cp
	MV    = mv
	DIFF  = diff
	AWK   = gawk
	define WAITKEY
		echo Press CONTROL-C to abort now or
		echo Press Enter to continue
		read
	endef
endif

ifeq ($(BUILDHOST),WIN98)
	ROOT := $(VMLABS)
	MKDIR = mkdir -p 
	RMDIR = rm -rf
	RM    = rm -f
	RMEX  = rm -r -f
	SEP   = /#
	ISEP  = /#
	CLS   = cls
	CP    = cp
	MV    = mv
	DIFF  = diff
	AWK   = gawk
	define WAITKEY
		echo Press CONTROL-C to abort now or
		echo Press Enter to continue
		read
	endef
endif

ifeq ($(BUILDHOST),MKS)
	ROOT := $(VMLABS)
	MKDIR = mkdir -p 
	RMDIR = rm -rf
	RM    = rm -f
	RMEX  = rm -r -f
	SEP   = /#
	ISEP  = /#
	CLS   = clear
	CP    = cp
	MV    = mv
	DIFF  = diff
	AWK   = awk
	define WAITKEY
		echo Press CONTROL-C to abort now or
		echo Press Enter to continue
		read
	endef
endif

ifeq ($(BUILDHOST),LINUX)
	ROOT := /usr/local/merlin-local
	MKDIR = mkdir -p
	RMDIR = rm -rf
	RM    = rm -f
	RMEX  = rm -r -f
	SEP   = /#
	ISEP  = /#
	CLS   = clear
	CP    = cp
	MV    = mv
	DIFF  = diff
	AWK   = awk
	define WAITKEY
		echo Press CONTROL-C to abort now or
		echo Press Enter to continue
		read
	endef
endif


# -- define the installation directory
ifdef	VMLABS_LOCAL
	INSTALL_ROOT = $(VMLABS_LOCAL)
else
	INSTALL_ROOT = $(VMLABS)
endif
INSTALL_DIR = $(INSTALL_ROOT)


# just what SDK release are we using?
ifndef	SDK_VERSION
    SDK_VERSION := $(shell cat $(VMLABS)/releaseNumber.txt)
endif
SDK_RELEASE_INFO := VMLabs SDK $(SDK_VERSION)
# note: we will eventually want this to include other info, like "(Internal)", "Game", "Hybrid" and so on.
# convenience quoting for passing to C
QUOTED_VERSION := -DSDK_VERSION="\"$(SDK_VERSION)\""
QUOTED_RELEASE_INFO := -DSDK_RELEASE_INFO="\"$(SDK_RELEASE_INFO)\""


endif	# VML_MAKE_LOCAL

endif	# VML_MAKE_MK

