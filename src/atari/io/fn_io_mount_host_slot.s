        .export         _fn_io_mount_host_slot
        .import         _fn_io_copy_dcb, fn_io_hostslots
        .include        "atari.inc"
        .include        "zeropage.inc"
        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include         "../inc/dcb.inc"

; void _fn_io_mount_host_slot(slot_num)
; does nothing if first byte of host slot is 0
.proc _fn_io_mount_host_slot
        sta tmp1                ; save the slot number

        mwa     #fn_io_hostslots, ptr1
        
        ldx     tmp1
        beq     skip        ; index is already 0

        ; now move ptr1 on in blocks of size HostSlot for slot_num blocks
:       adw     ptr1, #.sizeof(HostSlot)
        dex
        bne :-

skip:
        ldy     #$00
        lda     (ptr1), y   ; first byte of host slot
        beq     out         ; nothing to do if it's 0 (null)

        setax   #t_io_mount_host_slot
        jsr     _fn_io_copy_dcb
        mva     tmp1, IO_DCB::daux1
        jmp     SIOV

out:
        rts
.endproc

.rodata
t_io_mount_host_slot:
        .byte $f9, $00, $00, $00, $0f, $00, $00, $00, $ff, $00
