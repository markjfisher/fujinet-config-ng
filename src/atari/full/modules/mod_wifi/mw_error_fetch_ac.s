        .export     mw_error_fetch_ac

        .import     _show_error
        .import     mod_current
        .import     pusha

        .include    "macros.inc"
        .include    "modules.inc"

.proc mw_error_fetch_ac
        pusha   #32
        pusha   #1
        setax   #mw_ac_err_msg
        jsr     _show_error

        mva     #Mod::wifi, mod_current
        rts
.endproc

.segment "SCR_DATA"
mw_ac_err_msg:
                .byte "  Error loading adapter info!", 0
