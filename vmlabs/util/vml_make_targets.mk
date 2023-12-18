# Copyright (c) 1996-2000 VM Labs, Inc. All rights reserved.
# Confidential and Proprietary Information of VM Labs, Inc.
# These materials may be used or reproduced solely under
# an express written license from VM Labs, Inc.

# $Id: vml_make_targets.mk,v 1.25 2001/01/25 20:21:16 cheiny Exp $

ifndef VML_MAKE_TARGETS_MK

# look to see if we're using a local file already
ifdef	VMLABS_LOCAL
    ifneq ($(wildcard $(VMLABS_LOCAL)/util/vml_make_targets.mk),)
        ifeq ($(VML_MAKE_TARGETS_LOCAL),yes)
                # already included, don't do it again
            VML_MAKE_TARGETS_LOCAL:=no
        else
            VML_MAKE_TARGETS_LOCAL:=yes
        endif
    else
        VML_MAKE_TARGETS_LOCAL:=no
    endif
else
    VML_MAKE_TARGETS_LOCAL:=no
endif

ifeq ($(VML_MAKE_TARGETS_LOCAL),yes)
    include $(VMLABS_LOCAL)/util/vml_make_targets.mk
else
        # use the stuff in this file
    VML_MAKE_TARGETS_MK=1

ifdef VMLABS_LOCAL
    VML_INCLUDE_PATH = -I$(VMLABS_LOCAL)/include -I$(VMLABS)/include
    VML_LIB_PATH = -L$(VMLABS_LOCAL)/lib -L$(VMLABS)/lib
else
    VML_INCLUDE_PATH = -I$(VMLABS)/include
    VML_LIB_PATH = -L$(VMLABS)/lib
endif

ifndef ARFLAGS
    ARFLAGS = crs
endif

ifndef ASFLAGS
    ASFLAGS = -nologo -fcoff -c
endif

ifndef LDFLAGS
ifndef NO_DEFAULT_LDFLAGS
    LDFLAGS = -mrom -mpe3
endif
endif

ifndef CFLAGS
    CFLAGS = -Wall
endif

ifndef CXXFLAGS
    CXXFLAGS = -Wall
endif

ifndef OBJDIR
    OBJDIR = .
else
    OBJDEP = $(OBJDIR)
endif

ifndef MAKE_VERBOSITY
    COF_ECHO = @echo $(CC) $(LOCAL_LDFLAGS) $(VML_LIB_PATH) $(LDFLAGS) $^ $(LOCAL_LIBS) $(LDLIBS) -o $@
    LIB_ECHO = @echo $(AR) $(LOCAL_ARFLAGS) $(ARFLAGS) $@ $^
    DEP_ECHO =
    AS_ECHO =
    C_ECHO =
    CXX_ECHO =
    QUIET_ECHO =
    QUIET_ME =
else
ifeq ($(MAKE_VERBOSITY), quiet)
    COF_ECHO = @echo link - $@
    LIB_ECHO = @echo lib - $@
    QUIET_ME = @
    QUIET_ECHO = @echo $@
    DEP_ECHO = @echo d - $@
    AS_ECHO = @echo s - $@
    C_ECHO = @echo c - $@
    CXX_ECHO = @echo c++ - $@
endif
ifeq ($(MAKE_VERBOSITY), silent)
    QUIET_ME = @
    QUIET_ECHO =
    LIB_ECHO =
    COF_ECHO =
    DEP_ECHO =
    AS_ECHO =
    C_ECHO =
    CXX_ECHO =
endif
endif


$(OBJDIR)/%.o : %.s $(OBJDEP)
	$(AS_ECHO)
	$(QUIET_ME)$(AS) $(LOCAL_ASFLAGS) $(LOCAL_INCLUDE_PATH) $(VML_INCLUDE_PATH) $(ASFLAGS) -o $@ $<
$(OBJDIR)/%.o : %.c $(OBJDEP) 
	$(C_ECHO)
	$(QUIET_ME)$(CC) -c $(LOCAL_CFLAGS) $(LOCAL_INCLUDE_PATH) $(VML_INCLUDE_PATH) $(CFLAGS) $(CPPFLAGS) -o $@ $<
