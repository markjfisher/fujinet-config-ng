        .export     mfs_ask_new_disk

        .import     _show_select
        .import     pushax

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fc_mods.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"

.proc mfs_ask_new_disk
        ; show a popup with all the required inputs

        ; pushax  #sds_pu_info
        ; pushax  #devices_help
        ; setax   #sds_msg
        ; jsr     _show_select

        ; deal with return from select (type PopupItemReturn)

        rts

.endproc