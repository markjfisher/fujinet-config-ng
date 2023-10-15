        .export     _mx_do_boot
        .export     show_box

        .import     _fn_io_set_boot_config
        .import     _fn_io_set_boot_mode
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

        .include    "atari.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "zp.inc"
        .include    "fn_io.inc"

.proc _mx_do_boot
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
        ; check if we got an error
        bne     error

        pause   #$10
        ; "booting!"
        put_s   #10, #6, #boot_anim_2_1
        pause   #$20

        lda     #$00            ; don't read config
        jsr     _fn_io_set_boot_config
        jmp     COLDSV

lobby_boot:
        ; "booting!"
        jsr     show_box
        put_s   #10, #6, #boot_anim_2_1
        pause   #$20

        lda     #$02            ; lobby mode
        jsr     _fn_io_set_boot_mode
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