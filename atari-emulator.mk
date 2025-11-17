# emulator tasks for atari
$(info Loading ATARI emulator settings)

ALTIRRA ?= $(ALTIRRA_BIN) \
  $(XS)/portable $(XS)/portablealt:altirra-debug.ini \
  $(XS)/debug \
  $(XS)/debugcmd: ".loadsym build\$(PROGRAM_TGT).lbl" \

#  $(XS)/debugcmd: "bp debug" \

# we can also use all Altirra debug commands, like setting a break point on write access to a location
#   $(XS)/debugcmd: "ba w mw_setting_up" \
#   $(XS)/debugcmd: "bp mfp_show_page" \

ATARI800 ?= $(ATARI800_HOME)/atari800 -netsio -1088xe -pal -config atari800-debug.cfg -windowed -win-width 1366 -win-height 817 -axlon 4128
#  -windowed -win-width 1366 -win-height 817 \
# -netsio -xl -pal -config atari800-debug.cfg -windowed -win-width 1366 -win-height 817 -run dist/config.atari.full.com

atari_EMUCMD := $($(ATARI_EMULATOR))

ifeq ($(ATARI_EMULATOR),)
atari_EMUCMD := $(ALTIRRA)
endif

ifeq ($(EMUCMD),)
  EMUCMD = $(atari_EMUCMD)
endif
