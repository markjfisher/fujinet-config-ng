        .export   _dev_init
        .import   _scr_setup
        .import   fn_font_data

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

        mva     #>fn_font_data, CHBAS

        ; setup main Display List, and screen layout
        jmp     _scr_setup

.endproc
