        .export     _mf_init_screen

        .import     _clr_scr_all, _put_help, _put_status
        .import     _scr_clr_highlight
        .import     mf_s1, mf_h1, mf_h3
        .import     pusha

        .include    "fn_macros.inc"

.proc _mf_init_screen
        jsr        _clr_scr_all
        put_status #0, #mf_s1
        put_help   #0, #mf_h1
        put_help   #1, #mf_h3

        jsr        _scr_clr_highlight
        rts
.endproc