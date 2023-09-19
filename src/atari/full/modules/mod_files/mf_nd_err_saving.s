        .export     mf_nd_err_saving

        .import     _show_error
        .import     mod_current
        .import     pusha

        .include    "fc_macros.inc"
        .include    "fc_mods.inc"

.proc mf_nd_err_saving
        pusha   #21
        pusha   #1
        setax   #nd_save_err_msg
        jmp     _show_error
.endproc

.segment "SCR_DATA"
nd_save_err_msg:
        .byte " Failed to save disk", 0
