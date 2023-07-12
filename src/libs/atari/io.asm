    .reloc
    .public io_init, io_error
    .public io_get_wifi_enabled, io_get_wifi_status
    ; .public io_get_ssid, io_set_ssid
    ; .public io_scan_for_networks, io_get_scan_result
    ; .public io_get_adapter_config
    ; .public io_get_device_slots, io_put_device_slots, io_set_device_filename, io_get_device_filename, io_get_device_enabled_status
    ; .public io_update_devices_enabled, io_enable_device, io_disable_device, io_device_slot_to_device, io_get_filename_for_device_slot
    ; .public io_get_host_slots, io_put_host_slots, io_mount_host_slot
    ; .public io_open_directory, io_read_directory, io_close_directory, io_set_directory_position, io_build_directory
    ; .public io_set_boot_config, io_boot
    ; .public io_mount_disk_image, io_umount_disk_image
    ; .public io_create_new, io_copy_file, io_mount_all

    icl "inc/antic.inc"
    icl "inc/gtia.inc"
    icl "inc/os.inc"
    icl "../macros.mac"

.proc io_init
    mva #$ff NOCLIK
    mva #$00 SHFLOK
    mva #$9f COLOR0
    mva #$0f COLOR1
    mva #$90 COLOR2
    sta      COLOR4
    mva #$01 COLDST
    mva #$00 SDMCTL
    rts
    .endp

; sets A to 0 (and thus Z flag) if no error, 127 otherwise (not-Z)
.proc io_error
    lda DSTATS
    and #$80
    rts
    .endp

; returns A=1 if enabled (not-Z), A=0 if disabled (Z)
.proc io_get_wifi_enabled
    .var wifi_enabled .byte

    set_sio_defaults
    mva #$ea DCOMND
    mva #$40 DSTATS
    mwa #wifi_enabled DBUFLO
    mwa #$01 DBYTLO  ; always unsure on this!
    mva #$00 DAUX1

    call_siov
    cpb wifi_enabled #$01
    bne @+
    lda #$01
    rts

@   lda #$00
    rts
    .endp

.proc io_get_wifi_status
    rts
    .endp
