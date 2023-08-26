        .export     _fn_io_create_new
        ; for exposing in Altirra:
        .export     t_disk_num_sectors, t_disk_sector_sizes, t_io_create_new

        .import     _fn_strncpy, fn_dir_path
        .import     popa, pushax
        .import     _fn_io_copy_dcb, _fn_io_dosiov
        .import     _malloc, _free

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"

; void _fn_io_create_new(uint8 selected_host_slot, uint8 selected_device_slot, uint16 selected_size)
.proc _fn_io_create_new
        axinto  fn_io_newsize    ; size (word) - one of 90, 130, ... etc. see below
        popa    tmp1    ; device_slot (byte)
        popa    tmp2    ; host_slot (byte)

        setax   #.sizeof(NewDisk)
        jsr     _malloc
        axinto  ptr2

        mwa     fn_io_newsize, ptr1
        mwa     ptr2, fn_io_newsize     ; this is done only for test to reach in and get the malloc address

        ; convert selected_size into DiskSize index
        cpw     ptr1, #90
        beq     s90
        cpw     ptr1, #130
        beq     s130
        cpw     ptr1, #180
        beq     s180
        cpw     ptr1, #360
        beq     s360
        cpw     ptr1, #720
        beq     s720
        cpw     ptr1, #1440
        beq     s1440

        ; TODO CUSTOM 999, for now just return as error
        jmp     cleanup
        ; implicit rts

s90:    ldx     #DiskSize::size90
        .byte   $2c     ; BIT
s130:   ldx     #DiskSize::size130
        .byte   $2c     ; BIT
s180:   ldx     #DiskSize::size180
        .byte   $2c     ; BIT
s360:   ldx     #DiskSize::size360
        .byte   $2c     ; BIT
s720:   ldx     #DiskSize::size720
        .byte   $2c     ; BIT
s1440:  ldx     #DiskSize::size1440

        ; Y now holds index of numSectors/sectorSize values to read from tables below

        ; I have no doubt there's a better way to do this.
        ; Storing num_sectors L/H values into allocated memory structure
        ; we are using y as ptr offset, but have to keep swapping it between load and set

        ; ----------------------------------------------------------------------
        ; numSectors
        lda     t_disk_num_sectors, x
        ldy     #NewDisk::numSectors
        sta     (ptr2), y

        ; HIGH byte
        inx

        lda     t_disk_num_sectors, x
        ldy     #NewDisk::numSectors + 1
        sta     (ptr2), y

        dex     ; reset x to index

        ; ----------------------------------------------------------------------
        ; sectorSize
        lda     t_disk_sector_sizes, x
        ldy     #NewDisk::sectorSize
        sta     (ptr2), y

        ; HIGH byte
        inx

        lda     t_disk_sector_sizes, x
        ldy     #NewDisk::sectorSize + 1
        sta     (ptr2), y

        ; ----------------------------------------------------------------------
        ; deviceSlot
        lda     tmp1
        ldy     #NewDisk::deviceSlot
        sta     (ptr2), y

        ; ----------------------------------------------------------------------
        ; hostSlot
        lda     tmp2
        ldy     #NewDisk::hostSlot
        sta     (ptr2), y

        ; ----------------------------------------------------------------------
        ; filename - need location of this for strncpy
        ; ptr2 points to allocated area, we need to add offset to the filename
        adw     ptr2, #NewDisk::filename

        ; and copy the string there
        pushax  ptr2            ; dst
        pushax  #fn_dir_path    ; src
        lda     #$e0            ; max length
        jsr     _fn_strncpy

        ; restore ptr2 to start of malloc location
        sbw     ptr2, #NewDisk::filename

;         ; THIS CODE IS FROM ORIGINAL C, but I don't think it's in the right place.
;         ; set the mode of the specific deviceslot
;         ; make ptr1 start at specific entry
;         mwa     #fn_io_deviceslots, ptr1
;         ldx     tmp1
;         beq     skip        ; nothing to add, we're on deviceslots[0]

; :       adw     ptr1, #.sizeof(DeviceSlot)
;         dex
;         bne     :-

; skip:
;         ldy     #DeviceSlot::mode
;         mva     fn_io_deviceslot_mode, {(ptr1), y}

        ; finally setup DCB and call SIOV
        setax   #t_io_create_new
        jsr     _fn_io_copy_dcb
        mwa     ptr2, IO_DCB::dbuflo
        jsr     _fn_io_dosiov

cleanup:
        setax   ptr2
        jsr     _free
        rts
.endproc

.bss
fn_io_newsize:  .res 2

.rodata
t_disk_num_sectors:
        .word  720, 1040,  720, 1440, 2880, 5760
t_disk_sector_sizes:
        .word  128,  128,  256,  256,  256,  256

.define NDsz .sizeof(NewDisk)

t_io_create_new:
        .byte $e7, $80, $ff, $ff, $fe, $00, <NDsz, >NDsz, $00, $00
