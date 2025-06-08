        .export     _mi_init_screen
        .export     mi_set_pmg_widths
        .export     mi_show_help
        .export     empty_help

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

        ; Navigation callback system
        .import     kb_selection_changed_cb
        .import     kb_current_line

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

        ; Set up navigation callback for help text
        mwa     #mi_show_help, kb_selection_changed_cb

        rts

mi_set_pmg_widths:
        ; setup the PMG bar width by setting the space on both sides. Maybe should be a width setting instead of space_right...
        mva     #19, _pmg_space_left
        mva     #17, _pmg_space_right
        rts

; Callback function to display help text based on current selection
mi_show_help:
        lda     kb_current_line
        cmp     #8                      ; check bounds (0-7 for 8 preferences)
        bcs     clear_help              ; clear if out of bounds

        ; Use lookup table to get help text address
        asl     a                       ; multiply by 2 for word addresses
        tay
        lda     help_text_table,y
        sta     ptr1
        lda     help_text_table+1,y
        sta     ptr1+1

        ; Display help text
        put_s   #1, #19, ptr1
        rts

clear_help:
        ; Clear help line
        put_s   #1, #19, #empty_help
        rts

; Help text lookup table (word addresses)
help_text_table:
        .word   help_colour             ; 0 - Colour
        .word   help_brightness         ; 1 - Brightness  
        .word   help_shade              ; 2 - Shade (B/G)
        .word   help_bar_conn           ; 3 - Bar (Conn.)
        .word   help_bar_disconn        ; 4 - Bar (Discon.)
        .word   help_bar_copy           ; 5 - Bar (Copying)
        .word   help_anim_delay         ; 6 - Anim. Delay
        .word   help_date_format        ; 7 - Date Format

; Help text strings
.rodata
help_colour:        .byte " Change main colour of the display  ", 0
help_brightness:    .byte "  Adjust screen brightness (0-F)    ", 0
help_shade:         .byte " Background/foreground shade (0-F)  ", 0  
help_bar_conn:      .byte " Highlight bar color when connected ", 0
help_bar_disconn:   .byte " Highlight bar color when disconn.  ", 0
help_bar_copy:      .byte "Highlight bar color during file copy", 0
help_anim_delay:    .byte "Anim speed for scrolling text (0-F) ", 0
help_date_format:   .byte "  Date: 0=d/m/y, 1=m/d/y, 2=y/m/d   ", 0
empty_help:         .byte "                                    ", 0
