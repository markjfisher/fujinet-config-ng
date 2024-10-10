# COMPILE FLAGS

# reserved memory for graphics
# LDFLAGS += -Wl -D,__RESERVED_MEMORY__=0x2000

# WARNING! RESERVED_MEMORY MUST BE AT LEAST 1 OTHERWISE RESET BUTTON ALTERNATES WORKING AND NOT!
LDFLAGS += -Wl -D__RESERVED_MEMORY__=0x1
LDFLAGS += -C cfg/$(CURRENT_TARGET_LONG).cfg

################################################################
# DISK creation

SUFFIX = .com
DISK_TASKS += .atr
DISKZ_TASKS += .disk-z
ASSETS_DIR := assets
FN_CONFIG_LOADER := ../fujinet-config-loader
PICOBOOT_DOWNLOAD_URL = https://github.com/FujiNetWIFI/assets/releases/download/picobin/picoboot.bin

DISK_FILE := $(DIST_DIR)/$(PROGRAM).atr
DISKZ_FILE := $(DIST_DIR)/$(PROGRAM)-z.atr

.atr:
	$(call MKDIR,$(ASSETS_DIR)/atr)
	$(call MKDIR,$(DIST_DIR)/atr)
	cp $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX) $(DIST_DIR)/atr/$(PROGRAM)$(SUFFIX)
	if [ -d "../fujinet-config-tools" ]; then \
	    echo "Found fujinet-config-tools, copying com files to atr"; \
	    cp ../fujinet-config-tools/atari/dist/*.COM $(DIST_DIR)/atr || true; \
	    cp ../fujinet-config-tools/atari/dist/*.com $(DIST_DIR)/atr || true; \
	fi
	$(call RMFILES,$(DIST_DIR)/*.atr)
	if [ ! -f $(ASSETS_DIR)/picoboot.bin ] ; then \
		echo "Downloading picoboot.bin from $(PICOBOOT_DOWNLOAD_URL)"; \
		curl -sL $(PICOBOOT_DOWNLOAD_URL) -o $(ASSETS_DIR)/picoboot.bin; \
	fi
	dir2atr -m -S -B $(ASSETS_DIR)/picoboot.bin $(DIST_DIR)/$(PROGRAM).atr $(DIST_DIR)/atr
	rm -rf $(DIST_DIR)/atr
	@echo "Uncompressed file saved as $(DIST_DIR)/$(PROGRAM).atr"

.disk-z:
	if [[ -n "$(FN_CONFIG_LOADER)" && -d "$(FN_CONFIG_LOADER)" ]] ; then \
	  echo "Found fujinet-config-loader, creating compressed autorun.atr"; \
	  $(MAKE) -C "$(FN_CONFIG_LOADER)" clean dist CONFIG_PROG=$$(realpath $(DIST_DIR)/$(PROGRAM_TGT)$(SUFFIX)) $(BANNER_INFO); \
	  if [ $$? -ne 0 ] ; then \
	    echo "ERROR running compressor"; \
	    exit 1; \
	  fi; \
	  cp "$(FN_CONFIG_LOADER)/autorun-zx0.atr" $(DIST_DIR)/$(PROGRAM)-z.atr; \
	  echo "Compressed file saved as $(DIST_DIR)/$(PROGRAM)-z.atr"; \
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

#   $(XS)/debugcmd: "bp kb_global" \
#   $(XS)/debugcmd: "bp debug" \
#   $(XS)/debugcmd: "ba w mw_setting_up" \

ATARI800 ?= $(ATARI800_HOME)/atari800 \
  -xl -nobasic -ntsc -xl-rev custom -config atari800-debug.cfg -run

atari_EMUCMD := $($(ATARI_EMULATOR))

ifeq ($(ATARI_EMULATOR),)
atari_EMUCMD := $(ALTIRRA)
endif
