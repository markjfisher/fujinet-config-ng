# Generic CC65 TARGETS makefile++
#
# Set the TARGETS and PROGRAM values as required.
# See makefiles/build.mk for details on directory structure for src files and how to add custom extensions to the build.

TARGETS = atari.full
PROGRAM := config

SUB_TASKS := clean disk diskz test test-disk test-diskz release unit-test
.PHONY: all help $(SUB_TASKS)

all:
	@for target in $(TARGETS); do \
		echo "-------------------------------------"; \
		echo "Building $$target"; \
		echo "-------------------------------------"; \
		$(MAKE) --no-print-directory -f makefiles/build.mk CURRENT_TARGET_LONG=$$target PROGRAM=$(PROGRAM) $(MAKECMDGOALS); \
	done

$(SUB_TASKS): _do_all
$(SUB_TASKS):
	@:

_do_all: all

help:
	@echo "Makefile for $(PROGRAM)"
	@echo ""
	@echo "Available tasks:"
	@echo "all        - do all compilation tasks, create app in build directory"
	@echo "clean      - remove all build artifacts"
	@echo "disk       - generate platform specific disk versions of application (PO/ATR etc)"
	@echo "test       - run application in emulator for given platform."
	@echo "unit-test  - run the soft65c02 unit tests"
	@echo "test-disk  - create and run emulator with disk release"
	@echo "             specific platforms may expose additional variables to run with"
	@echo "             different emulators, see makefiles/custom-<platform>.mk"
	@echo "release    - create a release of the executable in the dist/ dir"
	@echo ""
	@echo "diskz      - create a compressed disk (specific to atari)"
	@echo "test-diskz - create and run emulator with compressed disk release"
