        .export     _mx_error_booting

        .import     _show_select
        .import     info_popup_help
        .import     pu_err_title
        .import     pushax

        .include    "fc_macros.inc"
        .include    "fn_io.inc"
        .include    "fc_mods.inc"
        .include    "popup.inc"

.proc _mx_error_booting
        pushax  #mx_boot_error_info
        pushax  #info_popup_help
        setax   #pu_err_title
        jmp     _show_select
.endproc

.rodata
mx_boot_error_info:
                .byte 19, 4, 0, $ff, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::text, 2, <mx_boot_error_msg, >mx_boot_error_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

.segment "SCR_DATA"
mx_boot_error_msg:
                .byte "Failed to boot with", 0
                .byte "  chosen options.", 0
