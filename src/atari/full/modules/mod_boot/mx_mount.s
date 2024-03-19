        .export     mx_mount

        .import     _fuji_error
        .import     _fuji_get_device_slots
        .import     _fuji_get_host_slots
        .import     _fuji_mount_all
        .import     _pause
        .import     fuji_deviceslots
        .import     fuji_hostslots
        .import     pushax
        .import     return0
        .import     return1

        .import     debug

        .include    "macros.inc"

.proc mx_mount
        ; re-read the devices/hosts, the WebUI might have changed them etc.
        pushax  #fuji_deviceslots
        ; setax    #$08 ; not required on atari
        jsr     _fuji_get_device_slots
        pushax  #fuji_hostslots
        ; setax    #$08 ; not required on atari
        jsr     _fuji_get_host_slots

        lda     #$08
        jsr     _pause      ; small pause to allow screen to continue showing "Mounting all" briefly

        ; MOUNT!
        jsr     _fuji_mount_all
        cmp     #$01
        bne     error
        jmp     return0
error:  jmp     return1

.endproc
