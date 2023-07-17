    .public io_init, io_error
    .public io_get_wifi_enabled, io_get_wifi_status
    .public io_get_ssid, io_set_ssid
    .public io_scan_for_networks, io_get_scan_result
    .public io_get_adapter_config
    .public io_get_device_slots, io_put_device_slots
    .public io_set_device_filename, io_get_device_filename, io_get_device_enabled_status
    .public io_update_devices_enabled, io_enable_device, io_disable_device
    .public io_device_slot_to_device ; NOT DOING: io_get_filename_for_device_slot
    .public io_get_host_slots, io_put_host_slots, io_mount_host_slot
    .public io_open_directory, io_read_directory, io_close_directory, io_set_directory_position, io_build_directory
    ; .public io_set_boot_config, io_boot
    ; .public io_mount_disk_image, io_umount_disk_image
    ; .public io_create_new, io_copy_file, io_mount_all

    ; Public access to buffers and arrays
    .public iobuffer
    .public deviceSlots
    .public hostSlots

    .reloc

    .extrn t1, t2 .byte
    .extrn strncpy, strncat .proc

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
.proc io_error ( .byte a ) .reg
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
    mwa #$00 DAUX

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
    mwa #$00 DAUX

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
    mwa #$00 DAUX

    call_siov
    lda <nc
    ldx >nc

    rts
    .endp

; ##################################################################################
; sends SSID information to SIO.
; params: (A,X) contains the address of the memory structure to send
.proc io_set_ssid ( .byte a, x ) .reg
    sta DBUFLO
    stx DBUFHI
    set_sio_defaults
    mva #$fb DCOMND         ; Set SSID
    mva #$80 DSTATS
    mwa #.sizeof(NetConfig) DBYTLO
    mwa #$01 DAUX

    call_siov
    rts
    .endp

; ##################################################################################
; returns: A = num of networks
.proc io_scan_for_networks
    set_sio_defaults
    mva #$fd DCOMND         ; Scan networks
    mva #$40 DSTATS
    mwa #$04 DBYTLO
    mwa #$00 DAUX
    mwa #iobuffer DBUFLO

    call_siov
    ; put first byte of iobuffer into X
    lda iobuffer

    rts
    .endp

; ##################################################################################
; params: A = index of network to get results for
; returns: A/X = memory location of SSIDInfo
.proc io_get_scan_result ( .byte a ) .reg
    .var info SSIDInfo

    ; network index in A
    sta      DAUX1
    mva #$00 DAUX2

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
; returns: A/X = memory location of AdapterConfig
.proc io_get_adapter_config
    .var ac AdapterConfig

    set_sio_defaults
    mva #$e8 DCOMND         ; Get adapter config
    mva #$40 DSTATS
    mwa #ac  DBUFLO
    mwa #.sizeof(AdapterConfig) DBYTLO
    mwa #$00 DAUX

    call_siov
    lda <ac
    ldx >ac

    rts
    .endp

; ##################################################################################
; params: A = index of device slots to read
; differs from C implementation which passes in the array location start every time
; and never uses the index
.proc io_get_device_slots ( .byte a ) .reg
    ; store the index into DAUX1
    sta      DAUX1
    mva #$00 DAUX2

    set_sio_defaults
    mva #$f2 DCOMND         ; Get device slot
    mva #$40 DSTATS
    mwa #.sizeof(DeviceSlot)*8 DBYTLO
    mwa #deviceSlots DBUFLO

    call_siov
    rts

    .endp

; ##################################################################################
; write all 8 device slots
.proc io_put_device_slots
    set_sio_defaults
    mva #$f1 DCOMND         ; Write device slot
    mva #$40 DSTATS
    mwa #.sizeof(DeviceSlot)*8 DBYTLO
    mwa #deviceSlots DBUFLO
    mwa #$00 DAUX           ; unused, but let's clear it

    call_siov
    rts
    .endp

; ##################################################################################
; params: a = slot num, x,y = pointer to path string
.proc io_set_device_filename ( .byte a, x, y ) .reg
    sta DAUX1
    stx DBUFLO
    sty DBUFHI

    set_sio_defaults
    mva #$e2  DCOMND        ; Set Filename for Device Slot
    mva #$80  DSTATS
    mwa #$100 DBYTLO
    mva #$00  DAUX2

    call_siov

    rts
    .endp

