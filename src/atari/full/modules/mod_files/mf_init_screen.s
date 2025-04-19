        .export     _mf_init_screen

        .import     _clr_help
        .import     _clr_status
        .import     _pmg_space_left
        .import     _pmg_space_right
        .import     get_scrloc

        .include    "macros.inc"

.segment "CODE2"

.proc _mf_init_screen
        ldx     #$01
        stx     _pmg_space_left
        stx     _pmg_space_right

        dex
        ldy     #$00
        jsr     get_scrloc

        jsr     _clr_help
        jmp     _clr_status
.endproc