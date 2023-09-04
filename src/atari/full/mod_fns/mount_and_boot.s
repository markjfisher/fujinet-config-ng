        .export     _mount_and_boot
        .import     _fn_io_get_device_slots, _fn_io_get_host_slots, _fn_io_mount_all, _fn_io_set_boot_config
        .import     _put_s, _bar_clear, pushax, pusha, _fn_pause
        .import     fn_io_deviceslots
        .import     fn_io_hostslots
        .import     return1

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"

; void mount_and_boot()
.proc _mount_and_boot

        ; clear the selection bar
        jsr     _bar_clear

        put_s   #10, #5, #boot_anim_1_1
        put_s   #10, #6, #boot_anim_1_2
        put_s   #10, #7, #boot_anim_1_3

        ; re-read the devices/hosts, the WebUI might have changed them etc.
        setax   #fn_io_deviceslots
        jsr     _fn_io_get_device_slots
        setax   #fn_io_hostslots
        jsr     _fn_io_get_host_slots
        pause   #10         ; small pause to allow screen to continue showing "Mounting all" briefly

        ; MOUNT!
        jsr     _fn_io_mount_all
        cmp     #$01
        bne     error

        ; tell the user we're booting. Box is same, so only need to show "Booting" part
        put_s   #12, #6, #boot_anim_2_1

        ; courtesy pause to catch the message for half a second
        pause   #$20

        ; CHARGE!
        ; turn off boot config, and cold start
        lda     #$00
        jsr     _fn_io_set_boot_config
        jmp     COLDSV

error:
        jmp     return1

.endproc

.segment "SCREEN"

; Mounting All - in box
boot_anim_1_1: .byte $11, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $05, 0
boot_anim_1_2: .byte $7C, $99, $CD, $EF, $F5, $EE, $F4, $E9, $EE, $E7, $A0, $C1, $EC, $EC, $19, $7C, 0
boot_anim_1_3: .byte $1A, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $12, $03, 0

; Booting!
boot_anim_2_1: .byte $A0, $A0, $C2, $EF, $EF, $F4, $E9, $EE, $E7, $A1, $A0, $A0, 0