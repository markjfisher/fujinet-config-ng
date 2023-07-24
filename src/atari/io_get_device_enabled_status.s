; io_get_device_enabled_status.s

        .export     io_get_device_enabled_status

.proc io_get_device_enabled_status
        lda #$01
        rts
.endproc
