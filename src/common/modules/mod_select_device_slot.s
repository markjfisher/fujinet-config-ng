        .export     mod_select_device_slot

        .import     pusha, pushax
        .import     _fn_popup

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"


.proc mod_select_device_slot
        ; handle the selection of a device slot for the given file from host

        ; this mod will create a small pop up window allowing the user to pick from 8 device lines
        pusha   #$08    ; number of lines to display
        pushax  #sds_msg
        ; what values to show?
        setax   #sds_selected
        jsr     _fn_popup

        ; the chosen value is in sds_selected

        rts
.endproc



.bss
sds_selected:   .byte 1

.segment "SCREEN"

        INVERT_ATASCII
sds_msg:
        .byte "Select Device Slot", 0
        NORMAL_CHARMAP