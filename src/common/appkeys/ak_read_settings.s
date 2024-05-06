        .export     ak_read_settings

        .import     ak_colour_idx
        .import     ak_version
        .import     _free
        .import     _fuji_appkey_open
        .import     _fuji_appkey_read
        .import     _fuji_appkey_write
        .import     _malloc
        .import     pushax

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fujinet-fuji.inc"

; read application settings from app keys

; uses ptr1, ptr2, tmp1, tmp7 (via appkey routines)

.proc   ak_read_settings
        ; allocate some memory for the app key data
        setax   #.sizeof(AppKeyDataBlock)
        jsr     _malloc
        axinto  ptr1            ; allocated memory for our data block

        ; set our key values
        lda     #$00            ; OPEN READ
        jsr     open_key

        beq     ak_err          ; ouch, unable to use APPKEY at all. we won't be able to save either, so just set to default values and bail out

        ; call "read", this can error if the given key doesn't exist yet
        setax   ptr1
        jsr     _fuji_appkey_read
        beq     no_cfg_key

        ; the data is now retrieved, so store it in our app state.
        ; we are using versioning to determine if there's more data or not, so can skip first 2 bytes of the length
        ldy     #$02
        lda     (ptr1), y       ; the version of the appkey data (like schema versioning)

        cmp     #$00
        beq     ak_v0

        ; fall through to bad data and creating default values again.

no_cfg_key:
        ; create default values, and write them back
        lda     #$00
        sta     ak_version
        sta     ak_colour_idx

        ; we have to OPEN again for WRITE
        lda     #$01
        jsr     open_key

        pushax  #$02            ; count of bytes
        setax   #ak_version     ; first byte to use for the location to save appkey from
        jsr     _fuji_appkey_write

        clc
        bcc     ak_end

ak_v0:
        sta     ak_version
        iny
        lda     (ptr1), y
        sta     ak_colour_idx

        clc
        bcc     ak_end

ak_err:
        lda     #$00
        sta     ak_version
        sta     ak_colour_idx
        ; fall through to freeing memory and returning

ak_end:
        setax   ptr1
        jsr     _free
        rts

open_key:
        sta     tmp1            ; store the mode
        setax   #ak_config_ng
        axinto  ptr2            ; table to read from

        ; copy open key data into block
        ldy     #$00
:       lda     (ptr2), y
        sta     (ptr1), y
        iny
        cpy     #$04            ; only loop for 4 main bytes
        bne     :-

        lda     tmp1            ; get mode back, 0 = read, 1 = write
        sta     (ptr1), y

        iny
        lda     #$00
        sta     (ptr1), y       ; reserved byte not used, but we set to 0

        ; try to "open" the key, this does not fetch anything, it just sets values in FN ready for read/write.
        setax   ptr1
        jmp     _fuji_appkey_open
        ; implicit rts

.endproc

.rodata

; https://github.com/FujiNetWIFI/fujinet-firmware/wiki/SIO-Command-$DC-Open-App-Key
ak_config_ng:
        .word $fe0c          ; creator id (fenrock)
        .byte $01            ; app-id (config-ng)
        .byte $01            ; key-id 01 = app settings, we only use 1 key at the moment, could use more if we want to store paths etc.
