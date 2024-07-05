        .export     mw_choose_custom
        .export     mw_help

        .import     _clr_help
        .import     _put_help
        .import     _scr_clr_highlight
        .import     mw_help_password
        .import     mw_ssid_pass_pu
        .import     pusha

        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "macros.inc"

;ptr1,ptr4
.proc mw_choose_custom
        jsr     _clr_help
        jsr     _scr_clr_highlight

        jmp     mw_ssid_pass_pu

.endproc

.proc mw_help
        jsr     _clr_help
        put_help   #0, #mw_help_password
        rts
.endproc