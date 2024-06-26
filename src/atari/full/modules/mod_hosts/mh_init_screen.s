        .export     _mh_init_screen

        .import     _clr_scr_all
        .import     _put_help
        .import     _put_status
        .import     mh_h1, mh_s1, mh_s2
        .import     pusha

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fujinet-fuji.inc"

.proc _mh_init_screen
        jsr        _clr_scr_all
        put_status #0, #mh_s1
        put_status #1, #mh_s2
        put_help   #0, #mh_h1
        rts
.endproc
