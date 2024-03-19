        .export     _md_display_devices

        .import     fuji_deviceslots
        .import     mod_devices_show_list_num
        .import     pusha
        .import     pushax
        .import     show_list

        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"

.proc _md_display_devices

        pushax  #mod_devices_show_list_num
        pusha   #MAX_DEVICES
        pusha   #.sizeof(DeviceSlot)
        setax   #fuji_deviceslots+2    ; string is 2 chars in the struct
        jsr     show_list

        rts
.endproc