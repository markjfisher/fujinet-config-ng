        .export     _mi_init_screen
        .export     mi_set_pmg_widths

        .import     _bank_count
        .import     _clr_help
        .import     _clr_scr_with_separator
        .import     _clr_status
        .import     _cng_prefs
        .import     _fc_div10
        .import     _pmg_space_left
        .import     _pmg_space_right
        .import     _put_help
        .import     _put_s
        .import     _put_s_nl
        .import     _put_status
        .import     _scr_clr_highlight
        .import     mg_l1
        .import     mx_h1
        .import     mx_k_app_name
        .import     mx_k_bank_cnt
        .import     mx_k_bar_conn
        .import     mx_k_bar_copy
        .import     mx_k_bar_dconn
        .import     mx_k_colour
        .import     mx_k_shade
        .import     mx_k_version
        .import     mx_s1
        .import     mx_s2
        .import     mx_v_app_name
        .import     _mx_v_version
        .import     pusha
        .import     temp_num

        .include    "cng_prefs.inc"
        .include    "fn_data.inc"
        .include    "macros.inc"
        .include    "zp.inc"

.segment "CODE2"

_mi_init_screen:
        jsr     _scr_clr_highlight
        jsr     _clr_help
        jsr     _clr_status
        lda     #6
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

        put_s      #5, #21, #mg_l1

        ; convert bank count to screen value
        lda     _bank_count

to_decimal_str:
        ldx     #'0'
        jsr     _fc_div10               ; A = quotient, X = remainder

        ; check if we're under 10
        cmp     #'0'
        beq     under_10

        sta     temp_num
        stx     temp_num + 1
        bne     :+                      ; guaranteed to be not 0, as we added 0x30 to get ascii char

under_10:
        mva     #$00, temp_num+1
        stx     temp_num

:
        ; now print bank count, it's now an ascii string
        put_s   #18, #3, #temp_num

        rts

mi_set_pmg_widths:
        ; setup the PMG bar width by setting the space on both sides. Maybe should be a width setting instead of space_right...
        mva     #19, _pmg_space_left
        mva     #17, _pmg_space_right
        rts
