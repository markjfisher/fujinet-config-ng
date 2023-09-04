        .export     _mh_init_screen

        .import     _clr_scr_all, _put_help, _put_status
        .import     mh_h1, mh_s1, mh_s3
        .import     pusha

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"

.proc _mh_init_screen
        jsr        _clr_scr_all
        put_status #0, #mh_s1
        put_status #1, #mh_s3
        put_help   #1, #mh_h1
        rts
.endproc
