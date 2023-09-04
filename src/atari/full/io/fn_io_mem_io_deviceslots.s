        .export fn_io_deviceslots
        .include    "fn_io.inc"

; 304 bytes, but it stops us doing SIO everytime enter the devices module screen
.segment "BUFFER"
fn_io_deviceslots:      .res 8 * .sizeof(DeviceSlot)

; .data
; this is used in "new disk", only seems to be changed on user input in original C in "input_select_slot_choose"
; which is the mounting mode? ESC = 0 (default), W = 2, other (R) = 1
; fn_io_deviceslot_mode:  .byte 0
