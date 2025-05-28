# Slightly adapted for config-ng "Generic Build script for CC65"
#
# This file is only responsible for compiling source code.
# It has some hooks for additional behaviour, see Additional Make Files below.
#
# The compilation will look in following directories for source:
#
#   src/*.[c|s]               # considered the "top level" dir, you can keep everything in here if you like, will not recurse into subdirs
#   src/common/**/*.[c|s]     # ie. common files for all platforms not in root dir - allows for splitting functionality out into subdirs

# IN CONFIG-NG THIS IS NOT INCLUDED:
#   src/<target>/**/*.[c|s]   # ie. including its subdirs - only CURRENT_TARGET files will be found

# INSTEAD THERE IS A common AND SUBTARGET FOLDERS
# This is to allow "full" vs "lite" builds, yet still allow common code for a platform between all subtargets
#
#   src/<target>/common/**/*.[c|s]
#   src/<target>/<sub-target>/**/*.[c|s]
#
# Additional Make Files
#  This script sources the following files to add additional behaviour.
#    makefiles/os.mk                 # for platform mappings (e.g. atarixl -> atari, apple2enh -> apple), emulator base settings
#    makefiles/common.mk             # for things to be added for all platforms
#    makefiles/custom-<platform>.mk  # for platform specific values, LDFLAGS etc for current PLATFORM (e.g. atari)
#
# Additional notes:
#
# - To add additional tasks to "all", in the sourced makefiles, add a value to "ALL_TASKS"
# - For creating platform specific DISK images, add the disk creating task to "DISK_TASKS"
# - Additional tasks in these makefiles MUST start with a ".", e.g. .atr, .po, .your-complex-rule
# - To add a suffix to the generated executable, ensure "SUFFIX" variable is set in your platform specific makefile.
# - All files referenced in this makefile are relative to the ORIGINAL Makefile in the root dir, not this dir

# Ensure WSL2 Ubuntu and other linuxes use bash by default instead of /bin/sh, which does not always like the shell commands.
SHELL := /usr/bin/env bash
ALL_TASKS = unit-test
DISK_TASKS =

# split "atari.full" or "atari.lite" into "atari" and appropriate sub-target
CURRENT_TARGET := $(firstword $(subst ., ,$(CURRENT_TARGET_LONG)))
SUBTARGET := $(word 2,$(subst ., ,$(CURRENT_TARGET_LONG)))

-include makefiles/os.mk

CC := cl65

SRCDIR := src
BUILD_DIR := build
OBJDIR := obj
DIST_DIR := dist
CACHE_DIR := ./_cache

# This allows src to be nested within sub-directories.
rwildcard=$(wildcard $(1)$(2))$(foreach d,$(wildcard $1*), $(call rwildcard,$d/,$2))

PROGRAM_TGT := $(PROGRAM).$(CURRENT_TARGET_LONG)

