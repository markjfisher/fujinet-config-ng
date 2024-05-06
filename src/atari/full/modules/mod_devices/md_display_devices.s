        .export     _md_display_devices

        .import     show_list
        .import     sl_callback
        .import     sl_max_cnt
        .import     sl_size
        .import     sl_str_loc

        .import     fuji_deviceslots
        .import     mod_devices_show_list_num

        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"

.proc _md_display_devices
        mwa     #mod_devices_show_list_num, sl_callback
        mva     #MAX_DEVICES, sl_max_cnt
        mva     #.sizeof(DeviceSlot), sl_size
        mwa     #fuji_deviceslots+2, sl_str_loc
        jmp     show_list
.endproc