        .export     _fn_io_get_device_enabled_status

; always true
.proc _fn_io_get_device_enabled_status
        lda     #$01
        ldx     #$00
        rts
.endproc
