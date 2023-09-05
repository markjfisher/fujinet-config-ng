        .export     mfs_error_too_long

        .import     _show_select
        .import     info_popup_help
        .import     pu_err_title
        .import     pushax

        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"
        .include    "popup.inc"

.proc mfs_error_too_long
        pushax  #p2l_err_info
        pushax  #info_popup_help
        setax   #pu_err_title
        jmp     _show_select
.endproc

.rodata
p2l_err_info:
                .byte 16, 4, 0, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::string, 1, <p2l_err_msg, >p2l_err_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

.segment "SCREEN"
                NORMAL_CHARMAP
p2l_err_msg:
                .byte " Path too long!", 0
