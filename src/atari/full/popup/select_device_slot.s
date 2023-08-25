        .export     select_device_slot

        .import     pusha, pushax
        .import     fn_io_buffer, fn_dir_path
        .import     _fn_io_set_device_filename
        .import     _fn_io_put_device_slots
        .import     _fn_io_get_device_slots
        .import     _fn_strncpy, _fn_strlen, _fn_strncat
        .import     _fn_clr_highlight
        .import     _fn_io_read_directory
        .import     _fn_io_close_directory
        .import     fn_io_deviceslots
        .import     _malloc, _free
        .import     s_empty
        .import     _show_select
        .import     devices_fetched
        .import     host_selected
        .import     get_to_dir_pos
        .import     sds_msg
        .import     debug

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"
        .include    "popup.inc"

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
        setax   #sds_msg
        jsr     _show_select
        sta     tmp1            ; save the return from select

        ; free the strings
        setax   pu_devs+4
        jsr     _free

        ; CHECK IF ESC pressed (return value from _show_select is 0 for esc)
        lda     tmp1
        bne     save_device_choice

        ; ESC was pressed, don't do anything, the caller will simply reload main screen
        rts

save_device_choice:
        ; the selected option was pu_devs+val
        ; the selected mode was pu_mode+val
        mva     {pu_devs + PopupItem::val}, sds_dev     ; device slot is 0 based
        mva     {pu_mode + PopupItem::val}, sds_mode
        inc     sds_mode                                ; mode is 1/2, we have 0/1, add 1 to align

        jsr     get_to_dir_pos                          ; get ourselves at the directory position

        ; do a 255 byte read of current dir entry (file)
        pusha   #$ff
        lda     #$00
        jsr     _fn_io_read_directory

        ; copy fn_io_buffer result to RAM, as we need to play around with buffers
        setax   #fn_io_buffer
        jsr     _fn_strlen
        sta     tmp1            ; save the file name's length
        jsr     _malloc
        axinto  ptr1            ; ptr1 must be freed later

        ; copy io_buffer into our memory location
        jsr     pushax          ; A/X already set correctly to RAM allocated for copy (dst)
        pushax  #fn_io_buffer   ; src
        lda     tmp1            ; length
        clc
        adc     #$01            ; 1 extra for 0 terminator
        jsr     _fn_strncpy
        
        ; put a zero at end of name to terminate string
        ldy     tmp1
        lda     #$00
        sta     fn_io_buffer, y

        ; copy path into buffer
        pushax  #fn_io_buffer
        pushax  #fn_dir_path
        lda     #$ff            ; path is only $e0, but specifying more ensures we blank out rest of buffer
        jsr     _fn_strncpy

        ; how large is path?
        setax   #fn_io_buffer
        jsr     _fn_strlen
        sta     tmp2

        ; calculate how much space we have left in buffer for copying file names
        lda     #$fe            ; drop 1 to ensure there's a 0 at the end of whole buffer to stop overrun
        sec
        sbc     tmp1            ; file name
        sbc     tmp2            ; path
        sta     tmp1

        ; now append the file name onto this
        pushax  #fn_io_buffer
        pushax  ptr1
        lda     tmp1
        jsr     _fn_strncat

        ; free up the temp buffer
        setax   ptr1
        jsr     _free

        ; we now finally have fn_io_buffer with our /path/filename, ready to call set_device
        ; set the device filename, this now works without need to save all slots
        pusha   sds_mode                ; read/write mode
        pusha   host_selected           ; host_slot
        lda     sds_dev                 ; device slot
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
        lda     host_selected
        ldy     #DeviceSlot::hostSlot
        sta     (ptr1), y

        ; write the mode
        lda     sds_mode
        ldy     #DeviceSlot::mode
        sta     (ptr1), y

        ; Save everything - bug was here for saving in A8? TODO check why fix to _fn_io_set_device_filename doesn't seem to be working - or is it another bug?
        jsr     _fn_io_put_device_slots

        ; read the device slots back so screen repopulates
        jsr     _fn_io_get_device_slots
        jmp     _fn_io_close_directory

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

.bss
sds_mode:       .res 1
sds_dev:        .res 1

.data
pu_width:       .byte 24
; the width of textList should be 3 less than the overall width. 2 for list number and space, 1 for end selection char
; currently only lengths of 1-9 string list entries will work on screen. popup can have up to 12 items with header etc
pu_devs:        .byte PopupItemType::textList, 8, 21, 0, $ff, $ff, 0, 0
pu_spc1:        .byte PopupItemType::space,    0,  0, 0,   0,   0, 0, 0         ; extra 6 bytes is shorter than code to skip
pu_mode:        .byte PopupItemType::option,   2,  5, 0, <sds_mode_name, >sds_mode_name, <sds_opt1_spc, >sds_opt1_spc
pu_end:         .byte PopupItemType::finish,   0, 0, 0, 0, 0, 0, 0              ; again, less bytes putting this here than faff if not.

.segment "SCREEN"

; option entry, first string 0 terminated "name", next strings are <len> chars exactly for entries
sds_mode_name:  .byte "Mode: ", 0
sds_mode_r:     .byte " R/O "
sds_mode_rw:    .byte " R/W "

; spacing for widgets. removes 200 bytes of code to calculate!
sds_opt1_spc:   .byte 3, 2, 3
