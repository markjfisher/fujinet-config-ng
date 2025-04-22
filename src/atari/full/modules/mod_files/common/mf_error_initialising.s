        .export     mf_error_initialising

        .import     _show_error
        .import     _scr_clr_highlight
        .import     pusha

        .include    "macros.inc"

.proc mf_error_initialising
        jsr     _scr_clr_highlight
        pusha   #26
        pusha   #1
        setax   #mfc_init_err_msg
        jmp     _show_error
.endproc

.rodata
mfc_init_err_msg:
        .byte "  Error initialising!", 0
