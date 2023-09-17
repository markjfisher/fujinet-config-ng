        .export mf_create_new

        .import     _create_new_disk

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

.proc mf_create_new
        jmp     _create_new_disk

.endproc