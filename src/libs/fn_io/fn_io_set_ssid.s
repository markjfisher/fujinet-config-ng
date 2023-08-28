        .export         _fn_io_set_ssid
        .import          fn_io_copy_dcb, _fn_io_dosiov

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "fn_data.inc"

; void  fn_io_set_ssid(void *fn_io_net_config)
; sends the ssid to sio.
.proc _fn_io_set_ssid
        axinto  ptr1

        setax   #t_io_set_ssid
        jsr     fn_io_copy_dcb

        ; copy mem location to DCB, and call siov
        mwa     ptr1, IO_DCB::dbuflo
        jmp     _fn_io_dosiov
.endproc

.rodata
.define NCsz .sizeof(NetConfig)

t_io_set_ssid:
        .byte $fb, $80, $ff, $ff, $0f, $00, <NCsz, >NCsz, $01, $00
