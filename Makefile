# A very linux make file
#
# assembles everything with mads
# from src dir into build dir to keep src clean.

# couldn't get rmdir working correctly, needs work.

BUILDDIR := build
OUT_EXT := xex
LIBS := src/libs
LIBS_OUT := build/libs

MKDIR = mkdir -p $1

.SUFFIXES:
.PHONY: all clean

all: $(BUILDDIR)/main.xex

$(BUILDDIR):
	$(call MKDIR,$@)

$(LIBS_OUT):
	@$(call MKDIR,$@)

TARGET_FILES :=  $(LIBS_OUT)/main_reloc.obx \
	$(LIBS_OUT)/atari/os.obx \
	$(LIBS_OUT)/atari/p1.obx \
	$(LIBS_OUT)/atari/procs.obx

$(LIBS_OUT)/atari/os.obx: $(LIBS)/atari/os.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/atari)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(LIBS_OUT)/atari/p1.obx: $(LIBS)/atari/p1.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/atari)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(LIBS_OUT)/atari/procs.obx: $(LIBS)/atari/procs.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/atari)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(LIBS_OUT)/main_reloc.obx: $(LIBS)/main_reloc.asm | $(LIBS_OUT)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(BUILDDIR)/main.xex: $(TARGET_FILES) | $(BUILDDIR)
	@echo "================================================================"
	@echo "Building $@"	@echo "LIB_FILES: $(LIB_FILES)"
	mads -o:$@ -i:$(BUILDDIR) src/$(notdir $(@:.xex=.asm))

clean:
	@rm -rf $(BUILDDIR)/*
