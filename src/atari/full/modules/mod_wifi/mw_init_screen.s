        .export     _mw_init_screen

        .import     _clr_scr_all
        .import     _put_help
        .import     _put_status
        .import     mw_h1, mw_s1, mw_s2, mw_s2
        .import     pusha

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"

.proc _mw_init_screen
        jsr        _clr_scr_all
        put_status #0, #mw_s1
        put_status #1, #mw_s2
        ; put_help   #1, #mw_h1
        rts
.endproc
