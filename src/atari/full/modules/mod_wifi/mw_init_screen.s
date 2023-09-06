        .export     _mw_init_screen

        .import     _clr_help
        .import     _clr_src_with_separator
        .import     _clr_status
        .import     _put_status
        .import     mw_s1
        .import     mw_s2
        .import     pusha

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"

.proc _mw_init_screen
        jsr     _clr_help
        jsr     _clr_status
        lda     #10                     ; print a separator on line 10
        jsr     _clr_src_with_separator
        
        put_status #0, #mw_s1
        put_status #1, #mw_s2
        ; put_help   #1, #mw_h1
        rts
.endproc
