        .export   _dev_init, mod_highlight_offsets
        .import   _fn_setup_screen
        .include  "atari.inc"
        .include  "zeropage.inc"
        .include  "fn_macros.inc"
        .include  "fn_mods.inc"

; void _dev_init()
;
; Device Specific initialisation routine.
; Setup display, any reset handling, etc.
.proc _dev_init
        ; a few bits of setup from the old C routines
        mva     #$ff, NOCLIK
        mva     #$00, SHFLOK

        ; do we want a full reboot on pressing RESET? Setting 1 causes that here.
        ; mva #$01, COLDST
        mva     #$00, COLDST

        ; setup main Display List, and screen layout
        jsr     _fn_setup_screen

        rts
.endproc

.rodata

; offsets for starting rows:
; row 0: $18
; row 1: $1c
; row 2: $20
;  i.e. $04 per row, starting at $18

; the offset for each module (see Mod enum), i.e. host, device, ...
; with host and device having first row of information at y = 2 (3rd row) down screen
mod_highlight_offsets:
        .byte   $20, $20, $18, $18, $18, $00, $00, $00
