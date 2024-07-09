        .export _mi_init_screen

        .import     _bank_count
        .import     _clr_help
        .import     _clr_src_with_separator
        .import     _clr_status
        .import     _fc_div10
        .import     _put_help
        .import     _put_s
        .import     _put_status
        .import     _scr_clr_highlight
        .import     mx_h1
        .import     mx_k_app_name
        .import     mx_v_app_name
        .import     mx_k_version
        .import     mx_v_version
        .import     mx_k_bank_cnt
        .import     mx_s1
        .import     mx_s2
        .import     pusha

        .include    "macros.inc"
        .include    "zp.inc"

_mi_init_screen:
        jsr     _scr_clr_highlight
        jsr     _clr_help
        jsr     _clr_status
        lda     #6                     ; print a separator at this line
        jsr     _clr_src_with_separator

        put_status #0, #mx_s1
        put_status #1, #mx_s2
        put_help   #0, #mx_h1

        put_s   #2, #1,  #mx_k_app_name
        put_s   #19, #1, #mx_v_app_name
        put_s   #2, #2,  #mx_k_version
        put_s   #19, #2, #mx_v_version
        put_s   #2, #3,  #mx_k_bank_cnt

        ; convert bank count to screen value
        lda     _bank_count
        ldx     #'0'
        jsr     _fc_div10

        ; check if we're under 10
        pha

        lda     tmp1
        cmp     #'0'
        beq     under_10

        sta     temp_num
        pla
        sta     temp_num + 1
        bne     do_print                ; guaranteed to be not 0, as we added 0x30 to get ascii char

under_10:
        mva     #$00, temp_num+1
        pla
        sta     temp_num

do_print:
        ; now print it, should be ascii string
        put_s   #19, #3, #temp_num
        rts

temp_num:
        .byte   0, 0, 0

