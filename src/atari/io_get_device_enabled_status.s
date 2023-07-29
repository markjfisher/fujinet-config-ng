        .export     io_get_device_enabled_status

; always true
.proc io_get_device_enabled_status
        lda #$01
        ldx #$00
        rts
.endproc
