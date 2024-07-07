        .export     mf_error_too_long

        .import     _scr_clr_highlight
        .import     _show_error
        .import     mod_current
        .import     pusha

        .include    "macros.inc"

.proc mf_error_too_long
        jsr     _scr_clr_highlight
        pusha   #16
        pusha   #1
        setax   #p2l_err_msg
        jmp     _show_error
.endproc

.rodata
p2l_err_msg:
        .byte " Path too long!", 0
