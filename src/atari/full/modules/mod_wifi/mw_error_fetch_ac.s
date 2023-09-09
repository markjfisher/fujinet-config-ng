        .export     mw_error_fetch_ac

        .import     _show_select
        .import     info_popup_help
        .import     mod_current
        .import     pu_err_title
        .import     pushax

        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"
        .include    "popup.inc"

.proc mw_error_fetch_ac
        pushax  #mw_ac_err_info
        pushax  #info_popup_help
        setax   #pu_err_title
        jsr     _show_select
        mva     #Mod::wifi, mod_current
        rts
.endproc

.rodata
mw_ac_err_info:
                .byte 32, 4, 0, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::string, 1, <mw_ac_err_msg, >mw_ac_err_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

.segment "SCR_DATA"
mw_ac_err_msg:
                .byte "  Error loading adapter info!", 0
