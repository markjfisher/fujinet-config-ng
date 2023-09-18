        .export     mx_mount

        .import     _fn_io_get_device_slots
        .import     _fn_io_get_host_slots
        .import     _fn_io_mount_all
        .import     _pause
        .import     fn_io_deviceslots
        .import     fn_io_hostslots
        .import     return0
        .import     return1

        .include    "fc_macros.inc"

.proc mx_mount
        ; re-read the devices/hosts, the WebUI might have changed them etc.
        setax   #fn_io_deviceslots
        jsr     _fn_io_get_device_slots
        setax   #fn_io_hostslots
        jsr     _fn_io_get_host_slots

        lda     #10
        jsr     _pause      ; small pause to allow screen to continue showing "Mounting all" briefly

        ; MOUNT!
        jsr     _fn_io_mount_all
        cmp     #$01
        bne     error
        jmp     return0
error:  jmp     return1

.endproc
