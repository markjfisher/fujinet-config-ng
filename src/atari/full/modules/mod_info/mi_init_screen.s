        .export _mi_init_screen

        .import     _bank_count
        .import     _clr_help
        .import     _clr_scr_with_separator
        .import     _clr_status
        .import     _cng_prefs
        .import     _fc_div10
        .import     _pmg_skip_x
        .import     _put_help
        .import     _put_s
        .import     _put_s_fast
        .import     _put_status
        .import     _scr_clr_highlight
        .import     hex
        .import     hexb
        .import     mx_h1
        .import     mx_k_app_name
        .import     mx_v_app_name
        .import     mx_k_version
        .import     mx_v_version
        .import     mx_k_bank_cnt
        .import     mx_s1
        .import     mx_s2
        .import     pusha
        .import     mx_k_colour, mx_k_shade, mx_k_bar_conn, mx_k_bar_dconn, mx_k_bar_copy

        .include    "cng_prefs.inc"
        .include    "fn_data.inc"
        .include    "macros.inc"
        .include    "zp.inc"

_mi_init_screen:
        jsr     _scr_clr_highlight
        jsr     _clr_help
        jsr     _clr_status
        lda     #6                     ; print a separator at this line
        jsr     _clr_scr_with_separator

        put_status #0, #mx_s1
        put_status #1, #mx_s2
        put_help   #0, #mx_h1

        put_s   #2,  #1, #mx_k_app_name
        put_s   #17, #1, #mx_v_app_name
        put_s   #2,  #2, #mx_k_version
        put_s   #17, #2, #mx_v_version
        put_s   #2,  #3, #mx_k_bank_cnt

        lda     #$12
        sta     _pmg_skip_x

        ; convert bank count to screen value
        lda     _bank_count
        jsr     to_decimal_str

do_print:
        ; now print it, should be ascii string
        put_s   #17, #3, #temp_num


; #######################################################################
; Editable Preferences

        put_s   #2, #7,  #mx_k_colour

        ; put_s   #2, #8,  #mx_k_shade
        mwa     #mx_k_shade, tmp9
        adw1    ptr4, #SCR_BYTES_W
        put_s_fast #2, #8

        ; put_s   #2, #9,  #mx_k_bar_conn
        mwa     #mx_k_bar_conn, tmp9
        adw1    ptr4, #SCR_BYTES_W
        put_s_fast #2, #9

        ; put_s   #2, #10, #mx_k_bar_dconn
        mwa     #mx_k_bar_dconn, tmp9
        adw1    ptr4, #SCR_BYTES_W
        put_s_fast #2, #10

        ; put_s   #2, #11, #mx_k_bar_copy
        mwa     #mx_k_bar_copy, tmp9
        adw1    ptr4, #SCR_BYTES_W
        put_s_fast #2, #11

        lda     _cng_prefs + CNG_PREFS_DATA::colour
        jsr     to_decimal_str
        put_s   #17, #7, #temp_num

        ;; everything from here uses the temp_num pointer in tmp9, so only set it once
        lda     _cng_prefs + CNG_PREFS_DATA::shade
        jsr     to_decimal_str
        ; put_s   #17, #8, #temp_num
        adw1    ptr4, #SCR_BYTES_W
        put_s_fast #17, #8

        lda     _cng_prefs + CNG_PREFS_DATA::bar_conn
        jsr     to_decimal_str
        ; put_s   #17, #9, #temp_num
        adw1    ptr4, #SCR_BYTES_W
        put_s_fast #17, #9

        lda     _cng_prefs + CNG_PREFS_DATA::bar_disconn
        jsr     to_decimal_str
        ; put_s   #17, #10, #temp_num
        adw1    ptr4, #SCR_BYTES_W
        put_s_fast #17, #10

        lda     _cng_prefs + CNG_PREFS_DATA::bar_copy
        jsr     to_decimal_str
        ; put_s   #17, #11, #temp_num
        adw1    ptr4, #SCR_BYTES_W
        put_s_fast #17, #11

        rts

to_decimal_str:
        ldx     #'0'
        jsr     _fc_div10               ; A = quotient, X = remainder

        ; check if we're under 10
        cmp     #'0'
        beq     under_10

        sta     temp_num
        stx     temp_num + 1
        bne     exit                    ; guaranteed to be not 0, as we added 0x30 to get ascii char

under_10:
        mva     #$00, temp_num+1
        stx     temp_num

exit:
        rts

.data

temp_num:
        .byte   0, 0, 0
