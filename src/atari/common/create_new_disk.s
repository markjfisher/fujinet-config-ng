        .export     _create_new_disk
        .export     t_disk_num_sectors
        .export     t_disk_sector_sizes

        .import     _free
        .import     _fn_io_create_new
        .import     _malloc
        .import     _strncpy
        .import     debug
        .import     popa
        .import     popax
        .import     pushax
        .import     return0
        .import     return1

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"
        .include    "fn_disk.inc"

; THIS CODE IS NOT TESTED FULLY IN THIS FORM - IT WAS IN FN_IO LIB, NOW LIVES AS CLIENT FUNCTION

; int create_new_disk(uint8_t host_slot, uint8_t device_slot, DiskSize size_index, uint16_t cust_num_sectors, uint16_t cust_size_sectors, char *disk_path)
;
; creates new disk from params
; returns completed indicator, 0 = nothing written, 1 = disk created
; tmp1,tmp2,tmp3,tmp5/6,tmp7/8
; ptr3,ptr4 (malloc trashes ptr1/2)
.proc _create_new_disk
        axinto  ptr3            ; directory path src - this will need the full dir pre-pended to the disk name
        popax   tmp5            ; custom size, if size_index is custom
        popax   tmp7            ; custom sectors number, if size_index is custom
        popa    tmp3            ; size_index
        popa    tmp1            ; device_slot (byte)
        popa    tmp2            ; host_slot (byte)

        setax   #.sizeof(NewDisk)
        jsr     _malloc         ; this craps all over ptr 1/2
        axinto  ptr4

        ; convert selected_size into DiskSize index
        lda     tmp3
        cmp     #DiskSize::sizeCustom           ; is the given DiskSize value valid? should be less than sizeCustom for normal
        bcc     :+
        beq     do_custom                       ; custom size picked, need to handle params

        ; unmatched, just return 0
        jmp     return0

; -------------------------------------------------------------
; get sector size/num from tables

:       tax             ; A is disk-size, already doubled to table offset

        ; X now holds index of numSectors/sectorSize values to read from tables below

        ldy     #$00    ; index into NewDisk structure, go down it field by field. this is tied to exact structure of NewDisk
        ; ----------------------------------------------------------------------
        ; numSectors
        lda     t_disk_num_sectors, x
        sta     (ptr4), y

        ; HIGH byte
        inx
        iny

        lda     t_disk_num_sectors, x
        sta     (ptr4), y

        dex                     ; reset x to index
        iny                     ; next byte of NewDisk

        ; ----------------------------------------------------------------------
        ; sectorSize
        lda     t_disk_sector_sizes, x
        sta     (ptr4), y

        ; HIGH byte
        inx
        iny

        lda     t_disk_sector_sizes, x
        sta     (ptr4), y

        iny                     ; move to hostSlot index
        bne     :+              ; jump over custom routine

; -------------------------------------------------------------
; get sector size/num from custom values

do_custom:
        ; custom num sectors
        ldy     #NewDisk::numSectors
        mway    tmp7, {(ptr4), y}

        ldy     #NewDisk::sectorSize
        mway    tmp5, {(ptr4), y}

        iny                     ; set to hostSlot index
        ; fall through to host/device

; -------------------------------------------------------------
; continue to host/device

        ; ----------------------------------------------------------------------
        ; hostSlot
:       lda     tmp2
        sta     (ptr4), y

        iny     ; move to deviceSlot index

        ; ----------------------------------------------------------------------
        ; deviceSlot
        lda     tmp1
        sta     (ptr4), y

        ; ----------------------------------------------------------------------
        ; filename - need location of this for strncpy
        ; ptr4 points to new disk buffer, we need to add offset to the filename
        adw     ptr4, #NewDisk::filename

        ; and copy the string there
        pushax  ptr4            ; dst
        pushax  ptr3            ; src
        setax   #$100           ; copy up to 256 bytes
        jsr     _strncpy        ; should we move entirely to standard version?

        ; restore ptr4 to start of buffer
        sbw     ptr4, #NewDisk::filename
        pushax  ptr4
        jsr     _fn_io_create_new
        ; TODO: react to result. Did it error?

        setax   ptr4
        jsr     _free

        jmp     return1

.endproc

.rodata
t_disk_num_sectors:
        .word  720, 1040,  720, 1440, 2880, 5760
t_disk_sector_sizes:
        .word  128,  128,  256,  256,  256,  256
