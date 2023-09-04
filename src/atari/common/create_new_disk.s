        .export     _create_new_disk
        .export     t_disk_num_sectors
        .export     t_disk_sector_sizes

        .import     _fn_io_create_new
        .import     _strncpy
        .import     popa
        .import     popax
        .import     pushax
        .import     return0
        .import     return1

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"

; THIS CODE IS NOT TESTED FULLY IN THIS FORM - IT WAS IN FN_IO LIB, NOW LIVES AS CLIENT FUNCTION

; int create_new_disk(uint8_t host_slot, uint8_t device_slot, DiskSize size_index, uint16_t cust_num_sectors, uint16_t cust_size_sectors, char *disk_path)
;
; creates new disk from params
; returns completed indicator, 0 = nothing written, 1 = disk created
.proc _create_new_disk
        axinto  ptr3            ; directory path src
        popax   ptr1            ; custom size, if size_index is custom
        popax   ptr2            ; custom sectors number, if size_index is custom
        popa    tmp3            ; DiskSize
        popa    tmp1            ; device_slot (byte)
        popa    tmp2            ; host_slot (byte)

        ; TODO: malloc NewDisk size into ptr4
        popax   ptr4            ; buffer for new disk, caller responsible for memory. IMPORTANT! ptr4 not trashed by _strncpy


        ; convert selected_size into DiskSize index
        lda     tmp3
        cmp     #DiskSize::sizeCustom           ; is the given DiskSize value valid? should be less than sizeCustom for normal
        bcc     :+
        beq     do_custom                       ; custom size picked, need to handle params

        ; unmatched, just return 0
        jmp     return0
        ; implicit rts

; -------------------------------------------------------------
; get sector size/num from tables

:       asl     a       ; double a so it becomes table index
        tax

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
        mway    ptr2, {(ptr4), y}

        ldy     #NewDisk::sectorSize
        mway    ptr1, {(ptr4), y}

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
        jsr     _strncpy        ; this leaves only ptr4 intact

        ; restore ptr4 to start of buffer
        sbw     ptr4, #NewDisk::filename
        pushax  ptr4
        jsr     _fn_io_create_new

        jmp     return1

.endproc

.rodata
t_disk_num_sectors:
        .word  720, 1040,  720, 1440, 2880, 5760
t_disk_sector_sizes:
        .word  128,  128,  256,  256,  256,  256
