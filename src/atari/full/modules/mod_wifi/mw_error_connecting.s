        .export     mw_error_connecting

        .import     _show_select
        .import     info_popup_help
        .import     mod_current
        .import     pu_err_title
        .import     pushax

        .include    "fc_macros.inc"
        .include    "fn_io.inc"
        .include    "fc_mods.inc"
        .include    "popup.inc"

.proc mw_error_connecting
        pushax  #mw_connect_error_info
        pushax  #info_popup_help
        setax   #pu_err_title
        jsr     _show_select
        ; mva     #Mod::wifi, mod_current
        rts
.endproc

.rodata
mw_connect_error_info:
                .byte 21, 5, 0, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::string, 2, <mw_connect_error_msg, >mw_connect_error_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

.segment "SCR_DATA"
mw_connect_error_msg:
                .byte " Could not connect", 0
                .byte "    to network!", 0
