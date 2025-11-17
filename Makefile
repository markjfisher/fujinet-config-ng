PRODUCT = config
PLATFORMS = atari

# You can run 'make <platform>' to build for a specific platform,
# or 'make <platform>/<target>' for a platform-specific target.
# Example shortcuts:
#   make coco        → build for coco
#   make apple2/disk → build the 'disk' target for apple2

# SRC_DIRS may use the literal %PLATFORM% token.
# It expands to the chosen PLATFORM plus any of its combos.
SRC_DIRS = src/**
INCLUDE_DIRS = src/**/inc

# FUJINET_LIB can be
# - a version number such as 4.7.6
# - a directory which contains the libs for each platform
# - a zip file with an archived fujinet-lib
# - a URL to a git repo
# - empty which will use whatever is the latest
# - undefined, no fujinet-lib will be used
FUJINET_LIB = /home/markf/dev/atari/fujinet-lib/build

include makefiles/toplevel-rules.mk

# If you need to add extra platform-specific steps, do it below:
#   coco/r2r:: coco/custom-step1
#   coco/r2r:: coco/custom-step2
# or
#   apple2/disk: apple2/custom-step1 apple2/custom-step2

ATARI_LINKER_CFG = cfg/atari.full.cfg
EXECUTABLE_EXTRA_DEPS_ATARI = $(ATARI_LINKER_CFG)
LDFLAGS_EXTRA_ATARI = -C $(ATARI_LINKER_CFG)

# Unit tests
-include unit-tests.mk

# Emulation
ifeq ($(filter atari/emulate,$(MAKECMDGOALS)),atari/emulate)
include atari-emulator.mk
endif

atari/emulate::
	$(EMUCMD)
