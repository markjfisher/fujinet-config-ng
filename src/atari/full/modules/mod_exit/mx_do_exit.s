        .export     _mx_do_exit

        .import     _fn_io_set_boot_config
        .import     _pause
        .import     _put_s
        .import     boot_anim_1_1
        .import     boot_anim_1_2
        .import     boot_anim_1_3
        .import     boot_anim_2_1
        .import     booting_mode
        .import     mod_current
        .import     mx_mount
        .import     pusha
        .import     return1

        .import     debug

        .include    "atari.inc"
        .include    "fc_macros.inc"
        .include    "fc_mods.inc"
        .include    "fc_zp.inc"

.proc _mx_do_exit
        jsr     debug
        ; pick from the booting mode
        lda     booting_mode
        cmp     #ExitMode::boot
        beq     normal_boot

        cmp     #ExitMode::lobby
        beq     lobby_boot

        ; didn't match any mode we know about, just drop to hosts.
        mva     #Mod::hosts, mod_current
        jmp     return1

normal_boot:
        ; "Mounting All"
        jsr     show_box
        put_s   #10, #6, #boot_anim_1_2

        jsr     mx_mount
        mva     #$00, tmp1      ; normal boot config value
        beq     :+

lobby_boot:
        jsr     show_box
        mva     #$02, tmp1      ; lobby boot config value

        ; "booting!"
:       put_s   #10, #6, #boot_anim_2_1

        ; courtesy pause to catch the message for half a second
        pause   #$20

        ; CHARGE!
        ; set appropriate boot config mode, and cold start
        lda     tmp1
        jsr     _fn_io_set_boot_config
        jmp     COLDSV

error:
        ; mounting or some other error. return an error to caller
        jmp     return1

.endproc

.proc show_box
        put_s   #10, #5, #boot_anim_1_1
        put_s   #10, #7, #boot_anim_1_3
        rts
.endproc