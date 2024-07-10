        .export     _mw_init_screen

        .import     _clr_help
        .import     _clr_scr_with_separator
        .import     _clr_status
        .import     _pmg_skip_x
        .import     _put_help
        .import     _put_status
        .import     _scr_clr_highlight
        .import     mw_h1
        .import     mw_s1
        .import     mw_s2
        .import     mw_setting_up
        .import     pusha

        .include    "macros.inc"
        .include    "zp.inc"

.proc _mw_init_screen
        jsr     _scr_clr_highlight
        jsr     _clr_help
        jsr     _clr_status
        lda     #9                     ; print a separator at this line
        jsr     _clr_scr_with_separator
        
        put_status #0, #mw_s1
        put_status #1, #mw_s2
        put_help   #0, #mw_h1
        lda        #$01
        sta        _pmg_skip_x
        rts
.endproc
