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
        .import     debug
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

        ; get memory for 8x22 strings
        setax   #(8*22)
        jsr     _malloc
        axinto  pu_devs+4
        jsr     copy_dev_strings

        ; show the selector
        pusha   #22
        pushax  #pu_devs
        pushax  #sds_msg
        setax   #kb_handler
        jsr     _show_select     ; device specific routine to handle showing selection. alters .val in structure

        ; free the strings
        setax   pu_devs+4

        jsr     _free

        ; pull out byte 3 of each pu_* to see what options were chosen

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

kb_handler:
        ; handle ESC. other keys probably generic
        rts

copy_dev_strings:
        ; copy 8x 22 bytes from every DeviceSlot+2 into memory we grabbed
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

:       lda     #22
        jsr     _fn_strncpy

        ; increment both src/dst pointers
        adw     ptr1, #22
        adw     ptr2, #.sizeof(DeviceSlot)

        dec     tmp1
        bne     l1

        rts
.endproc

.data
pu_devs:        .byte PopupItemType::textList, 8, 22, 0, $ff, $ff
pu_mode:        .byte PopupItemType::option,   2,  4, 0, <sds_mode_r, >sds_mode_r
pu_end:         .byte PopupItemType::finish

.segment "SCREEN"
        INVERT_ATASCII
sds_msg:
        .byte "  Select Device Slot  "
        NORMAL_CHARMAP

; both must be 4 chars wide
sds_mode_r:     .byte " R ", 0
sds_mode_rw:    .byte "R/W", 0

test_msg:       .byte "/this/path/to/somewhere4.atx", 0