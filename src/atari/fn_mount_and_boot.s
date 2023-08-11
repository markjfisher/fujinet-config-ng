        .export     _fn_mount_and_boot
        .import     _fn_io_get_device_slots, _fn_io_get_host_slots, _fn_io_mount_all, _fn_io_set_boot_config
        .import     _fn_pause, _fn_put_s, _bar_clear, pushax

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"

; void fn_mount_and_boot()
.proc _fn_mount_and_boot

        ; INTERNAL DEBATE! Should this function do the display? Or the done module before it calls us?

        ; clear the selection bar
        jsr     _bar_clear
        ; put a message on screen
        pushax  #boot_1s
        ldx     #8
        ldy     #6
        jsr     _fn_put_s

        lda     #$1
        jsr     _fn_pause       ; force screen refresh

        ; re-read the devices/hosts, the WebUI might have changed them etc.
        jsr     _fn_io_get_device_slots
        jsr     _fn_io_get_host_slots

        ; MOUNT!
        jsr     _fn_io_mount_all
        cmp     #$01
        bne     error

        pushax  #boot_2s
        ldx     #4
        ldy     #8
        jsr     _fn_put_s

        lda     #$40
        jsr     _fn_pause       ; courtesy pause for user

        ; CHARGE!
        ; turn off boot config, and cold start
        lda     #$00
        jsr     _fn_io_set_boot_config
        jmp     COLDSV

error:
        rts

.endproc

.segment "SDATA"
boot_1s:    .byte "Mounting Images...", 0
boot_2s:    .byte "Successful Mount, Booting!", 0