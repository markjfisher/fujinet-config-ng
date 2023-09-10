        .export     select_device_slot
        .export     pathfile_err_info

        .import     _clr_help
        .import     _scr_clr_highlight
        .import     _fn_io_close_directory
        .import     _fn_io_get_device_slots
        .import     _fn_io_put_device_slots
        .import     _fn_io_read_directory
        .import     _fn_io_set_device_filename
        .import     _put_help
        .import     _fc_strlcpy
        .import     _fc_strlen
        .import     _fc_strncpy
        .import     _free
        .import     _malloc
        .import     _show_select
        .import     md_is_devices_data_fetched
        .import     fn_dir_path
        .import     fn_io_buffer
        .import     fn_io_deviceslots
        .import     mh_host_selected
        .import     info_popup_help
        .import     pu_err_title
        .import     pusha
        .import     pushax
        .import     read_full_dir_name
        .import     s_empty

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

.proc select_device_slot
        jsr     _scr_clr_highlight

        ; handle the selection of a device slot for the given file from host
        ; we will put all the relevant selection details into memory starting at sds_pu_devs, and it
        ; is the job of the _show_select to display this, calling back to kb handler here

        ; get memory for 8 * devices list width strings
        lda     sds_pu_devs+2
        asl     a
        asl     a
        asl     a       ; * 8
        ldx     #$00

        jsr     _malloc
        axinto  sds_pu_devs+4
        jsr     copy_dev_strings

        ; show the selector
        pushax  #sds_pu_info
        pushax  #devices_help
        setax   #sds_msg
        jsr     _show_select
        sta     tmp1            ; save the return from select

        ; free the strings
        setax   sds_pu_devs+4
        jsr     _free

        ; CHECK IF ESC pressed (return value from _show_select is 0 for esc)
        lda     tmp1
        bne     save_device_choice

        ; ESC was pressed, don't do anything, the caller will simply reload main screen
        rts

save_device_choice:
        ; the selected option was sds_pu_devs+val
        ; the selected mode was sds_pu_mode+val
        mva     {sds_pu_devs + POPUP_VAL_IDX}, sds_dev     ; device slot is 0 based
        mva     {sds_pu_mode + POPUP_VAL_IDX}, sds_mode
        inc     sds_mode                                ; mode is 1/2, we have 0/1, add 1 to align

        ; set the device filename, this now works without need to save all slots
        pusha   sds_mode                ; read/write mode
        pusha   mh_host_selected           ; host_slot
        pusha   sds_dev                 ; device slot
        setax   #fn_io_buffer
        jsr     _fn_io_set_device_filename

        ; write it to the deviceslots memory
        mwa     #fn_io_deviceslots, ptr1
        ldx     sds_dev
        beq     no_dev_add
:       adw     ptr1, #.sizeof(DeviceSlot)
        dex
        bne     :-

no_dev_add:
        ; write the host slot
        lda     mh_host_selected
        ldy     #DeviceSlot::hostSlot
        sta     (ptr1), y

        ; write the mode
        lda     sds_mode
        ldy     #DeviceSlot::mode
        sta     (ptr1), y

        ; Save everything - bug was here for saving in A8? TODO check why fix to _fn_io_set_device_filename doesn't seem to be working - or is it another bug?
        setax   #fn_io_deviceslots
        jsr     _fn_io_put_device_slots

        ; read the device slots back so screen repopulates
        setax   #fn_io_deviceslots
        jsr     _fn_io_get_device_slots

        jmp     _fn_io_close_directory

copy_dev_strings:
        ; copy 8x width bytes from every DeviceSlot+2 into memory we grabbed
        ; if the entry is null, use s_empty instead

        ; have we loaded device slots yet?
        lda     md_is_devices_data_fetched
        bne     :+

        ; no! fetch them so we can see the entries
        setax   #fn_io_deviceslots
        jsr     _fn_io_get_device_slots
        mva     #$01, md_is_devices_data_fetched

:       mva     #$08, tmp1              ; number of strings in popup
        mwa     {sds_pu_devs + PopupItemTextList::text}, ptr1   ; dst, location of string buffer
        mwa     {#(fn_io_deviceslots + DeviceSlot::file)}, ptr2 ; src

l1:     pushax  ptr1    ; dst

        ; is src empty?
        ldy     #$00
        lda     (ptr2), y
        beq     empty

        pushax  ptr2    ; use device string, not empty.
        clc
        bcc     :+

empty:  pushax  #s_empty

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
sds_mode:       .res 1
sds_dev:        .res 1

; the device list is dynamic, so this can't be in RODATA
.data
; the width of textList should be 3 less than the overall width. 2 for list number and space, 1 for end selection char
; currently only lengths of 1-9 string list entries will work on screen. popup can have up to 12 items with header etc
sds_pu_info:    .byte 24, 0, 1, 0, 2           ; PopupItemInfo. width, y_offset, is_selectable, up/down = testList, l/r = option
sds_pu_devs:    .byte PopupItemType::textList, 8, 21, 0, $ff, $ff
sds_pu_spc1:    .byte PopupItemType::space
sds_pu_mode:    .byte PopupItemType::option,   2,  5, 0, <sds_mode_name, >sds_mode_name, <sds_opt1_spc, >sds_opt1_spc
sds_pu_end:     .byte PopupItemType::finish


.rodata

pathfile_err_info:
                .byte 24, 4, 0, $ff, $ff
                .byte PopupItemType::space
                .byte PopupItemType::string, 1, <pathfile_err_msg, >pathfile_err_msg
                .byte PopupItemType::space
                .byte PopupItemType::finish

.segment "SCR_DATA"

; option entry, first string 0 terminated "name", next strings are <len> chars exactly for entries
sds_mode_name:  .byte "Mode: ", 0
sds_mode_r:     .byte " R/O "
sds_mode_rw:    .byte " R/W "

; spacing for widgets. removes 200 bytes of code to calculate!
sds_opt1_spc:   .byte 3, 2, 3

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
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Choose"
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0

pathfile_err_msg:
                NORMAL_CHARMAP
                .byte "  Path + File too long", 0