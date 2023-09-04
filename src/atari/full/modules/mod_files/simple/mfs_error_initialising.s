        .export     mfs_error_initialising

        .import     _show_select
        .import     info_popup_help
        .import     mod_current
        .import     pu_err_title
        .import     pushax

        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"
        .include    "popup.inc"

.proc mfs_error_initialising

        pushax  #mfs_init_err_info
        pushax  #info_popup_help
        setax   #pu_err_title
        jsr     _show_select
        mva     #Mod::hosts, mod_current
        rts
.endproc

.rodata
mfs_init_err_info:
                .byte 26, 4, 0, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::string, 1, <mfs_init_err_msg, >mfs_init_err_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

.segment "SCREEN"
mfs_init_err_msg:
                .byte "  Error initialising!", 0
