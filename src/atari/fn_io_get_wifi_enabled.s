        .export         _fn_io_get_wifi_enabled
        .import         _fn_io_siov
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "fn_io.inc"

; int _fn_io_get_wifi_enabled()
;
; sets A=1 if wifi is enabled. 0 otherwise
.proc _fn_io_get_wifi_enabled
        setax   #fn_t_io_get_wifi_enabled
        jsr     _fn_io_siov

        ; was it set?
        cpb     fn_io_wifi_enabled, #$01
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

.rodata
fn_t_io_get_wifi_enabled:
        .byte $ea, $40, <fn_io_wifi_enabled,   >fn_io_wifi_enabled,   $0f, $00, $01,   $00,   $00, $00

.bss
fn_io_wifi_enabled: .res 1
