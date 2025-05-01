        .export     mf_kb_cb

        .import     kb_idle_counter

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "atari.inc"

mf_kb_cb:
        ; update a char on the screen to prove it's working
        mwa     SAVMSC, ptr1
        adw     ptr1, #878      ; line 22, 38th char

        ldy     #$00
        lda     anim_val
        sta     (ptr1), y
        inc     anim_val

        rts

.data
anim_val:       .byte 0