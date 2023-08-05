        .export     _fn_show_dcb
        .import     _fn_put_s, pusha, pushax
        .import     hexb, hex, setax, _fn_get_scrloc
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_dcb.inc"
        .include    "atari.inc"

; void fn_show_dcb()
;
; prints DCB info in top right corner for debug
.proc _fn_show_dcb

        ; headings
        put_s   #25, #2,  #sdcb_ddevic
        put_s   #25, #3,  #sdcb_dunit
        put_s   #25, #4,  #sdcb_dcomnd
        put_s   #25, #5,  #sdcb_dstats
        put_s   #25, #6,  #sdcb_dbuf
        put_s   #25, #7,  #sdcb_dtimlo
        put_s   #25, #8,  #sdcb_dunuse
        put_s   #25, #9,  #sdcb_dbyt
        put_s   #25, #10, #sdcb_daux1
        put_s   #25, #11, #sdcb_daux2

        do_scr_loc   #32, #2

        pusha   IO_DCB::ddevic
        setax   ptr4
        jsr     hexb

        adw     ptr4, #40
        pusha   IO_DCB::dunit
        setax   ptr4
        jsr     hexb

        adw     ptr4, #40
        pusha   IO_DCB::dcomnd
        setax   ptr4
        jsr     hexb

        adw     ptr4, #40
        pusha   IO_DCB::dstats
        setax   ptr4
        jsr     hexb

        ; WORD
        adw     ptr4, #40
        pushax  IO_DCB::dbuflo
        setax   ptr4
        jsr     hexb

        adw     ptr4, #40
        pusha   IO_DCB::dtimlo
        setax   ptr4
        jsr     hexb

        adw     ptr4, #40
        pusha   IO_DCB::dunuse
        setax   ptr4
        jsr     hexb

        ; WORD
        adw     ptr4, #40
        pushax  IO_DCB::dbytlo
        setax   ptr4
        jsr     hexb

        adw     ptr4, #40
        pusha   IO_DCB::daux1
        setax   ptr4
        jsr     hexb

        adw     ptr4, #40
        pusha   IO_DCB::daux2
        setax   ptr4
        jsr     hexb

.endproc

.rodata

sdcb_ddevic:    .byte "ddevic", 0
sdcb_dunit:     .byte " dunit", 0
sdcb_dcomnd:    .byte "dcomnd", 0
sdcb_dstats:    .byte "dstats", 0
sdcb_dbuf:      .byte "  dbuf", 0
sdcb_dtimlo:    .byte "dtimlo", 0
sdcb_dunuse:    .byte "dunuse", 0
sdcb_dbyt:      .byte "  dbyt", 0
sdcb_daux1:     .byte " daux1", 0
sdcb_daux2:     .byte " daux2", 0












