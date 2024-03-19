        .export     _mf_init_screen

        .import     _clr_help
        .import     _clr_status
        .import     get_scrloc

        .include    "macros.inc"

.proc _mf_init_screen
        ldx        #$00
        ldy        #$00
        jsr        get_scrloc

        jsr        _clr_help
        jmp        _clr_status
.endproc