        .export     _md_display_devices

        .import     fn_io_deviceslots
        .import     mod_devices_show_list_num
        .import     pusha
        .import     pushax
        .import     show_list

        .import     debug, _pause

        .include    "fn_macros.inc"
        .include    "fn_io.inc"

.proc _md_display_devices

        pushax  #mod_devices_show_list_num
        pusha   #.sizeof(DeviceSlot)
        setax   #fn_io_deviceslots+2    ; string is 2 chars in the struct
        jsr     show_list

        rts
.endproc