$(OBJDIR)/%.o : %.cpp $(OBJDEP)
	$(CXX_ECHO)
	$(QUIET_ME)$(CXX) -c $(LOCAL_CXXFLAGS) $(LOCAL_INCLUDE_PATH) $(VML_INCLUDE_PATH) $(CXXFLAGS) $(CPPFLAGS) -o $@ $< 
$(OBJDIR)/%.o : %.cc $(OBJDEP)
	$(CXX_ECHO)
	$(QUIET_ME)$(CXX) -c $(LOCAL_CXXFLAGS) $(LOCAL_INCLUDE_PATH) $(VML_INCLUDE_PATH) $(CXXFLAGS) $(CPPFLAGS) -o $@ $<
$(OBJDIR)/%.d:	%.s $(OBJDEP)
	$(DEP_ECHO)
	$(QUIET_ME)$(AS) -M $(LOCAL_ASFLAGS) $(LOCAL_INCLUDE_PATH) $(VML_INCLUDE_PATH) $(ASFLAGS) -o $*.o $< | $(SED) -e 's@^.*\.o:@$(OBJDIR)/$*.o $@ : @g' -e 's@\\\([^$$]\)@/\1@g' > $(subst /,$(SEP),$@)
$(OBJDIR)/%.d:	%.c $(OBJDEP)
	$(DEP_ECHO)
	$(QUIET_ME)$(CC) -M -MG $(LOCAL_CFLAGS) $(LOCAL_INCLUDE_PATH) $(VML_INCLUDE_PATH) $(CFLAGS) $(CPPFLAGS) $< | $(SED) -e 's@^.*\.o:@$(OBJDIR)/$*.o $@ : @g' -e 's@\\\([^$$]\)@/\1@g' > $(subst /,$(SEP),$@)
$(OBJDIR)/%.d : %.cpp $(OBJDEP)
	$(CXX_ECHO)
	$(QUIET_ME)$(CXX) -M -MG $(LOCAL_CXXFLAGS) $(LOCAL_INCLUDE_PATH) $(VML_INCLUDE_PATH) $(CXXFLAGS) $(CPPFLAGS) $< | $(SED) -e 's@^.*\.o:@$(OBJDIR)/$*.o $@ : @g' -e 's@\\\([^$$]\)@/\1@g' > $(subst /,$(SEP),$@)
$(OBJDIR)/%.d : %.cc $(OBJDEP)
	$(CXX_ECHO)
	$(QUIET_ME)$(CXX) -M -MG $(LOCAL_CXXFLAGS) $(LOCAL_INCLUDE_PATH) $(VML_INCLUDE_PATH) $(CXXFLAGS) $(CPPFLAGS) $< | $(SED) -e 's@^.*\.o:@$(OBJDIR)/$*.o $@ : @g' -e 's@\\\([^$$]\)@/\1@g' > $(subst /,$(SEP),$@)


define makecof
	$(COF_ECHO) 
	@$(CC) $(LOCAL_LDFLAGS) $(LOCAL_LIB_PATH) $(VML_LIB_PATH) $(LDFLAGS) $^ $(LOCAL_LIBS) $(LDLIBS) -o $@ 
endef

define makelib
	$(LIB_ECHO)
	@$(AR) $(LOCAL_ARFLAGS) $(ARFLAGS) $@ $?
endef

#dummy target to complain if the user forgets to specify any targets of their own
.PHONY: no-target
no-target:
	@$(ECHO) You have failed to define any targets in your makefile.
	@exit -1

# handy rule for creating export directories
EXPORT_NAMES = lib bin include doc
.PHONY: export-dirs
export-dirs:
	$(QUIET_ME)$(MKDIR) $(VML_EXPORTDIR)/lib
	$(QUIET_ME)$(MKDIR) $(VML_EXPORTDIR)/bin
	$(QUIET_ME)$(MKDIR) $(VML_EXPORTDIR)/include
	$(QUIET_ME)$(MKDIR) $(VML_EXPORTDIR)/doc

#rule to print sdk release info
.PHONY: sdkrelease
sdkrelease:
	@$(ECHO) info: $(SDK_RELEASE_INFO)
	@$(ECHO) version: $(SDK_VERSION)

include $(VMLABS)/util/vml_make_clean.mk

endif # VML_MAKE_TARGETS_LOCAL

endif # VML_MAKE_TARGETS_MK

