; io_copy_dcb.s
;
; defined tables for the DCB values for all io functions
; and exposes a procedure to copy the base data into DCB

        .export         io_copy_dcb
        .import         io_wifi_enabled, io_wifi_status, io_net_config, io_scan, io_ssidinfo
        .import         io_adapter_config, io_deviceslots
        .importzp       ptr1
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; Only sets DCB
; INPUT:
;       x = index of io function. see IO_TABLES below
.proc io_copy_dcb
        mva {io_dcb_table_lo,x}, ptr1
        mva {io_dcb_table_hi,x}, ptr1+1

        ; first 2 bytes always $70, $01, so we can do those manually. saves table space, and loops
        mva #$70, DCB
        mva #$01, DCB+1

        ; copy 10 bytes of table into DCB
        ldy #9
:       mva {(ptr1), y}, {DCB+2, y}
        dey
        bpl :-
        rts
.endproc

.rodata

        .linecont +
        .define IO_Tables \
                t_io_get_wifi_enabled,   \
                t_io_get_wifi_status,    \
                t_io_get_ssid,           \
                t_io_set_ssid,           \
                t_io_scan_for_networks,  \
                t_io_get_scan_result,    \
                t_io_get_adapter_config, \
                t_io_get_device_slots
        .linecont -

io_dcb_table_lo: .lobytes IO_Tables
io_dcb_table_hi: .hibytes IO_Tables

; DCB order is:
;  ddevic ($70)
;  dunit  ($01)
;  dcomnd
;  dstats ($40/$80)
;  dbuflo / dbufhi
;  dtimlo ($0f)
;  dunuse ($00)
;  dbytlo / dbythi
;  daux1  / daux2

.define NCsz .sizeof(NetConfig)
.define SIsz .sizeof(SSIDInfo)
.define ACsz .sizeof(AdapterConfig)
; I had to split this one to get it to work
.define DS8zL .lobyte(.sizeof(DeviceSlot)*8)
.define DS8zH .hibyte(.sizeof(DeviceSlot)*8)

; TODO: could rearrange this vertically, i.e. group by DDEVIC etc to save more space
; as 2 columns are constant. saves about 60 bytes ultimately

t_io_get_wifi_enabled:
        .byte $ea, $40, <io_wifi_enabled,   >io_wifi_enabled,   $0f, $00, $01,   $00,   $00, $00

t_io_get_wifi_status:
        .byte $fa, $40, <io_wifi_status,    >io_wifi_status,    $0f, $00, $01,   $00,   $00, $00

t_io_get_ssid:
        .byte $fe, $40, <io_net_config,     >io_net_config,     $0f, $00, <NCsz, >NCsz, $00, $00

t_io_set_ssid:
        .byte $fb, $80, <io_net_config,     >io_net_config,     $0f, $00, <NCsz, >NCsz, $01, $00

t_io_scan_for_networks:
        .byte $fd, $40, <io_scan,           >io_scan,           $0f, $00, $04,   $00,   $00, $00

t_io_get_scan_result:
        .byte $fc, $40, <io_ssidinfo,       >io_ssidinfo,       $0f, $00, <SIsz, >SIsz, $ff, $00

t_io_get_adapter_config:
        .byte $e8, $40, <io_adapter_config, >io_adapter_config, $0f, $00, <ACsz, >ACsz, $00, $00

t_io_get_device_slots:
        .byte $f2, $40, <io_deviceslots,    >io_deviceslots,    $0f, $00, DS8zL, DS8zH, $00, $00

