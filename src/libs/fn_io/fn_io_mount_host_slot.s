        .export         _fn_io_mount_host_slot
        .import         fn_io_copy_dcb, fn_io_hostslots, _fn_io_dosiov
        .import         popa

        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include         "fn_data.inc"

; void fn_io_mount_host_slot(uint8_t slot_num, HostSlot *host_slots)
; does nothing if first byte of host slot is 0
.proc _fn_io_mount_host_slot
        axinto  ptr1
        popa    tmp1        ; save the slot number

        tax
        beq     skip        ; index is already 0

        ; now move ptr1 on in blocks of size HostSlot for slot_num blocks
:       adw     ptr1, #.sizeof(HostSlot)
        dex
        bne     :-

skip:
        ldy     #$00
        lda     (ptr1), y   ; first byte of host slot
        beq     out         ; nothing to do if it's 0 (null)

        setax   #t_io_mount_host_slot
        jsr     fn_io_copy_dcb
        mva     tmp1, IO_DCB::daux1
        jmp     _fn_io_dosiov

out:
        rts
.endproc

.rodata
t_io_mount_host_slot:
        .byte $f9, $00, $00, $00, $0f, $00, $00, $00, $ff, $00
