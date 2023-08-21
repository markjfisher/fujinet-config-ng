        .export     select_device_slot

        .import     pusha, pushax, popa, popax
        .import     _fn_popup_select, fn_io_buffer
        .import     _fn_io_set_device_filename
        .import     _fn_io_put_device_slots
        .import     _fn_io_get_device_slots
        .import     _fn_strncpy
        .import     _fn_clr_highlight
        .import     fn_io_deviceslots
        .import     _malloc, _free
        .import     s_empty
        .import     _show_select
        .import     debug, _fn_pause
        .import     devices_fetched

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"
        .include    "fn_popup_item.inc"

.proc select_device_slot
        jsr     _fn_clr_highlight

        ; handle the selection of a device slot for the given file from host
        ; we will put all the relevant selection details into memory starting at pu_devs, and it
        ; is the job of the _show_select to display this, calling back to kb handler here

        ; get memory for 8 * devices list width strings
        lda     pu_devs+2
        asl     a
        asl     a
        asl     a       ; * 8
        ldx     #$00

        jsr     _malloc
        axinto  pu_devs+4
        jsr     copy_dev_strings

        ; show the selector
        pusha   pu_width
        pushax  #pu_devs
        setax  #sds_msg
        ; setax   #kb_handler
        jsr     _show_select    ; device specific routine to handle showing selection. alters .val in structure
        sta     tmp1            ; save the return from select

        ; free the strings
        setax   pu_devs+4
        jsr     _free

        ; CHECK IF ESC pressed (return value from _show_select)
        lda     tmp1
        beq     save_device_choice

        ; ESC was pressed, don't do anything, the caller will simply reload main screen
        rts

save_device_choice:
        ; pull out byte 3 of each pu_* to see what options were chosen

        ; TODO: LINK UP OPTIONS CHOSEN
        rts

        ; convert these into something to mount the device slot with

        ; TEST CODE BELOW - NEED TO ADD VALUES FROM ABOVE HERE        
        ; try it out first, let's put a string into fn_io_buffer
        pushax  #fn_io_buffer   ; dst
        pushax  #test_msg       ; src
        lda     #$e0            ; len
        jsr     _fn_strncpy

        ; set the device filename, this now works without need to save all slots
        pusha   #$02    ; read/write mode
        pusha   #$01    ; host_slot, pretend we were currently in host 1
        lda     #$01    ; device slot, pretend slot 1
        jsr     _fn_io_set_device_filename

        ; read the device slots back so screen repopulates
        jsr     _fn_io_get_device_slots

        rts

; kb_handler:
;         ; handle ESC. other keys probably generic
;         rts

copy_dev_strings:
        ; copy 8x width bytes from every DeviceSlot+2 into memory we grabbed
        ; if the entry is null, use s_empty instead

        ; have we loaded device slots yet?
        lda     devices_fetched
        bne     :+

        ; no! fetch them so we can see the entries
        jsr     _fn_io_get_device_slots
        mva     #$01, devices_fetched

:       mva     #$08, tmp1
        mwa     pu_devs+4, ptr1                                 ; dst
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

:       lda     pu_devs + PopupItem::len
        jsr     _fn_strncpy

        ; increment both src/dst pointers
        adw1    ptr1, {pu_devs + PopupItem::len}
        adw     ptr2, #.sizeof(DeviceSlot)

        dec     tmp1
        bne     l1

        rts
.endproc

.data
pu_width:       .byte 24
; the width of textList should be 3 less than the overall width. 2 for list number and space, 1 for end selection char
; currently only lengths of 1-9 string list entries will work on screen. popup can have up to 12 items with header etc
pu_devs:        .byte PopupItemType::textList, 8, 21, 0, $ff, $ff, 0, 0
pu_spc1:        .byte PopupItemType::space,    0,  0, 0,   0,   0, 0, 0         ; extra 6 bytes is shorter than code to skip
pu_mode:        .byte PopupItemType::option,   2,  5, 0, <sds_mode_name, >sds_mode_name, <sds_opt1_spc, >sds_opt1_spc
pu_end:         .byte PopupItemType::finish,   0, 0, 0, 0, 0, 0, 0              ; again, less bytes putting this here than faff if not.

.segment "SCREEN"
        INVERT_ATASCII
sds_msg:
        .byte "   Select Device Slot   "
        NORMAL_CHARMAP

; option entry, first string 0 terminated "name", next strings are <len> chars exactly for entries
sds_mode_name:  .byte "Mode: ", 0
sds_mode_r:     .byte "  R  "
sds_mode_rw:    .byte " R/W "

; spacing for widgets. removes 200 bytes of code to calculate!
sds_opt1_spc:   .byte 3, 2, 3

test_msg:       .byte "/this/path/to/somewhere4.atx", 0