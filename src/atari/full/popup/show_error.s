        .export     _show_error

        .import     _show_select
        .import     info_popup_help
        .import     popa
        .import     pu_null_cb
        .import     pu_err_title
        .import     pushax

        .include    "macros.inc"
        .include    "fujinet-fuji.inc"
        .include    "modules.inc"
        .include    "popup.inc"

; void show_error(uint8_t width, uint8_t num_lines, char *msgs)
; display a generic error message with given width, and lines of msgs
.proc _show_error
        ; messages
        sta     se_template + 9
        stx     se_template + 10
        ; number of lines
        jsr     popa
        sta     se_template + 8
        ; width
        jsr     popa
        sta     se_template + 0

        pushax  #pu_null_cb
        pushax  #se_template
        pushax  #info_popup_help
        setax   #pu_err_title
        jmp     _show_select
.endproc

.data
se_template:
                .byte 0, 5, 0, $ff, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::text, 1, 0, 0
                .byte PopupItemType::space
                .byte PopupItemType::finish
