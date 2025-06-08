        .export     _mi_display_prefs

        .import     _cng_prefs
        .import     _put_s
        .import     _put_s_nl
        .import     hexb
        .import     hex_out
        .import     mx_k_anim_delay
        .import     mx_k_bar_conn
        .import     mx_k_bar_copy
        .import     mx_k_bar_dconn
        .import     mx_k_bright
        .import     mx_k_colour
        .import     mx_k_date_format
        .import     mx_k_shade
        .import     pre_hex_str
        .import     pusha
        .import     temp_num

        .include    "cng_prefs.inc"
        .include    "macros.inc"
        .include    "zp.inc"

.segment "CODE2"

.proc _mi_display_prefs
        put_s   #2, #7,  #mx_k_colour
        put_s   #2, #8,  #mx_k_bright
        put_s   #2, #9,  #mx_k_shade
        put_s   #2, #10, #mx_k_bar_conn
        put_s   #2, #11, #mx_k_bar_dconn
        put_s   #2, #12, #mx_k_bar_copy
        put_s   #2, #13, #mx_k_anim_delay
        put_s   #2, #14, #mx_k_date_format

        ; print 0x in front of all hex values
        put_s   #18, #7, #pre_hex_str
        jsr     _put_s_nl
        jsr     _put_s_nl
        jsr     _put_s_nl
        jsr     _put_s_nl
        jsr     _put_s_nl
        jsr     _put_s_nl
        jsr     _put_s_nl

        ; all of the hexb outputs use temp_num for the target location, so set it once
        mwa     #temp_num, {hex_out+1}

        lda     _cng_prefs + CNG_PREFS_DATA::colour
        jsr     hexb
        ; range is 0-F, so skip first nybble, as it's always 0 and don't want user thinking they can enter larger values
        put_s   #20, #7, #(temp_num+1)

        lda     _cng_prefs + CNG_PREFS_DATA::brightness
        jsr     hexb
        ; as above, range is 0-F, so can use same temp_num+1 string location
        jsr     _put_s_nl

        lda     _cng_prefs + CNG_PREFS_DATA::shade
        jsr     hexb
        ; as above, range is 0-F, so can use same temp_num+1 string location
        jsr     _put_s_nl

        ; these are now full HEX values to print
        lda     _cng_prefs + CNG_PREFS_DATA::bar_conn
        jsr     hexb
        ; need to set ptr9 to correct location again, so use put_s
        put_s   #20, #10, #temp_num

        lda     _cng_prefs + CNG_PREFS_DATA::bar_disconn
        jsr     hexb
        jsr     _put_s_nl

        lda     _cng_prefs + CNG_PREFS_DATA::bar_copy
        jsr     hexb
        jsr     _put_s_nl

        lda     _cng_prefs + CNG_PREFS_DATA::anim_delay
        jsr     hexb
        put_s   #20, #13, #(temp_num+1)

        lda     _cng_prefs + CNG_PREFS_DATA::date_format
        jsr     hexb
        put_s   #20, #14, #(temp_num+1)

        rts
.endproc