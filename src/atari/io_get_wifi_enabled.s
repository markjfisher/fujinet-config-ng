; io_get_wifi_enabled.s
;

        .export         io_get_wifi_enabled, wifi_enabled
        .import         io_siov
        .include        "atari.inc"
        .include        "../inc/macros.inc"

; sets A=1 if wifi is enabled. 0 otherwise
.proc io_get_wifi_enabled

        ; index 0 is io_get_wifi_enabled
        ldx #0
        jsr io_siov

        ; was it set?
        cpb wifi_enabled, #$01
        bne :+

        ; yes
        lda #$01
        rts

        ; no
:       lda #$00
        rts

.endproc

; ------------------------------------------------------

.data
wifi_enabled:   .byte 0
