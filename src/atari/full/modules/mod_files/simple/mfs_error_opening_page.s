        .export     mfs_error_opening_page

        .import     _show_select
        .import     info_popup_help
        .import     mod_current
        .import     pu_err_title
        .import     pushax

        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "popup.inc"

.proc mfs_error_opening_page
        pushax  #opendir_err_info
        pushax  #info_popup_help
        setax   #pu_err_title
        jsr     _show_select

        ; set next module as hosts
        mva     #Mod::hosts, mod_current
        rts

.endproc

.rodata
opendir_err_info:
                .byte 30, 4, 0, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::string, 1, <opendir_err_msg, >opendir_err_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

.segment "SCR_DATA"
opendir_err_msg:
                .byte "  Error Opening Directory!", 0
