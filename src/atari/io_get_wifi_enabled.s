; io_get_wifi_enabled.s
;

        .export         io_get_wifi_enabled
        .import         io_siov, io_wifi_enabled
        .include        "atari.inc"
        .include        "../inc/macros.inc"
        .include        "io.inc"

; sets A=1 if wifi is enabled. 0 otherwise
.proc io_get_wifi_enabled
        ldx #IO_FN::get_wifi_enabled
        jsr io_siov

        ; was it set?
        cpb io_wifi_enabled, #$01
        bne :+

        ; yes
        lda #$01
        rts

        ; no
:       lda #$00
        rts
.endproc
