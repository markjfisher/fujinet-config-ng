        .export         _main

        .import         _reset_handler
        .import         mod_current
        .import         run_module

        ; in a pure asm application (or where main is in asm, not sure...)
        ; this is required for the APPLE2 target, doesn't harm the atari
        .forceimport    __STARTUP__

        .include        "atari.inc"
        .include        "modules.inc"
        .include        "macros.inc"
        .include        "zp.inc"

.proc _main
:       jsr     run_module

        ; are we quitting?
        lda     mod_current
        cmp     #Mod::exit
        bne     :-              ; no, loop around running module's handler code

        ; ---------------------------------------------------
        ; RETURN TO CALLER

        ; reset DOSINI for reset handling
        mwa     _reset_handler+1+3, DOSINI

        mva     #$00, GRACTL
        mva     #$00, PMBASE
        mva     #$22, DMACTL
        mva     #$00, NOCLIK

        ; Alternative library way of doing this, but adds about 1k to app:
        ; lda #$00
        ; jsr __graphics
        ; jsr _close

        ; RESET THE SCREEN by closing and opening E: on IOCB#0
        ldx     #$00
        mva     #$0C,       {ICCOM, x}
        jsr     CIOV

        ldx     #$00
        mva     #$03,       {ICCOM, x}  ; open
        mva     #<dev_name, {ICBAL, x}
        mva     #>dev_name, {ICBAH, x}
        mva     #$0C,       {ICAX1, x}
        jmp     CIOV
        ; implicit rts


        ; this is the way to do it with functions, but it's 1 off, so skipping all the niceties

        ; lda     #$00            ; iocb #0
        ; jsr     _close_dev      ; close it

        ; pusha   #$00            ; iocb #0
        ; pusha   #$0C            ; R/W (aux1)
        ; setax   #dev_name       ; device E:
        ; jmp     _open_dev       ; open!

        ; ; implicit rts

.endproc

; ; int close_dev(uint8_t iocb_num)
; .proc _close_dev
;         tax
;         mva     #$0C,  {ICCOM, x}
;         jsr     CIOV
;         bpl     ok
;         jmp     return1
; ok:
;         jmp     return0
;         rts
; .endproc

; ; int open_dev(uint8_t iocb_num, uint8_t aux1, char *device);
; .proc _open_dev
;         axinto  ptr1                ; device
;         popa    tmp1                ; aux1
;         jsr     popa                ; iocb ($10 for 1, $20 for 2, etc)
;         tax
;         mva     #$03,   {ICCOM, x}  ; open
;         mva     ptr1,   {ICBAL, x}
;         mva     ptr1+1, {ICBAH, x}
;         mva     tmp1,   {ICAX1, x}
;         jsr     CIOV
;         bpl     ok
;         jmp     return1
; ok:
;         jmp     return0
; .endproc

.data
dev_name:        .byte "E:", 0
