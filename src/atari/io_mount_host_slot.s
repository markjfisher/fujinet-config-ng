; io_mount_host_slot.s
;

        .export         io_mount_host_slot
        .import         io_copy_dcb, io_hostslots, pushax
        .importzp       tmp1, ptr1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; *HostSlots[slot_num] io_mount_host_slot(slot_num)
; does nothing if first byte of host slot is 0
.proc io_mount_host_slot
        sta tmp1                ; save the slot number

        mwa #io_hostslots, ptr1
        
        ldx tmp1
        beq skip        ; index is already 0

        ; now move ptr1 on in blocks of size HostSlot for slot_num blocks
:       adw ptr1, #.sizeof(HostSlot)
        dex
        bne :-

skip:
        ldy #$00
        lda (ptr1), y   ; first byte of host slot
        beq out         ; nothing to do if it's 0 (null)

        pushax #t_io_mount_host_slot
        jsr io_copy_dcb
        mva tmp1, IO_DCB::daux1
        jmp SIOV

out:
        rts
.endproc

.data

t_io_mount_host_slot:
        .byte $f9, $00, $00, $00, $0f, $00, $00, $00, $ff, $00
