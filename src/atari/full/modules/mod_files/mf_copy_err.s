        .export     mf_copy_err

        .import     _scr_clr_highlight
        .import     _show_error
        .import     mod_current
        .import     pusha

        .include    "macros.inc"
        .include    "modules.inc"

.proc mf_copy_err
        jsr     _scr_clr_highlight
        pusha   #24
        pusha   #1
        setax   #opendir_err_msg
        jmp     _show_error
.endproc

.segment "SCR_DATA"
opendir_err_msg:
        .byte " Cannot copy directory", 0
