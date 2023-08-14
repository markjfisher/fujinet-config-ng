        .export         _fn_io_get_wifi_enabled
        .import         _fn_io_siov

        .include        "fn_macros.inc"
        .include        "fn_io.inc"

; int _fn_io_get_wifi_enabled()
;
; sets A=1 if wifi is enabled. 0 otherwise
.proc _fn_io_get_wifi_enabled
        setax   #t_io_get_wifi_enabled
        jsr     _fn_io_siov

        ; was it set?
        lda     fn_io_wifi_enabled
        cmp     #$01
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
t_io_get_wifi_enabled:
        .byte $ea, $40, <fn_io_wifi_enabled, >fn_io_wifi_enabled, $0f, $00, $01, $00, $00, $00

.bss
fn_io_wifi_enabled: .res 1
