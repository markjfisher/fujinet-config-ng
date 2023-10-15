        .export     _md_get_devices_data

        .import     _fn_io_get_device_slots
        .import     fn_io_deviceslots
        .import     md_is_devices_data_fetched

        .include    "macros.inc"

.proc _md_get_devices_data
        lda     md_is_devices_data_fetched
        bne     :+

        setax   #fn_io_deviceslots
        jsr     _fn_io_get_device_slots
        mva     #$01, md_is_devices_data_fetched

:       rts
.endproc