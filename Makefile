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
	$(LIBS_OUT)/states/check_wifi.obx \
    $(LIBS_OUT)/states/connect_wifi.obx \
    $(LIBS_OUT)/states/set_wifi.obx \
    $(LIBS_OUT)/states/hosts_and_devices.obx \
    $(LIBS_OUT)/states/select_file.obx \
    $(LIBS_OUT)/states/select_slot.obx \
    $(LIBS_OUT)/states/destination_host_slot.obx \
    $(LIBS_OUT)/states/perform_copy.obx \
    $(LIBS_OUT)/states/show_info.obx \
    $(LIBS_OUT)/states/show_devices.obx \
    $(LIBS_OUT)/states/done.obx \
	$(LIBS_OUT)/atari/os.obx \
	$(LIBS_OUT)/atari/dlists.obx

# CORE

$(LIBS_OUT)/main_reloc.obx: $(LIBS)/main_reloc.asm | $(LIBS_OUT)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(LIBS_OUT)/modules.obx: $(LIBS)/modules.asm | $(LIBS_OUT)
	mads -o:$@ -i:$(BUILDDIR) $(subst build,src,$@)

$(LIBS_OUT)/modules/hosts.obx: $(LIBS)/modules/hosts.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/modules)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/modules/hosts.lst -t:build/libs/modules/hosts.lab $(subst build,src,$@)

$(LIBS_OUT)/decompress.obx: $(LIBS)/decompress.asm | $(LIBS_OUT)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/decompress.lst -t:build/libs/decompress.lab $(subst build,src,$@)

$(LIBS_OUT)/states/check_wifi.obx: $(LIBS)/states/check_wifi.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/check_wifi.lst -t:build/libs/states/check_wifi.lab $(subst build,src,$@)

$(LIBS_OUT)/states/connect_wifi.obx: $(LIBS)/states/connect_wifi.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/connect_wifi.lst -t:build/libs/states/connect_wifi.lab $(subst build,src,$@)

$(LIBS_OUT)/states/set_wifi.obx: $(LIBS)/states/set_wifi.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/set_wifi.lst -t:build/libs/states/set_wifi.lab $(subst build,src,$@)

$(LIBS_OUT)/states/hosts_and_devices.obx: $(LIBS)/states/hosts_and_devices.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/hosts_and_devices.lst -t:build/libs/states/hosts_and_devices.lab $(subst build,src,$@)

$(LIBS_OUT)/states/select_file.obx: $(LIBS)/states/select_file.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/select_file.lst -t:build/libs/states/select_file.lab $(subst build,src,$@)

$(LIBS_OUT)/states/select_slot.obx: $(LIBS)/states/select_slot.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/select_slot.lst -t:build/libs/states/select_slot.lab $(subst build,src,$@)

$(LIBS_OUT)/states/destination_host_slot.obx: $(LIBS)/states/destination_host_slot.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/destination_host_slot.lst -t:build/libs/states/destination_host_slot.lab $(subst build,src,$@)

$(LIBS_OUT)/states/perform_copy.obx: $(LIBS)/states/perform_copy.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/perform_copy.lst -t:build/libs/states/perform_copy.lab $(subst build,src,$@)

$(LIBS_OUT)/states/show_info.obx: $(LIBS)/states/show_info.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/show_info.lst -t:build/libs/states/show_info.lab $(subst build,src,$@)

$(LIBS_OUT)/states/show_devices.obx: $(LIBS)/states/show_devices.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/show_devices.lst -t:build/libs/states/show_devices.lab $(subst build,src,$@)

$(LIBS_OUT)/states/done.obx: $(LIBS)/states/done.asm | $(LIBS_OUT)
	$(call MKDIR,$(LIBS_OUT)/states)
	mads -o:$@ -i:$(BUILDDIR) -l:build/libs/states/done.lst -t:build/libs/states/done.lab $(subst build,src,$@)


#########################################################
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
