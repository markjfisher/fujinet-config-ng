# COMPILE FLAGS

# reserved memory for graphics
# LDFLAGS += -Wl -D,__RESERVED_MEMORY__=0x2000

LDFLAGS += -Wl -D__RESERVED_MEMORY__=0x1
LDFLAGS += -C cfg/$(CURRENT_TARGET_LONG).cfg

################################################################
# DISK creation

SUFFIX = .com
DISK_TASKS += .atr
DISKZ_TASKS += .dist-z

FN_CONFIG_LOADER := ../fujinet-config-loader

.atr:
	$(call MKDIR,$(DIST_DIR)/atr)
	cp $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX) $(DIST_DIR)/atr/$(PROGRAM)$(SUFFIX)
	$(call RMFILES,$(DIST_DIR)/*.atr)
	dir2atr -S $(DIST_DIR)/$(PROGRAM).atr $(DIST_DIR)/atr

.dist-z:
	@if [[ -n "$(FN_CONFIG_LOADER)" && -d "$(FN_CONFIG_LOADER)" ]] ; then \
    echo "Found fujinet-config-loader, creating compressed autorun.atr"; \
    $(MAKE) -C "$(FN_CONFIG_LOADER)" clean dist CONFIG_PROG=$$(realpath $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX)) $(BANNER_INFO); \
    if [ $$? -ne 0 ] ; then \
      echo "ERROR running compressor"; \
      exit 1; \
    fi; \
    cp "$(FN_CONFIG_LOADER)/autorun-zx0.atr" ./autorun.atr; \
    echo "Compressed file saved as autorun.atr"; \
  else \
    echo "ERROR: Could not find fujinet-config-loader at path $(FN_CONFIG_LOADER)."; \
    exit 1; \
  fi

################################################################
# TESTING / EMULATOR

# Specify ATARI_EMULATOR=[ALTIRRA|ATARI800] to set which one to run, default is ALTIRRA
# At the current time, ATARI800 does not have any integration with fujinet

ALTIRRA ?= $(ALTIRRA_HOME)/Altirra64.exe \
  $(XS)/portable $(XS)/portablealt:altirra-debug.ini \
  $(XS)/debug \
  $(XS)/debugcmd: ".loadsym build\$(PROGRAM_TGT).lbl" \
  $(XS)/debugcmd: "bp ak_read_settings" \

# Additional args that can be copied into the above lines
#   $(XS)/debug \
#   $(XS)/debugcmd: ".loadsym build\$(PROGRAM).$(CURRENT_TARGET).lbl" \
#   $(XS)/debugcmd: "bp _debug" \

ATARI800 ?= $(ATARI800_HOME)/atari800 \
  -xl -nobasic -ntsc -xl-rev custom -config atari800-debug.cfg -run

atari_EMUCMD := $($(ATARI_EMULATOR))

ifeq ($(ATARI_EMULATOR),)
atari_EMUCMD := $(ALTIRRA)
endif
