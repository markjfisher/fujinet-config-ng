        .export     mf_nd_err_saving

        .import     _show_error
        .import     mod_current
        .import     pusha

        .include    "macros.inc"
        .include    "modules.inc"

.proc mf_nd_err_saving
        pusha   #21
        pusha   #1
        setax   #nd_save_err_msg
        jmp     _show_error
.endproc

.rodata
nd_save_err_msg:
        .byte " Failed to save disk", 0
