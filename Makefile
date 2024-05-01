# Adapted from the generic cc65 makefile.
# Notible exceptions:
# - recursive dirs for src
# - subtargets based on variants, but share common directory for src rather than expecting duplication or src
#   This means output goes to obj/atari/* rather than obj/atari.full/*, with obj/atari/common/* containing the shared code between variants
# - altirra instead of atari800 for emulation, needs some work on the lbl file name.
# - cfg/*.cfg file instead of finding one in the src dir
# - final files go into build/ directory instead of polluting root folder (e.g. lbl, com file etc)

TARGETS := atari.full

FUJINET_LIB_VERSION = 3.0.1
FUJINET_LIB = fujinet-lib
FUJINET_LIB_VERSION_DIR = $(FUJINET_LIB)/$(FUJINET_LIB_VERSION)-$(CC65TARGET)

PROGRAM := config
LIBS    :=
CONFIG  :=
CFLAGS  =
ASFLAGS =
LDFLAGS =
SRCDIR := src
OBJDIR := obj
EMUCMD :=
BUILD_DIR = build
PREEMUCMD :=
POSTEMUCMD :=
STATEFILE := Makefile.options

# Compiler flags used to tell the compiler to optimise for SPEED
define _optspeed_
  CFLAGS += -Oris
endef

# Compiler flags used to tell the compiler to optimise for SIZE
define _optsize_
  CFLAGS += -Or
endef

# Compiler and assembler flags for generating listings
define _listing_
  CFLAGS += --listing $$(@:.o=.lst)
  ASFLAGS += --listing $$(@:.o=.lst)
  REMOVES += $(addsuffix .lst,$(basename $(OBJECTS)))
endef

# Linker flags for generating map file
define _mapfile_
  LDFLAGS += --mapfile $(BUILD_DIR)/$$@.map
  REMOVES += $(BUILD_DIR)/$(PROGRAM).map
endef

# Linker flags for generating VICE label file
define _labelfile_
  LDFLAGS += -Ln $(BUILD_DIR)/$$@.lbl
  REMOVES += $(BUILD_DIR)/$(PROGRAM).lbl
endef

# Linker flags for generating a debug file
define _debugfile_
  LDFLAGS += -Wl --dbgfile,$(BUILD_DIR)/$$@.dbg
  REMOVES += $(BUILD_DIR)/$(PROGRAM).dbg
endef

ifeq ($(PROGRAM),)
  PROGRAM := $(notdir $(CURDIR))
endif

TARGETOBJDIR := $(OBJDIR)/$(TARGETS)

# On Windows it is mandatory to have CC65_HOME set. So do not unnecessarily
# rely on cl65 being added to the PATH in this scenario.
ifdef CC65_HOME
  CC := $(CC65_HOME)/bin/cl65
else
  CC := cl65
endif

ifeq '$(findstring ;,$(PATH))' ';'
    detected_OS := Windows
else
    detected_OS := $(shell uname 2>/dev/null || echo Unknown)
    detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
    detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
    detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
endif

XS := ""
ifeq ($(detected_OS),$(filter $(detected_OS),MSYS MINGW))
# need an eXtra Slash for altirra things
	XS := /
endif

LBL_SYM := $(XS)/debugcmd: ".loadsym build\config.$(TARGETS).lbl"

ifeq ($(ALTIRRA_PORTABLE_ALT),)
  # you can override this in your environment with:
  #   export ALTIRRA_ARGS="//portable //portablealt:your-own.ini //debug ... etc"
  # when using MSYS, you must use double slashes, as the first is stripped off and not passed to the application
  ALTIRRA_ARGS := $(XS)/portable $(XS)/portablealt:altirra-debug.ini
else
  ALTIRRA_ARGS := $(XS)/portable $(ALTIRRA_PORTABLE_ALT)
endif

