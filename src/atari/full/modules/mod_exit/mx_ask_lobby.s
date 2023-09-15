        .export     mx_ask_lobby

        .import     _clr_help
        .import     _put_help
        .import     _scr_clr_highlight
        .import     _show_select
        .import     mx_ask_help
        .import     mx_ask_lobby_info
        .import     mx_ask_pu_msg
        .import     pusha
        .import     pushax

        .include    "fc_macros.inc"

.proc mx_ask_lobby
        jsr     _scr_clr_highlight
        pushax  #mx_ask_lobby_info
        pushax  #ask_help
        setax   #mx_ask_pu_msg
        jmp     _show_select        ; return value is type PopupItemReturn

ask_help:
        jsr     _clr_help
        put_help #0, #mx_ask_help
        rts

.endproc