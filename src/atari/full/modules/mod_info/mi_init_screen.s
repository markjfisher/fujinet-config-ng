        .export _mi_init_screen

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
        .import     hexb
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
        .import     mx_v_version
        .import     pusha

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

        ; setup the PMG bar width by setting the space on both sides. Maybe should be a width setting instead of space_right...
        mva     #19, _pmg_space_left
        mva     #17, _pmg_space_right

        put_status #0, #mx_s1
        put_status #1, #mx_s2
        put_help   #0, #mx_h1

        put_s   #2,  #1, #mx_k_app_name
        put_s   #20, #1, #mx_v_app_name
        put_s   #2,  #2, #mx_k_version
        put_s   #20, #2, #mx_v_version
        put_s   #2,  #3, #mx_k_bank_cnt

        ; convert bank count to screen value
        lda     _bank_count
        jsr     to_decimal_str

do_print:
        ; now print bank count, it's now an ascii string
        put_s   #20, #3, #temp_num


; #######################################################################
; Editable Preferences

        put_s   #2, #7,  #mx_k_colour

        put_s   #2, #8,  #mx_k_shade
        put_s   #2, #9,  #mx_k_bar_conn
        put_s   #2, #10, #mx_k_bar_dconn
        put_s   #2, #11, #mx_k_bar_copy

        ; print 0x in front of all hex values
        put_s   #18, #7, #pre_hex_str
        jsr     _put_s_nl
        jsr     _put_s_nl
        jsr     _put_s_nl
        jsr     _put_s_nl

        lda     _cng_prefs + CNG_PREFS_DATA::colour
        jsr     pusha
        setax   #temp_num
        jsr     hexb
        ; range is 0-F, so skip first nybble, as it's always 0 and don't want user thinking they can enter larger values
        put_s   #20, #7, #(temp_num+1)

        lda     _cng_prefs + CNG_PREFS_DATA::shade
        jsr     pusha
        setax   #temp_num
        jsr     hexb
        ; as above, range is 0-F, so can use same temp_num+1 string location
        jsr     _put_s_nl

        ; these are now full HEX values to print
        lda     _cng_prefs + CNG_PREFS_DATA::bar_conn
        jsr     pusha
        setax   #temp_num
        jsr     hexb
        ; need to set ptr9 to correct location again, so use put_s
        put_s   #20, #9, #temp_num

        lda     _cng_prefs + CNG_PREFS_DATA::bar_disconn
        jsr     pusha
        setax   #temp_num
        jsr     hexb
        jsr     _put_s_nl

        lda     _cng_prefs + CNG_PREFS_DATA::bar_copy
        jsr     pusha
        setax   #temp_num
        jsr     hexb
        jsr     _put_s_nl

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

temp_num:       .byte 0, 0, 0   ; our value string of 2 bytes
pre_hex_str:    .byte "0x", 0