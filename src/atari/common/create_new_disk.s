        .export     _create_new_disk
        .export     t_disk_num_sectors
        .export     t_disk_sector_sizes
        .export     cnd_args

        .import     _fuji_create_new
        .import     _strncpy
        .import     debug
        .import     popa
        .import     popax
        .import     pushax
        .import     return0
        .import     return1

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fujinet-fuji.inc"
        .include    "fn_data.inc"
        .include    "fn_disk.inc"

; int create_new_disk(uint8_t host_slot, uint8_t device_slot, DiskSize size_index, 
;                     uint16_t cust_num_sectors, uint16_t cust_size_sectors, char *disk_path)
;
; creates new disk from params
; returns completed indicator, 0 = nothing written, 1 = disk created
; ptr1,ptr4; ptr1 is trashed by strncpy
.proc _create_new_disk
        mwa     #cnd_newdisk, ptr4

        ; convert selected_size into DiskSize index
        lda     cnd_args+CreateDiskArgs::size_index
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
        mway    {cnd_args+CreateDiskArgs::cust_num_sectors}, {(ptr4), y}

        ldy     #NewDisk::sectorSize
        mway    {cnd_args+CreateDiskArgs::cust_size_sectors}, {(ptr4), y}

        iny                     ; set to hostSlot index
        ; fall through to host/device

; -------------------------------------------------------------
; continue to host/device

        ; ----------------------------------------------------------------------
        ; hostSlot
:       lda     cnd_args+CreateDiskArgs::host_slot
        sta     (ptr4), y

        iny     ; move to deviceSlot index

        ; ----------------------------------------------------------------------
        ; deviceSlot
        lda     cnd_args+CreateDiskArgs::device_slot
        sta     (ptr4), y

        ; ----------------------------------------------------------------------
        ; filename - need location of this for strncpy
        ; ptr4 points to new disk buffer, we need to add offset to the filename
        adw     ptr4, #NewDisk::filename

        ; and copy the string there
        ; A is already ptr4
        ldx     ptr4+1
        jsr     pushax                                  ; dst
        pushax  cnd_args+CreateDiskArgs::disk_path      ; src
        setax   #$100                                   ; copy up to 256 bytes
        jsr     _strncpy        ; should we move entirely to standard version?

        ; restore ptr4 to start of buffer
        sbw     ptr4, #NewDisk::filename
        ; A is already ptr4
        ldx     ptr4+1
        jsr     pushax                                  ; dst
        ; pushax  ptr4
        jsr     _fuji_create_new
        ; TODO: react to result. Did it error?

        jmp     return1

.endproc

.bss
cnd_args:
        .tag    CreateDiskArgs

cnd_newdisk:
        .tag    NewDisk


.rodata
t_disk_num_sectors:
        .word  720, 1040,  720, 1440, 2880, 5760
t_disk_sector_sizes:
        .word  128,  128,  256,  256,  256,  256
