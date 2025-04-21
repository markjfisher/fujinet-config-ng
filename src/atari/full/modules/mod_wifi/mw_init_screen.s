        .export     _mw_init_screen

        .import     _clr_help
        .import     _clr_scr_with_separator
        .import     _clr_status
        .import     _pmg_space_left
        .import     _pmg_space_right
        .import     _put_help
        .import     _put_s
        .import     _put_status
        .import     _scr_clr_highlight
        .import     mg_l1
        .import     mw_h1
        .import     mw_s1
        .import     mw_s2
        .import     mw_setting_up
        .import     pusha
        .import     screen_separators

        .include    "macros.inc"
        .include    "zp.inc"

.proc _mw_init_screen
        jsr     _scr_clr_highlight
        jsr     _clr_help
        jsr     _clr_status
        lda     #$08                     ; print a separator at line 9
        sta     screen_separators
        ldy     #$01
        jsr     _clr_scr_with_separator
        
        put_status #0, #mw_s1
        put_status #1, #mw_s2
        put_help   #0, #mw_h1
        put_s      #3, #21, #mg_l1
        lda        #$01
        sta        _pmg_space_left
        sta        _pmg_space_right
        rts
.endproc
