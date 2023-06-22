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

TARGET_FILES := $(LIBS_OUT)/loop-part.obx $(LIBS_OUT)/other.obx

$(LIBS_OUT)/loop-part.obx: $(LIBS)/loop-part.asm | $(LIBS_OUT)
	mads -o:$@ $(subst build,src,$@)

$(LIBS_OUT)/other.obx: $(LIBS)/other.asm | $(LIBS_OUT)
	mads -o:$@ $(subst build,src,$@)

$(BUILDDIR)/main.xex: $(TARGET_FILES) | $(BUILDDIR)
	@echo "================================================================"
	@echo "Building $@"	@echo "LIB_FILES: $(LIB_FILES)"
	mads -o:$@ -i:$(BUILDDIR) src/$(notdir $(@:.xex=.asm))

clean:
	@rm -rf $(BUILDDIR)/*
