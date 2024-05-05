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

.endproc

.data
dev_name:        .byte "E:", 0
