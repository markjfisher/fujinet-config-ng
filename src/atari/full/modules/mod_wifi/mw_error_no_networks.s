        .export     mw_error_no_networks

        .import     _show_select
        .import     info_popup_help
        .import     pu_err_title
        .import     pushax

        .include    "fc_macros.inc"
        .include    "fn_io.inc"
        .include    "fc_mods.inc"
        .include    "popup.inc"

.proc mw_error_no_networks
        pushax  #mw_no_networks_info
        pushax  #info_popup_help
        setax   #pu_err_title
        jsr     _show_select
        rts
.endproc

.rodata
mw_no_networks_info:
                .byte 17, 5, 0, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::string, 1, <mw_no_networks_error_msg, >mw_no_networks_error_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

.segment "SCR_DATA"
mw_no_networks_error_msg:
                .byte " No networks", 0
