# A very linux make file
#
# assembles everything with mads
# from src dir into build dir to keep src clean.

# couldn't get rmdir working correctly, needs work.

BUILDDIR := build
OUT_EXT := xex
LIBS := src/libs
LIBS_OUT := build/libs

ALTIRRA := $(ALTIRRA_HOME)/Altirra64.exe

MKDIR = mkdir -p $1

.SUFFIXES:
.PHONY: all clean

all: $(BUILDDIR)/main.xex

$(BUILDDIR):
	$(call MKDIR,$@)

$(LIBS_OUT):
	@$(call MKDIR,$@)

TARGET_FILES :=  $(LIBS_OUT)/main_reloc.obx \
	$(LIBS_OUT)/decompress.obx \
	$(LIBS_OUT)/modules.obx \
	$(LIBS_OUT)/modules/hosts.obx \
	$(LIBS_OUT)/atari/os.obx \
	$(LIBS_OUT)/atari/dlists.obx

# OTHER

$(LIBS_OUT)/main_reloc.obx: $(LIBS)/main_reloc.asm | $(LIBS_OUT)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(LIBS_OUT)/modules.obx: $(LIBS)/modules.asm | $(LIBS_OUT)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(LIBS_OUT)/modules/hosts.obx: $(LIBS)/modules/hosts.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/modules)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/modules/hosts.lst -t:build/libs/modules/hosts.lab $(subst build,src,$@)

$(LIBS_OUT)/decompress.obx: $(LIBS)/decompress.asm | $(LIBS_OUT)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/decompress.lst -t:build/libs/decompress.lab $(subst build,src,$@)

# ATARI specific

$(LIBS_OUT)/atari/os.obx: $(LIBS)/atari/os.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/atari)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(LIBS_OUT)/atari/dlists.obx: $(LIBS)/atari/dlists.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/atari)
	mads -o:$@ -i:$(BUILDDIR) -i:src/libs/atari/data -l:build/libs/atari/dlists.lst -t:build/libs/atari/dlists.lab $(subst build,src,$@)

# DEBUG in Altirra emulator
# You need to configure altirra-debug.ini by adding roms etc in initial run.
debug: $(BUILDDIR)/main.xex
	$(ALTIRRA) \
	/portable /portablealt:altirra-debug.ini \
	/debug \
	/debugcmd: ".loadsym build\main.lst" \
	/debugcmd: ".loadsym build\main.lab" \
	/debugcmd: ".loadsym build\libs\atari\dlists.lst" \
	/debugcmd: ".loadsym build\libs\atari\dlists.lab" \
	/debugcmd: ".loadsym build\libs\decompress.lst" \
	/debugcmd: ".loadsym build\libs\decompress.lab" \
	/debugcmd: "bp init_dl" \
	build\\main.xex

# Doesn't work so well in WSL as it doesn't find the asm files, and can't load them from WSL path for some reason
#	/debugcmd: ".sourcemode on" \

## EXECUTABLE

$(BUILDDIR)/main.xex: $(TARGET_FILES) | $(BUILDDIR)
	@echo "================================================================"
	@echo "Building $@"	@echo "LIB_FILES: $(LIB_FILES)"
	mads -o:$@ -i:$(BUILDDIR) -l:build/main.lst -t:build/main.lab src/$(notdir $(@:.xex=.asm))

clean:
	@rm -rf $(BUILDDIR)/*
