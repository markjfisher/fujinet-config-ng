        .export   _dev_init
        .import   _fn_setup_screen
        .include  "fn_macros.inc"
        .include  "zeropage.inc"
        .include  "atari.inc"

; void _dev_init()
;
; Device Specific initialisation routine.
; Setup display, any reset handling, etc.
.proc _dev_init
        ; setup reset handler
        ; only do it if we haven't captured it yet, else multiple resets cause recursion
;         lda     _reset_handler+1
;         cmp     #$ff
;         bne     noset
;         lda     _reset_handler+2
;         cmp     #$ff
;         bne     noset

; set_dosini:
;         mwa     DOSINI, _reset_handler+1
;         mwa     #_reset_handler, DOSINI

noset:
        ; a few bits of setup from the old C routines
        mva #$ff, NOCLIK
        mva #$00, SHFLOK

        ; do we want a full reboot on pressing RESET? Setting 1 causes that here.
        ; mva #$01, COLDST
        mva #$00, COLDST
        mva #$00, SDMCTL

        ; setup main Display List, and screen layout
        jsr     _fn_setup_screen

; show_init:
;         ; show initialising messages
;         put_s   #10, #7, #s_init1

;         ldx     #10
;         ldy     #7
;         jsr     _fn_get_scrloc      ; ptr4 set to screen location where 'initialized' string is
        
;         ; A small delay with animation, invert the string letter by letter, looks like progress bar.
;         ; COMPLETELY UNNEEDED.

;         ; fill over each letter with its inverse every N blanks
;         ldy     #$00
; :       lda     #$01            ; pause time in jiffies
;         jsr     _fn_pause       ; pause! does not trash Y or ptr4
;         lda     (ptr4), y       ; get current letter
;         ora     #$80            ; inverse it
;         sta     (ptr4), y       ; write to screen
;         iny
;         cpy     #15
;         bne     :-              ; loop for all letters 

        rts

.endproc

; .rodata
; s_init1:    .byte "Initialising...", 0