SOURCES := $(wildcard $(SRCDIR)/*.c)
SOURCES += $(wildcard $(SRCDIR)/*.s)

# allow for a src/common/ dir and recursive subdirs
SOURCES += $(call rwildcard,$(SRCDIR)/common/,*.s)
SOURCES += $(call rwildcard,$(SRCDIR)/common/,*.c)

# allow src/<target>/ and its recursive subdirs
SOURCES_TG := $(call rwildcard,$(SRCDIR)/$(CURRENT_TARGET)/common/,*.s)
SOURCES_TG += $(call rwildcard,$(SRCDIR)/$(CURRENT_TARGET)/common/,*.c)

ifneq "$(SUBTARGET)" ""
SOURCES_TG += $(call rwildcard,$(SRCDIR)/$(CURRENT_TARGET)/$(SUBTARGET)/,*.s)
SOURCES_TG += $(call rwildcard,$(SRCDIR)/$(CURRENT_TARGET)/$(SUBTARGET)/,*.c)
endif

# remove trailing and leading spaces.
SOURCES := $(strip $(SOURCES))
SOURCES_TG := $(strip $(SOURCES_TG))

# convert from src/your/long/path/foo.[c|s] to obj/your/long/path/foo.o
OBJ1 := $(SOURCES:.c=.o)
OBJECTS := $(OBJ1:.s=.o)
OBJECTS := $(OBJECTS:$(SRCDIR)/%=$(OBJDIR)/%)

OBJ2 := $(SOURCES_TG:.c=.o)
OBJECTS_TG := $(OBJ2:.s=.o)
OBJECTS_TG := $(OBJECTS_TG:$(SRCDIR)/%=$(OBJDIR)/%)

OBJECTS += $(OBJECTS_TG)

# Ensure make recompiles parts it needs to if src files change
DEPENDS := $(OBJECTS:.o=.d)

ASFLAGS += --asm-include-dir src/common/inc
ASFLAGS += --asm-include-dir src/$(CURRENT_TARGET)/common/inc

CFLAGS += --include-dir src/common/inc
CFLAGS += --include-dir src/$(CURRENT_TARGET)/common/inc

ifneq "$(SUBTARGET)" ""
ASFLAGS += --asm-include-dir src/$(CURRENT_TARGET)/$(SUBTARGET)/inc
CFLAGS += --include-dir src/$(CURRENT_TARGET)/$(SUBTARGET)/inc
endif

ASFLAGS += --asm-include-dir $(SRCDIR)
CFLAGS += --include-dir $(SRCDIR)

# allow for additional flags etc
-include ./makefiles/common.mk
-include ./makefiles/custom-$(CURRENT_PLATFORM).mk

# allow for application specific config
-include ./application.mk

define _listing_
  CFLAGS += --listing $$(@:.o=.lst)
  ASFLAGS += --listing $$(@:.o=.lst)
endef

define _mapfile_
  LDFLAGS += --mapfile $$@.map
endef

define _labelfile_
  LDFLAGS += -Ln $$@.lbl
endef


STATEFILE := Makefile.options
-include $(DEPENDS)
-include $(STATEFILE)

ifeq ($(origin _OPTIONS_),file)
OPTIONS = $(_OPTIONS_)
$(eval $(OBJECTS): $(STATEFILE))
endif

# Transform the abstract OPTIONS to the actual cc65 options.
$(foreach o,$(subst $(COMMA),$(SPACE),$(OPTIONS)),$(eval $(_$o_)))

ifeq ($(BUILD_DIR),)
BUILD_DIR := build
endif

ifeq ($(OBJDIR),)
OBJDIR := obj
endif

ifeq ($(DIST_DIR),)
DIST_DIR := dist
endif

.SUFFIXES:
.PHONY: all clean release $(DISK_TASKS) $(BUILD_TASKS) $(PROGRAM_TGT)

all: $(ALL_TASKS) $(PROGRAM_TGT)


$(OBJDIR):
	$(call MKDIR,$@)

$(BUILD_DIR):
	$(call MKDIR,$@)

$(DIST_DIR):
	$(call MKDIR,$@)

SRC_INC_DIRS := \
  $(sort $(dir $(wildcard $(SRCDIR)/$(CURRENT_TARGET)/common/*))) \
  $(sort $(dir $(wildcard $(SRCDIR)/common/*))) \
  $(SRCDIR)

ifneq "$(SUBTARGET)" ""
SRC_INC_DIRS += $(sort $(dir $(wildcard $(SRCDIR)/$(CURRENT_TARGET)/$(SUBTARGET)/*)))
endif

vpath %.c $(SRC_INC_DIRS)

$(OBJDIR)/%.o: %.c $(VERSION_FILE) | $(OBJDIR)
	@$(call MKDIR,$(dir $@))
	$(CC) -t $(CURRENT_TARGET) -c --create-dep $(@:.o=.d) $(CFLAGS) -o $@ $<

vpath %.s $(SRC_INC_DIRS)

$(OBJDIR)/%.o: %.s $(VERSION_FILE) | $(OBJDIR)
	@$(call MKDIR,$(dir $@))
	$(CC) -t $(CURRENT_TARGET) -c --create-dep $(@:.o=.d) $(ASFLAGS) -o $@ $<


$(BUILD_DIR)/$(PROGRAM_TGT): $(OBJECTS) $(LIBS) | $(BUILD_DIR)
	$(CC) -t $(CURRENT_TARGET) $(LDFLAGS) -o $@ $^

$(PROGRAM_TGT): $(BUILD_DIR)/$(PROGRAM_TGT) | $(BUILD_DIR)

test: $(PROGRAM_TGT) release
	$(PREEMUCMD)
	$(EMUCMD) $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX)
	$(POSTEMUCMD)

test-disk: disk
	$(PREEMUCMD)
	$(EMUCMD) $(DISK_FILE)
	$(POSTEMUCMD)

test-diskz: diskz
	$(PREEMUCMD)
	$(EMUCMD) $(DISKZ_FILE)
	$(POSTEMUCMD)

# Use "./" in front of all dirs being removed as a simple safety guard to ensure deleting from current dir, and not something like root "/".
clean:
	@for d in $(BUILD_DIR) $(OBJDIR) $(DIST_DIR); do \
      if [ -d "./$$d" ]; then \
	    echo "Removing $$d"; \
        rm -rf ./$$d; \
      fi; \
    done

release: all | $(BUILD_DIR) $(DIST_DIR)
	cp $(BUILD_DIR)/$(PROGRAM_TGT) $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX)

disk: release $(DISK_TASKS)

diskz: release $(DISKZ_TASKS)
