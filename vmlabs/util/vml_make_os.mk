# Copyright (c) 1996-2001 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
# These materials may be used or reproduced solely under
# an express written license from VM Labs, Inc.

# $Id: vml_make_os.mk,v 1.2 2001/03/09 01:01:50 lreeber Exp $


#------------------------------------------------------------------------------

ifndef VML_MAKE_OS_MK

# look to see if we're using a local file already
ifdef VMLABS_LOCAL
    ifneq ($(wildcard $(VMLABS_LOCAL)/util/vml_make_os.mk),)
        ifeq ($(VML_MAKE_OS_LOCAL),yes)
                # already included, don't do it again
            VML_MAKE_OS_LOCAL := no
        else
            VML_MAKE_OS_LOCAL := yes
        endif
    else
            # not there, don't include
        VML_MAKE_OS_LOCAL := no
    endif
else
        # no VMLABS_LOCAL, don't include
    VML_MAKE_OS_LOCAL := no
endif

ifeq ($(VML_MAKE_OS_LOCAL),yes)

include $(VMLABS_LOCAL)/util/vml_make_os.mk

else	# use the stuff in this file

VML_MAKE_OS_MK = 1

ifeq ($(OSTYPE),Linux)
     BUILDHOST := LINUX
endif

ifeq ($(OSTYPE),linux)
     BUILDHOST := LINUX
endif

ifeq ($(OSTYPE),linux-gnu)
     BUILDHOST := LINUX
endif

ifeq ($(OSTYPE),LINUX)
     BUILDHOST := LINUX
endif

ifneq ($(BUILDHOST),LINUX)
ifeq ($(SHTYPE),mks)
    BUILDHOST := MKS
else
ifeq ($(OS),Windows_NT)
    BUILDHOST := WINDOWS_NT
# Windows_NT means both NT and Win20000 <- I hope Windows isn't around that long ;-) AB
else
    BUILDHOST = WIN98
endif
endif
endif

ifeq ($(origin BUILDHOST),undefined)
    $(error DANGER WILL ROBINSON!!  MY SENSORS DETECT A STRANGE OS!!)
endif


endif	# VML_MAKE_OS_LOCAL

endif	# VML_MAKE_OS_MK

