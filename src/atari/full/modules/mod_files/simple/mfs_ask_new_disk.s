        .export     mfs_ask_new_disk

        .import     _clr_help
        .import     _scr_clr_highlight
        .import     _show_select
        .import     mfs_ask_new_disk_std_info
        .import     mfs_ask_new_disk_pu_msg
        .import     pushax

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fc_mods.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"

.proc mfs_ask_new_disk
        jsr     _scr_clr_highlight
        pushax  #mfs_ask_new_disk_std_info
        pushax  #std_help
        setax   #mfs_ask_new_disk_pu_msg
        jsr     _show_select

        ; deal with return from select (type PopupItemReturn)

        rts

.endproc

.proc std_help
        jsr     _clr_help
;        put_help #0, #mfss_h1
        rts
.endproc