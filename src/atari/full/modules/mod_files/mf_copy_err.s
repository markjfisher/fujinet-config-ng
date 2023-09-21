        .export     mf_copy_err

        .import     _show_error
        .import     mod_current
        .import     pusha

        .include    "fc_macros.inc"
        .include    "fc_mods.inc"

.proc mf_copy_err
        pusha   #24
        pusha   #1
        setax   #opendir_err_msg
        jsr     _show_error

        ; set next module as hosts
        mva     #Mod::hosts, mod_current
        rts

.endproc

.segment "SCR_DATA"
opendir_err_msg:
        .byte " Cannot copy directory", 0
