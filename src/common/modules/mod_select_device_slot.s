        .export     mod_select_device_slot

        .import     pusha, pushax
        .import     _fn_popup_select, fn_io_buffer

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"


; TODO: DECIDE IF THIS IS A FULL MOD OR JUST A FUNCTION
; do we need to be able to return to where we were?
; e.g. press ESC to not mount the device, you'd want to come back to where you were, which isn't easy if we jump out to module handler


.proc mod_select_device_slot
        ; handle the selection of a device slot for the given file from host

        ; we need space for 8 x 22 strings just to show versions of the currently loaded devices

        ; create a pop up window allowing the user to pick from 8 device lines
        pusha   #22                     ; width of the strings to input
        pushax  #fn_io_buffer           ; the strings to display
        pushax  #sds_msg                ; the message to display
        pushax  #kb_handler             ; deal with key presses
        setax   #sds_selected           ; the location to set the 'choice' from popup
        jsr     _fn_popup_select

        ; the chosen value is in sds_selected

        rts

kb_handler:
        rts

.endproc



.bss
sds_selected:   .res 1


.segment "SCREEN"

        INVERT_ATASCII
sds_msg:
        .byte "Select Device Slot", 0
        NORMAL_CHARMAP