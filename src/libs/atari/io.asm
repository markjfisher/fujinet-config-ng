    .reloc
    .public io_init, io_error
    .public io_get_wifi_enabled, io_get_wifi_status
    .public io_get_ssid, io_set_ssid
    .public io_scan_for_networks, io_get_scan_result
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
    
    icl "inc/io.inc"

; ##################################################################################
; some basic setup
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

; ##################################################################################
; sets A to 0 (and thus Z flag) if no error, 127 otherwise (not-Z)
.proc io_error
    lda DSTATS
    and #$80
    rts
    .endp

; ##################################################################################
; returns A=1 if enabled (not-Z), A=0 if disabled (Z)
.proc io_get_wifi_enabled
    .var wifi_enabled .byte

    set_sio_defaults
    mva #$ea DCOMND     ; Get WiFi enabled - TODO: Wiki undocumented
    mva #$40 DSTATS
    mwa #wifi_enabled DBUFLO
    mwa #$01 DBYTLO
    mva #$00 DAUX1

    call_siov
    cpb wifi_enabled #$01
    bne @+
    lda #$01
    rts

@   lda #$00
    rts
    .endp


; ##################################################################################
; Returns: status from SIO call in A for this command
;
; Return values are:
;  1: No SSID available
;  3: Connection Successful
;  4: Connect Failed
;  5: Connection lost
.proc io_get_wifi_status
    .var status .byte

    ; TODO: C version has a 1 second delay here.

    set_sio_defaults
    mva #$fa DCOMND     ; Get WiFi Status
    mva #$40 DSTATS
    mwa #status DBUFLO
    mwa #$01 DBYTLO
    mva #$00 DAUX1

    call_siov

    ; return status in A
    lda status

    rts
    .endp

; ##################################################################################
; sets the current SSID information into memory, and returns
; it's address in (A,X)
.proc io_get_ssid
    .var nc NetConfig

    set_sio_defaults
    mva #$fe DCOMND         ; Get SSID
    mva #$40 DSTATS
    mwa #nc DBUFLO
    mwa #.sizeof(NetConfig) DBYTLO
    mva #$00 DAUX1

    call_siov
    lda <nc
    ldx >nc

    rts
    .endp

; ##################################################################################
; sends SSID information to SIO.
; param: (A,X) contains the address of the memory structure to send
.proc io_set_ssid
    ; before we lose them, store A,X
    sta DBUFLO
    stx DBUFHI
    set_sio_defaults
    mva #$fb DCOMND         ; Set SSID
    mva #$80 DSTATS
    mwa #.sizeof(NetConfig) DBYTLO
    mva #$01 DAUX1

    call_siov
    rts
    .endp

; ##################################################################################
; call SIOV with 0xFD and pass in location of buffer
; returns: X = num of networks - Arbitrary picking X. Maybe a new standard for single byte returns
.proc io_scan_for_networks
    set_sio_defaults
    mva #$fd DCOMND         ; Scan networks
    mva #$40 DSTATS
    mwa #$04 DBYTLO
    mva #$00 DAUX1
    mwa #response DBUFLO

    call_siov
    ; put first byte of response into X
    ldx response

    rts
    .endp

; ##################################################################################
; Parameter: A = index of network to get results for
; returns: A/X = location of SSIDInfo memory
.proc io_get_scan_result
    .var info SSIDInfo

    ; network index in A
    sta DAUX1

    set_sio_defaults
    mva #$fc DCOMND         ; Get Scan Result
    mva #$40 DSTATS
    mwa #info DBUFLO
    mwa #.sizeof(SSIDInfo) DBYTLO

    call_siov
    lda <info
    ldx >info

    rts
    .endp

; ##################################################################################
; buffer for transfers
response :512 .byte
