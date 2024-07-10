        .export     _mf_init_screen

        .import     _clr_help
        .import     _clr_status
        .import     _pmg_skip_x
        .import     get_scrloc

        .include    "macros.inc"

.proc _mf_init_screen
        ldx     #$01
        stx     _pmg_skip_x

        dex
        ldy     #$00
        jsr     get_scrloc

        jsr     _clr_help
        jmp     _clr_status
.endproc