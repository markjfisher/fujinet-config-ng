        .export   _dev_init
        .import   _fn_setup_screen, _fn_get_scrloc, _fn_pause, _fn_put_s, pushax
        .include    "fn_macros.inc"
        .include    "zeropage.inc"

.proc _dev_init
        jsr     _fn_setup_screen

show_init:
        ; show initialising messages
        put_s   #10, #7, #s_init1

        ldx     #10
        ldy     #7
        jsr     _fn_get_scrloc      ; ptr4 set to screen location where 'initialized' string is
        
        ; A small delay with animation. Trying to let FN have time to start?

        ; fill over each letter with its inverse every N blanks
        ldy     #$00
:       lda     #$01
        jsr     _fn_pause       ; pause n jiffies, does not trash Y or ptr4
        lda     (ptr4), y       ; get current letter
        ora     #$80            ; inverse
        sta     (ptr4), y       ; write to screen
        iny
        cpy     #15
        bne     :-              ; loop for all letters 

        rts

.endproc

.rodata
s_init1:    .byte "Initialising...", 0