; ##################################################################################
; params: a = slot num
; returns: a/x = lo/hi of device slot filename buffer
.proc io_get_device_filename ( .byte a ) .reg
    sta DAUX1

    set_sio_defaults
    mva #$da  DCOMND        ; Get Filename for Device Slot
    mva #$40  DSTATS
    mwa #$100 DBYTLO
    mva #$00  DAUX2
    mwa #iobuffer DBUFLO

    call_siov
    lda <iobuffer
    ldx >iobuffer

    rts
    .endp

; ##################################################################################
; returns: true always on atari
.proc io_get_device_enabled_status
    lda #$01
    rts
    .endp
 
; ##################################################################################
; In C version, this sets 8 booleans to true always.
; But nothing needs those fields on atari, so we will do nothing
.proc io_update_devices_enabled
    rts
    .endp

; ##################################################################################
; No-op
.proc io_enable_device
    rts
    .endp

; ##################################################################################
; No-op
.proc io_disable_device
    rts
    .endp

; ##################################################################################
; No-op
.proc io_device_slot_to_device
    rts
    .endp

; ##################################################################################
; Not going to implement this, it's only used in one place and I think
; io_get_device_filename can be used instead
; .proc io_get_filename_for_device_slot
;     rts
;     .endp

; ##################################################################################
; Get hostslots information into array
.proc io_get_host_slots
    set_sio_defaults
    mva #$f4  DCOMND         ; Get hosts slot
    mva #$40  DSTATS
    mwa #.sizeof(HostSlot)*8 DBYTLO
    mwa #hostSlots DBUFLO
    mwa #$00 DAUX

    call_siov
    rts
    .endp

; ##################################################################################
.proc io_put_host_slots
    set_sio_defaults
    mva #$f3  DCOMND         ; Write host slots
    mva #$80  DSTATS
    mwa #.sizeof(HostSlot)*8 DBYTLO
    mwa #hostSlots DBUFLO
    mwa #$00 DAUX

    call_siov
    rts
    .endp

; ##################################################################################
; params: x = host slot number
.proc io_mount_host_slot ( .byte x ) .reg
    mwa #hostSlots t1       ; copy hostSlots location into zp

    txa         ; save the slot
    pha

    ; make t1 point to specific host slot, by jumping forward x number of HostSlot entries
    beq skip                        ; but not if x == 0
@   adw t1 #.sizeof(HostSlot)
    dex
    bne @-

skip
    pla         ; restore slot back
    tax

    ldy #0
    lda (t1), y ; first byte of host slot
    beq out     ; don't do anything if first byte is zero

    set_sio_defaults
    mva #$f9 DCOMND         ; mount host
    mva #$00 DSTATS
    sta      DBYTLO
    sta      DBYTHI
    sta      DBUFLO
    sta      DBUFHI
    stx      DAUX1
    sta      DAUX2

    call_siov

out
    rts
    .endp

; ##################################################################################
; params: hs - host slot
; requires filter and path to have been previously set
.proc io_open_directory ( .byte hs ) .var
    .var hs .byte       ; host slot

    ; is the filter set?
    lda filter
    beq skip

    ; yes, create a dir+filter string
    ; clear 256 bytes of iobuffer
    ldx #$00
    mva:rne #$00 iobuffer,x+

    ; copy path+filter to iobuffer
    strncpy   #path   #iobuffer #224
    strncat   #filter #iobuffer
    ; did append work? if not, a=1
    bne error

    mwa       #iobuffer DBUFLO
    jmp do_sio

skip
    mwa       #path     DBUFLO

do_sio
    set_sio_defaults
    mva #$f7  DCOMND         ; open directory
    mva #$80  DSTATS
    mwa #$100 DBYTLO
    mva hs    DAUX1
    mva #$00  DAUX2

    call_siov
    ; return success
    lda #$00

error
    rts
    .endp

; ##################################################################################
.proc io_read_directory

    rts
    .endp

; ##################################################################################
.proc io_close_directory

    rts
    .endp

; ##################################################################################
.proc io_set_directory_position

    rts
    .endp

; ##################################################################################
.proc io_build_directory

    rts
    .endp

; ##################################################################################
; arrays and buffers

deviceSlots:
deviceSlots_real dta DeviceSlot  [7]     ; 8 entries, MADS arrays are 0..COUNT
hostSlots:
hostSlots_real   dta HostSlot    [7]

filter      :$20  .byte
src_filter  :$20  .byte
path        :$e0  .byte
;src_path    :$e0  .byte
;src_fname   :$80  .byte

; this is a general buffer we will reuse for temp data
iobuffer    :$100 .byte
