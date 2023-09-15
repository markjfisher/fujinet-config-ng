        .export     _mw_init_screen

        .import     _clr_help
        .import     _clr_src_with_separator
        .import     _clr_status
        .import     _put_help
        .import     _put_status
        .import     mw_h1
        .import     mw_s1
        .import     mw_s2
        .import     mw_setting_up
        .import     pusha

        .include    "fc_macros.inc"
        .include    "fc_zp.inc"

.proc _mw_init_screen
        jsr     _clr_help
        jsr     _clr_status
        lda     #9                     ; print a separator at this line
        jsr     _clr_src_with_separator
        
        put_status #0, #mw_s1
        put_status #1, #mw_s2
        put_help   #0, #mw_h1
        rts
.endproc
