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
        mva #$ff, NOCLIK
        mva #$00, SHFLOK

        ; do we want a full reboot on pressing RESET? Setting 1 causes that here.
        ; mva #$01, COLDST
        mva #$00, COLDST

        ; setup main Display List, and screen layout
        jsr     _fn_setup_screen

        rts
.endproc

.rodata

mod_highlight_offsets:
        .byte   $20, $20, 0, 0
