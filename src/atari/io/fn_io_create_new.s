        .export     _fn_io_create_new
        ; for exposing in Altirra:
        .export     fn_new_disk, t_disk_num_sectors, t_disk_sector_sizes, t_io_create_new

        .include    "atari.inc"
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .import     _fn_io_siov, _fn_strncpy
        .import     fn_io_deviceslots, fn_io_deviceslot_mode, fn_dir_path
        .import     popax, popa, pushax

; void _fn_io_create_new(uint8 selected_host_slot, uint8 selected_device_slot, uint16 selected_size)
.proc _fn_io_create_new
        getax   ptr1    ; size (word) - one of 90, 130, ... etc. see below
        popa    tmp1    ; device_slot (byte)
        popa    tmp2    ; host_slot (byte)

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
        rts

s90:    ldy     #DiskSize::size90
        .byte   $2c     ; BIT
s130:   ldy     #DiskSize::size130
        .byte   $2c     ; BIT
s180:   ldy     #DiskSize::size180
        .byte   $2c     ; BIT
s360:   ldy     #DiskSize::size360
        .byte   $2c     ; BIT
s720:   ldy     #DiskSize::size720
        .byte   $2c     ; BIT
s1440:  ldy     #DiskSize::size1440

        ; Y now holds index of numSectors/sectorSize values to read from tables below

        ; copy num_sectors param into newdisk
        mwa     #t_disk_num_sectors, ptr1
        mva     {(ptr1), y}, {fn_new_disk + NewDisk::numSectors}
        iny
        mva     {(ptr1), y}, {fn_new_disk + NewDisk::numSectors + 1}
        dey     ; reset y to index

        ; copy sector_size param into newdisk
        mwa     #t_disk_sector_sizes, ptr1
        mva     {(ptr1), y}, {fn_new_disk + NewDisk::sectorSize}
        iny
        mva     {(ptr1), y}, {fn_new_disk + NewDisk::sectorSize + 1}

        ; set the newdisk.hostSlot and deviceSlot
        mva     tmp1, {fn_new_disk + NewDisk::deviceSlot}
        mva     tmp2, {fn_new_disk + NewDisk::hostSlot}

        ; copy path into newdisk.filename
        pushax  #fn_new_disk+NewDisk::filename   ; dst
        pushax  #fn_dir_path                        ; src
        lda     #$e0                                ; max length
        jsr     _fn_strncpy

        ; WHY? This feels out of place: TODO - move this to more appropriate place

        ; set the mode of the specific deviceslot
        ; make ptr1 start at specific entry
        mwa     #fn_io_deviceslots, ptr1
        ldx     tmp1
        beq     skip        ; nothing to add, we're on deviceslots[0]

:       adw     ptr1, #.sizeof(DeviceSlot)
        dex
        bne     :-

skip:
        ldy     #DeviceSlot::mode
        mva     fn_io_deviceslot_mode, {(ptr1), y}

        ; END: WHY?

        ; finally setup DCB and call SIOV
        setax   #t_io_create_new
        jmp     _fn_io_siov
.endproc

.bss
fn_new_disk:    .tag NewDisk

.rodata
t_disk_num_sectors:
        .word  720, 1040,  720, 1440, 2880, 5760
t_disk_sector_sizes:
        .word  128,  128,  256,  256,  256,  256

.define NDsz .sizeof(NewDisk)

t_io_create_new:
        .byte $e7, $80, <fn_new_disk, >fn_new_disk, $fe, $00, <NDsz, >NDsz, $00, $00
