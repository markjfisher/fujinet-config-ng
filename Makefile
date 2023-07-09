# Generic build file with no target
.DEFAULT_GOAL := all
include Makefile.common

all: $(BUILDDIR)/main.com

TARGET_FILES += $(LIBS_OUT)/default_screen/display.obx

$(LIBS_OUT)/default_screen/display.obx: $(LIBS)/default_screen/display.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/default_screen)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(BUILDDIR)/main.com: $(TARGET_FILES) | $(BUILDDIR)
	@echo "================================================================"
	@echo "Building $@"
	@echo "LIB_FILES: $(TARGET_FILES)"
	mads -o:$@ -i:$(BUILDDIR) src/$(notdir $(@:.com=.asm))