ALTIRRA ?= $(ALTIRRA_HOME)/Altirra64.exe \
  $(ALTIRRA_ARGS) \
  $(XS)/debugcmd: ".tracecio on" \

  # $(XS)/debug $(LBL_SYM)

  # $(XS)/debugcmd: "bp debug" \
  # $(XS)/debugcmd: "bp init_debug" \
  # $(XS)/debugcmd: "bp reset_debug" \
  # $(XS)/debugcmd: "ba w 0x0400" \
  # $(XS)/debugcmd: "ba w 0x0401" \
  # $(XS)/debugcmd: "ba w 0x0402" \
  # $(XS)/debugcmd: "ba w 0x0403" \
  # $(XS)/debugcmd: "ba w 0x0404" \
  # $(XS)/debugcmd: "ba w 0x0405" \
  # $(XS)/debugcmd: "ba r dosini" \
  # $(XS)/debugcmd: "ba w dosini" \
  # $(XS)/debugcmd: "bp start" \
  # $(XS)/debugcmd: "bp _main" \
  # $(XS)/debugcmd: "bp \$$0943" \
  # $(XS)/debugcmd: "bp pre_init" \

atari_EMUCMD := $(ALTIRRA)

ifeq ($(EMUCMD),)
  EMUCMD = $($(CC65TARGET)_EMUCMD)
endif

ifeq ($(shell echo),)
  MKDIR = mkdir -p $1
  RMDIR = rmdir $1
  RMFILES = $(RM) $1
else
  MKDIR = mkdir $(subst /,\,$1)
  RMDIR = rmdir $(subst /,\,$1)
  RMFILES = $(if $1,del /f $(subst /,\,$1))
endif
COMMA := ,
SPACE := $(N/A) $(N/A)
define NEWLINE


endef
# Note: Do not remove any of the two empty lines above !

rwildcard=$(wildcard $(1)$(2))$(foreach d,$(wildcard $1*), $(call rwildcard,$d/,$2))

TARGETLIST := $(subst $(COMMA),$(SPACE),$(TARGETS))

ifeq ($(words $(TARGETLIST)),1)

# Strip potential variant suffix from the actual cc65 target.
CC65TARGET := $(firstword $(subst .,$(SPACE),$(TARGETLIST)))
SUBTARGET := $(word 2,$(subst .,$(SPACE),$(TARGETLIST)))

FUJINET_LIB_DOWNLOAD_URL = https://github.com/FujiNetWIFI/fujinet-lib/releases/download/v$(FUJINET_LIB_VERSION)/fujinet-lib-$(CC65TARGET)-$(FUJINET_LIB_VERSION).zip
FUJINET_LIB_DOWNLOAD_FILE = $(FUJINET_LIB)/fujinet-lib-$(CC65TARGET)-$(FUJINET_LIB_VERSION).zip

# Set PROGRAM to something like 'myprog.c64'.
override PROGRAM := $(PROGRAM).$(TARGETLIST)

