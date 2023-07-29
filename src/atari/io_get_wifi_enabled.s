        .export         io_get_wifi_enabled
        .import         io_siov
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; int io_get_wifi_enabled()
;
; sets A=1 if wifi is enabled. 0 otherwise
.proc io_get_wifi_enabled
        setax   #t_io_get_wifi_enabled
        jsr     io_siov

        ; was it set?
        cpb     io_wifi_enabled, #$01
        bne :+

        ; yes
        ldx     #$00
        lda     #$01
        rts

        ; no
        ldx     #$00
:       lda     #$00
        rts
.endproc

.data

t_io_get_wifi_enabled:
        .byte $ea, $40, <io_wifi_enabled,   >io_wifi_enabled,   $0f, $00, $01,   $00,   $00, $00

.bss
io_wifi_enabled: .res 1
