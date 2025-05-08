        .export     _mi_init_screen
        .export     mi_set_pmg_widths

        .import     _bank_count
        .import     _clr_help
        .import     _clr_scr_with_separator
        .import     _clr_status
        .import     _mx_v_version
        .import     _pmg_space_left
        .import     _pmg_space_right
        .import     _put_help
        .import     _put_s
        .import     _put_status
        .import     _scr_clr_highlight
        .import     itoa_args
        .import     itoa_2digits
        .import     mg_l1
        .import     mx_h1
        .import     mx_k_app_name
        .import     mx_k_bank_cnt
        .import     mx_k_version
        .import     mx_s1
        .import     mx_s2
        .import     mx_v_app_name
        .import     pusha
        .import     screen_separators


        .include    "cng_prefs.inc"
        .include    "fn_data.inc"
        .include    "itoa.inc"
        .include    "macros.inc"
        .include    "zp.inc"

.segment "CODE2"

_mi_init_screen:
        jsr     _scr_clr_highlight
        jsr     _clr_help
        jsr     _clr_status
        lda     #$05
        sta     screen_separators
        ldy     #$01
        jsr     _clr_scr_with_separator

        jsr     mi_set_pmg_widths

        put_status #0, #mx_s1
        put_status #1, #mx_s2
        put_help   #0, #mx_h1

        put_s   #2,  #1, #mx_k_app_name
        put_s   #18, #1, #mx_v_app_name
        put_s   #2,  #2, #mx_k_version
        put_s   #18, #2, _mx_v_version
        put_s   #2,  #3, #mx_k_bank_cnt

        put_s      #3, #21, #mg_l1

to_decimal_str:
        ; convert bank count to screen value
        mva     _bank_count, itoa_args+ITOA_PARAMS::itoa_input
        mva     #$00, itoa_args+ITOA_PARAMS::itoa_show0
        jsr     itoa_2digits

        ; now print bank count, it's now an ascii string
        put_s   #18, #3, #itoa_args+ITOA_PARAMS::itoa_buf

        rts

mi_set_pmg_widths:
        ; setup the PMG bar width by setting the space on both sides. Maybe should be a width setting instead of space_right...
        mva     #19, _pmg_space_left
        mva     #17, _pmg_space_right
        rts
