        .export     _mf_init_screen

        .import     _clr_help
        .import     _clr_status
        .import     _put_help
        .import     _put_status
        .import     get_scrloc
        .import     mf_s1, mf_h1, mf_h2
        .import     pusha

        .include    "fn_macros.inc"

.proc _mf_init_screen
        ldx        #$00
        ldy        #$00
        jsr        get_scrloc

        jsr        _clr_help
        jmp        _clr_status
.endproc