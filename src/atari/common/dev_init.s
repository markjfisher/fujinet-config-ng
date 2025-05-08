        .export   _dev_init

        .import   _joy_load_driver
        .import   _joy_static_stddrv
        .import   _scr_setup
        .import   enable_dli
        .import   fn_font_data

        .include  "atari.inc"
        .include  "zp.inc"
        .include  "macros.inc"
        .include  "modules.inc"

; void dev_init()
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

        ; oddly I had a period where this was resetting to E0 after being set in INIT.
        mva     #>fn_font_data, CHBAS

        ; setup main Display List, and screen layout
        jsr     _scr_setup

        ; enable DLIs
        jmp     enable_dli

.endproc
