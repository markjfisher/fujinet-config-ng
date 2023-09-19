        .export     mf_error_too_long

        .import     _show_error
        .import     mod_current
        .import     pusha

        .include    "fc_macros.inc"

.proc mf_error_too_long
        pusha   #16
        pusha   #1
        setax   #p2l_err_msg
        jmp     _show_error
.endproc

.segment "SCR_DATA"
p2l_err_msg:
        .byte " Path too long!", 0
