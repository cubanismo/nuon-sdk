# general rule for directory cleaning

# Copyright (c) 1996-2001 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
# These materials may be used or reproduced solely under
# an express written license from VM Labs, Inc.

# $Id: vml_make_clean.mk,v 1.4 2001/02/05 19:04:05 lreeber Exp $

ifndef VML_MAKE_CLEAN_MK

# look to see if we're using a local file already
ifdef	VMLABS_LOCAL
    ifneq ($(wildcard $(VMLABS_LOCAL)/util/vml_make_clean.mk),)
        ifeq ($(VML_MAKE_CLEAN_LOCAL),yes)
                # already included, don't do it again
            VML_MAKE_CLEAN_LOCAL:=no
        else
            VML_MAKE_CLEAN_LOCAL:=yes
        endif
    else
        VML_MAKE_CLEAN_LOCAL:=no
    endif
else
    VML_MAKE_CLEAN_LOCAL:=no
endif

ifeq ($(VML_MAKE_CLEAN_LOCAL),yes)
    include $(VMLABS_LOCAL)/util/vml_make_clean.mk
else
        # use the stuff in this file
    VML_MAKE_CLEAN_MK=1

ifndef OBJDIR
    OBJDIR = .
endif

ifndef MAKE_VERBOSITY
    CLEAN_ECHO =
    CLEAN_QUIET =
else
ifeq ($(MAKE_VERBOSITY), quiet)
    CLEAN_QUIET = @
    CLEAN_ECHO = @echo $@
endif
ifeq ($(MAKE_VERBOSITY), silent)
    CLEAN_QUIET = @
    CLEAN_ECHO =
endif
endif

ifndef NO_DEFAULT_CLEAN
    NO_DEFAULT_CLEAN = no
endif

ifneq ($(NO_DEFAULT_CLEAN),yes)

ifdef LOCAL_CLEAN_FILES
    ifneq ($(LOCAL_CLEAN_FILES),"")
        VML_CLEAN = $(LOCAL_CLEAN_FILES)
    endif
endif

ifdef CLEAN_LIBS
    ifneq ($(CLEAN_LIBS),"")
        VML_CLEAN += $(CLEAN_LIBS)
    endif
else
    VML_CLEAN += $(wildcard $(OBJDIR)/*.a)
    VML_CLEAN += $(wildcard $(OBJDIR)/*.lib)
endif

ifdef CLEAN_DEPS
    ifneq ($(CLEAN_DEPS),"")
        VML_CLEAN += $(CLEAN_DEPS)
    endif
else
    VML_CLEAN += $(wildcard $(OBJDIR)/*.d)
endif

ifdef CLEAN_OBJS
    ifneq ($(CLEAN_OBJS),"")
        VML_CLEAN += $(CLEAN_OBJS)
    endif
else
    VML_CLEAN += $(wildcard $(OBJDIR)/*.o)
    VML_CLEAN += $(wildcard $(OBJDIR)/*.obj)
endif

ifdef CLEAN_COFS
    ifneq ($(CLEAN_COFS),"")
        VML_CLEAN += $(CLEAN_COFS)
    endif
else
    VML_CLEAN += $(wildcard $(OBJDIR)/*.cof)
endif

ifdef CLEAN_EXES
    ifneq ($(CLEAN_EXES),"")
        VML_CLEAN += $(CLEAN_EXES)
    endif
else
    VML_CLEAN += $(wildcard $(OBJDIR)/*.exe)
endif

ifdef CLEAN_DLLS
    ifneq ($(CLEAN_DLLS),"")
        VML_CLEAN += $(CLEAN_DLLS)
    endif
else
    VML_CLEAN += $(wildcard $(OBJDIR)/*.dll)
endif

ifdef CLEAN_EXPORTS
    ifneq ($(CLEAN_EXPORTS),"")
        VML_CLEAN += $(CLEAN_EXPORTS)
    endif
else
    ifneq ($(wildcard $(VML_EXPORTDIR)),)
        VML_CLEAN += $(VML_EXPORTDIR)
    endif
endif

ifeq ($(strip $(VML_CLEAN)),)
    CLEAN_COMMAND = @echo Nothing to clean in this directory.
else
    CLEAN_COMMAND = $(CLEAN_QUIET)$(RMEX) $(VML_CLEAN)
endif

VML_CLEAN_DEPS = $(LOCAL_CLEAN)
ifneq ($(strip $(COMPONENTS)),)
    VML_CLEAN_DEPS += clean-components

.PHONY: clean-components
%.comp-clean:
	@$(MAKE) -C $(*F) clean

clean-components: $(foreach dir,$(COMPONENTS),$(dir).comp-clean)

endif

.PHONY: clean
clean: $(VML_CLEAN_DEPS)
	$(CLEAN_COMMAND)

endif

# general rule for total directory demolition

.PHONY: clobber
clobber: $(LOCAL_CLOBBER)
	$(RMDIR) *

endif # VML_MAKE_TARGETS_LOCAL

endif # VML_MAKE_TARGETS_MK