# Root dir files
SOURCES := $(wildcard $(SRCDIR)/*.c)
SOURCES += $(wildcard $(SRCDIR)/*.s)

# Recursive files
SOURCES += $(call rwildcard,$(SRCDIR)/common/,*.s)
SOURCES += $(call rwildcard,$(SRCDIR)/common/,*.c)

# keep target/subtarget sources separate so we can compile them to different dir to common code shared between all targets
SOURCES_TG := $(call rwildcard,$(SRCDIR)/$(CC65TARGET)/common/,*.s)
SOURCES_TG += $(call rwildcard,$(SRCDIR)/$(CC65TARGET)/common/,*.c)

ifneq "$(SUBTARGET)" ""
SOURCES_TG += $(call rwildcard,$(SRCDIR)/$(CC65TARGET)/$(SUBTARGET)/,*.s)
SOURCES_TG += $(call rwildcard,$(SRCDIR)/$(CC65TARGET)/$(SUBTARGET)/,*.c)
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

DEPENDS := $(OBJECTS:.o=.d)
DEPENDS += $(OBJECTS_TG:.o=.d)

# Add to LIBS something like 'src/foo.lib src/c64/bar.lib'.
LIBS += $(wildcard $(SRCDIR)/*.lib)
LIBS += $(wildcard $(SRCDIR)/$(CC65TARGET)/*.lib)
LIBS += $(FUJINET_LIB_VERSION_DIR)/fujinet-$(CC65TARGET)-$(FUJINET_LIB_VERSION).lib

CONFIG += cfg/$(TARGETLIST).cfg

# Select CONFIG file to use. Target specific configs have higher priority.
ifneq ($(word 2,$(CONFIG)),)
  CONFIG := $(firstword $(CONFIG))
  $(info Using config file $(CONFIG) for linking)
endif

ASFLAGS += --asm-include-dir src/common/inc --asm-include-dir src/libs/inc --asm-include-dir src/$(CC65TARGET)/common/inc --asm-include-dir $(FUJINET_LIB_VERSION_DIR)
CFLAGS += --include-dir src/common/inc --include-dir src/$(CC65TARGET)/common/inc --include-dir $(FUJINET_LIB_VERSION_DIR)

ifneq "$(SUBTARGET)" ""
ASFLAGS += --asm-include-dir src/$(CC65TARGET)/$(SUBTARGET)/inc
CFLAGS += --include-dir src/$(CC65TARGET)/$(SUBTARGET)/inc
endif

LDFLAGS += -Wl -D__RESERVED_MEMORY__=0x1

.SUFFIXES:
.PHONY: all test clean get_fujinet_lib

all: get_fujinet_lib $(PROGRAM)

-include $(DEPENDS)
-include $(STATEFILE)

# If OPTIONS are given on the command line then save them to STATEFILE
# if (and only if) they have actually changed. But if OPTIONS are not
# given on the command line then load them from STATEFILE. Have object
# files depend on STATEFILE only if it actually exists.
ifeq ($(origin OPTIONS),command line)
  ifneq ($(OPTIONS),$(_OPTIONS_))
    ifeq ($(OPTIONS),)
      $(info Removing OPTIONS)
      $(shell $(RM) $(STATEFILE))
      $(eval $(STATEFILE):)
    else
      $(info Saving OPTIONS=$(OPTIONS))
      $(shell echo _OPTIONS_=$(OPTIONS) > $(STATEFILE))
    endif
    $(eval $(OBJECTS): $(STATEFILE))
  endif
else
  ifeq ($(origin _OPTIONS_),file)
    $(info Using saved OPTIONS=$(_OPTIONS_))
    OPTIONS = $(_OPTIONS_)
    $(eval $(OBJECTS): $(STATEFILE))
  endif
endif

# Transform the abstract OPTIONS to the actual cc65 options.
$(foreach o,$(subst $(COMMA),$(SPACE),$(OPTIONS)),$(eval $(_$o_)))

get_fujinet_lib:
	@if [ ! -f "$(FUJINET_LIB_DOWNLOAD_FILE)" ]; then \
		if [ -d "$(FUJINET_LIB_VERSION_DIR)" ]; then \
		  echo "A directory already exists with version $(FUJINET_LIB_VERSION) - please remove it first"; \
			exit 1; \
		fi; \
		HTTPSTATUS=$$(curl -Is $(FUJINET_LIB_DOWNLOAD_URL) | head -n 1 | awk '{print $$2}'); \
		if [ "$${HTTPSTATUS}" == "404" ]; then \
			echo "ERROR: Unable to find file $(FUJINET_LIB_DOWNLOAD_URL)"; \
			exit 1; \
		fi; \
		echo "Downloading fujinet-lib for $(TARGETLIST) version $(FUJINET_LIB_VERSION) from $(FUJINET_LIB_DOWNLOAD_URL)"; \
		mkdir -p $(FUJINET_LIB); \
		curl -L $(FUJINET_LIB_DOWNLOAD_URL) -o $(FUJINET_LIB_DOWNLOAD_FILE); \
		echo "Unzipping to $(FUJINET_LIB)"; \
		unzip -o $(FUJINET_LIB_DOWNLOAD_FILE) -d $(FUJINET_LIB_VERSION_DIR); \
		echo "Unzip complete."; \
	fi

dist-z: $(PROGRAM)
	@if [ -d "../fujinet-config-loader" ] ; then \
    echo "Found fujinet-config-loader, creating compressed autorun.atr"; \
    $(MAKE) -C ../fujinet-config-loader clean dist CONFIG_TARGET=$$(realpath build/$(PROGRAM)) ; \
    if [ $$? -ne 0 ] ; then \
      echo "ERROR running compressor"; \
      exit 1; \
    fi; \
    cp ../fujinet-config-loader/autorun-zx0.atr ./autorun.atr; \
    echo "Compressed file saved as autorun.atr"; \
  else \
    echo "ERROR: Could not find fujinet-config-loader in sibling directory to current."; \
    exit 1; \
  fi

# The remaining targets.
$(OBJDIR):
	$(call MKDIR,$@)

$(BUILD_DIR):
	$(call MKDIR,$@)

SRC_INC_DIRS := \
  $(sort $(dir $(wildcard $(SRCDIR)/$(CC65TARGET)/common/*))) \
  $(sort $(dir $(wildcard $(SRCDIR)/common/*))) \
  $(sort $(dir $(wildcard $(SRCDIR)/libs/*)))

ifneq "$(SUBTARGET)" ""
SRC_INC_DIRS += $(sort $(dir $(wildcard $(SRCDIR)/$(CC65TARGET)/$(SUBTARGET)/*)))
endif

# $(info $$SOURCES = ${SOURCES})
# $(info $$SOURCES_TG = ${SOURCES_TG})
# $(info $$OBJECTS = ${OBJECTS})
# $(info $$SRC_INC_DIRS = ${SRC_INC_DIRS})
# $(info $$TARGETOBJDIR = ${TARGETOBJDIR})

vpath %.c $(SRC_INC_DIRS) $(SRCDIR)

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	@$(call MKDIR,$(dir $@))
	$(CC) -t $(CC65TARGET) -c --create-dep $(@:.o=.d) $(CFLAGS) -o $@ $<

vpath %.s $(SRC_INC_DIRS) $(SRCDIR)

$(OBJDIR)/%.o: %.s | $(OBJDIR)
	@$(call MKDIR,$(dir $@))
	$(CC) -t $(CC65TARGET) -c --create-dep $(@:.o=.d) $(ASFLAGS) -o $@ $<

$(PROGRAM): $(CONFIG) $(OBJECTS) $(LIBS) | $(BUILD_DIR)
	$(CC) -t $(CC65TARGET) $(LDFLAGS) -o $(BUILD_DIR)/$@ $(patsubst %.cfg,-C %.cfg,$^)

test: $(PROGRAM)
	$(PREEMUCMD) \
	$(EMUCMD) $(BUILD_DIR)\\$< \
	$(POSTEMUCMD)

test-atrz-sd: $(PROGRAM) dist-z
	$(PREEMUCMD) \
  $(EMUCMD) //disk "C:\8bit\atari\tnfsd\atari\dos\SpartaDOS3.2d.atr" //disk autorun.atr \
	$(POSTEMUCMD)

test-atrz: $(PROGRAM) dist-z
	$(PREEMUCMD) \
  $(EMUCMD) //disk autorun.atr \
	$(POSTEMUCMD)

test-atr-sd: $(PROGRAM) dist
	$(PREEMUCMD) \
  $(EMUCMD) //disk "C:\8bit\atari\tnfsd\atari\dos\SpartaDOS3.2d.atr" //disk autorun.atr \
	$(POSTEMUCMD)

test-atr: $(PROGRAM) dist
	$(PREEMUCMD) \
  $(EMUCMD) //disk autorun.atr \
	$(POSTEMUCMD)

#	$(EMUCMD) autorun.atr \

clean:
	$(call RMFILES,$(OBJECTS))
	$(call RMFILES,$(DEPENDS))
	$(call RMFILES,$(REMOVES))
	$(call RMFILES,$(PROGRAM))

# TODO: add the ../fujinet-config-tools/atari/dist/*.com files here?
dist: $(PROGRAM)
	$(call MKDIR,dist/)
	$(call RMFILES,dist/*)
	$(call RMFILES,autorun.atr)
	cp build/$(PROGRAM) dist/config.com
	dir2atr -m -S -B picoboot.bin autorun.atr dist/

else # $(words $(TARGETLIST)),1

all test clean:
	$(foreach t,$(TARGETLIST),$(MAKE) TARGETS=$t $@$(NEWLINE))

endif # $(words $(TARGETLIST)),1


###################################################################
###  Place your additional targets in the additional Makefiles  ###
### in the same directory - their names have to end with ".mk"! ###
###################################################################
-include *.mk