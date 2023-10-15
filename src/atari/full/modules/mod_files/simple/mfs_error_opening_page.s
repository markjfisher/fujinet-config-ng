        .export     mfs_error_opening_page

        .import     _show_error
        .import     mod_current
        .import     pusha

        .include    "macros.inc"
        .include    "modules.inc"

.proc mfs_error_opening_page
        pusha   #26
        pusha   #1
        setax   #opendir_err_msg
        jsr     _show_error

        ; set next module as hosts
        mva     #Mod::hosts, mod_current
        rts

.endproc

.segment "SCR_DATA"
opendir_err_msg:
        .byte " Error Opening Directory!", 0
