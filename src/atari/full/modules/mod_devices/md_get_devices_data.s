        .export     _md_get_devices_data

        .import     _fuji_get_device_slots
        .import     fuji_deviceslots
        .import     md_is_devices_data_fetched
        .import     pushax

        .include    "macros.inc"

.proc _md_get_devices_data
        lda     md_is_devices_data_fetched
        bne     :+

        pushax  #fuji_deviceslots
        ; setax    #$08 ; not required on atari
        jsr     _fuji_get_device_slots
        mva     #$01, md_is_devices_data_fetched

:       rts
.endproc