        .export     select_device_slot

        .export     mx_ask_help
        .export     sds_pu_device_val
        .export     sds_pu_mode_val
        .export     sds_pu_no_opt_devs

        .import     _clr_help
        .import     _fc_strncpy
        .import     _fuji_get_device_slots
        .import     _free
        .import     _malloc
        .import     _put_help
        .import     _scr_clr_highlight
        .import     _show_select
        .import     fuji_deviceslots
        .import     md_is_devices_data_fetched
        .import     pu_null_cb
        .import     pusha
        .import     pushax
        .import     _s_empty

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "fujinet-fuji.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

; tmp1,tmp2
; ptr1,ptr2,ptr3

; uint8_t select_device_slot(uint8_t with_mode)
;
; with_mode determines whether to show the R/O, R/W option or not (1=yes, 0=no)
; as it isn't required for New Disk option
.proc select_device_slot
        sta     tmp2                    ; store the with_mode flag
        jsr     _scr_clr_highlight

        ; handle the selection of a device slot for the given file from host
        ; we will put all the relevant selection details into memory starting at sds_pu_devs, and it
        ; is the job of the _show_select to display this, calling back to kb handler here

        ; get memory for 8 * devices list width strings - can't use fuji_buffer as that contains the file path we will use
        lda     sds_pu_devs + POPUP_LEN_IDX
        asl     a
        asl     a
        asl     a       ; * 8
        ldx     #$00

        jsr     _malloc
        ; store it into both rather than caring which is actually being shown
        axinto  sds_pu_devs + PopupItemTextList::text
        axinto  sds_pu_no_opt_devs + PopupItemTextList::text
        jsr     copy_dev_strings

        ; show the selector
        ; no cb handler needed for popup
        pushax  #pu_null_cb

        ; decide which version to show
        lda     tmp2
        beq     no_options

        pushax  #sds_pu_info
        clc
        bcc     :+

no_options:
        pushax  #sds_pu_no_opt_info

:       pushax  #devices_help
        setax   #sds_msg
        jsr     _show_select
        sta     tmp1

        ; free the strings in the device list display. they are for display only
        setax   sds_pu_devs + PopupItemTextList::text
        jsr     _free

        ; return the value from the popup so caller can react to Enter/ESC
        lda     tmp1
        rts

copy_dev_strings:
        ; copy 8x width bytes from every DeviceSlot+2 into memory we grabbed
        ; if the entry is null, use _s_empty instead

        ; have we loaded device slots yet?
        lda     md_is_devices_data_fetched
        bne     :+

        ; no! fetch them so we can see the entries
        pushax  #fuji_deviceslots
        ; setax    #$08 ; not required on atari
        jsr     _fuji_get_device_slots
        mva     #$01, md_is_devices_data_fetched

:       mva     #$08, tmp1              ; number of strings in popup
        mwa     {sds_pu_devs + PopupItemTextList::text}, ptr1   ; dst, location of string buffer
        mwa     {#(fuji_deviceslots + DeviceSlot::file)}, ptr2 ; src

l1:     pushax  ptr1    ; dst

        ; is src empty?
        ldy     #$00
        lda     (ptr2), y
        beq     empty

        pushax  ptr2    ; use device string, not empty.
        clc
        bcc     :+

empty:  pushax  #_s_empty

:       lda     sds_pu_devs + POPUP_LEN_IDX
        jsr     _fc_strncpy

        ; increment both src/dst pointers
        adw1    ptr1, {sds_pu_devs + POPUP_LEN_IDX}
        adw     ptr2, #.sizeof(DeviceSlot)

        dec     tmp1
        bne     l1

        rts

devices_help:
        jsr     _clr_help
        put_help #0, #mfss_h1
        rts
.endproc

.bss
sds_pu_device_val:      .res 1
sds_pu_mode_val:        .res 1


; SHOULD NOT be RODATA, the buffer isn't a fixed location, needs to be malloc'd

.data
; the width of textList should be 3+x_off less than the overall width. 2 for list number and space, 1 for end selection char
sds_pu_info:    .byte 28, 2, 1, 0, 2, $ff           ; width, y_offset, is_selectable, up/down = testList, l/r = option, edit field
sds_pu_devs:    .byte PopupItemType::textList, 8, 21, <sds_pu_device_val, >sds_pu_device_val, $ff, $ff, 2
                .byte PopupItemType::space
sds_pu_mode:    .byte PopupItemType::option, 2, 5, <sds_pu_mode_val, >sds_pu_mode_val, <sds_mode_name, >sds_mode_name, <sds_opt1_spc, >sds_opt1_spc
                .byte PopupItemType::finish

; NO OPTIONS VERSION
sds_pu_no_opt_info:
                .byte 28, 7, 1, 0, $ff, $ff           ; PopupItemInfo. width, y_offset, is_selectable, up/down = testList, l/r = option, edit field
sds_pu_no_opt_devs:
                .byte PopupItemType::textList, 8, 21, <sds_pu_device_val, >sds_pu_device_val, $ff, $ff, 2
                .byte PopupItemType::finish


.rodata

; option entry, first string 0 terminated "name", next strings are <len> chars exactly for entries
sds_mode_name:  .byte " Mode:  ", 0
sds_mode_r:     .byte " R/O "
sds_mode_rw:    .byte " R/W "

; spacing for widgets. removes 200 bytes of code to calculate!
sds_opt1_spc:   .byte 4, 2, 4

; ------------------------------------------------------------------
; Select Device Slot data
; ------------------------------------------------------------------
        NORMAL_CHARMAP
sds_msg:
        .byte "Select Device Slot", 0
        

mfss_h1:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move"
                NORMAL_CHARMAP
                .byte $81, "TAB", $82
                INVERT_ATASCII
                .byte "Next"
; reuse this section of the data for other popup helps
mx_ask_help:
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Choose"
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0
