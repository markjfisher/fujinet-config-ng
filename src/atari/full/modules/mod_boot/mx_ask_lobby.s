        .export     mx_ask_lobby

        .import     _clr_help
        .import     _put_help
        .import     _scr_clr_highlight
        .import     _show_select
        .import     mx_ask_help
        .import     mx_ask_lobby_info
        .import     mx_ask_lobby_option
        .import     mx_ask_pu_msg
        .import     pu_null_cb
        .import     pusha
        .import     pushax
        .import     return0
        .import     return1

        .include    "macros.inc"
        .include    "popup.inc"
        .include    "zp.inc"

.proc mx_ask_lobby
        jsr     _scr_clr_highlight
        pushax  #pu_null_cb
        pushax  #mx_ask_lobby_info
        pushax  #ask_help
        setax   #mx_ask_pu_msg
        jsr     _show_select        ; return value is type PopupItemReturn in X

        cpx     #PopupItemReturn::escape
        beq     lobby_no

        ; option value is in ptr at mx_ask_lobby_option + POPUP_VAL_IDX, 0 = Y, 1 = N
        ldy     #$00
        mwa     {mx_ask_lobby_option + POPUP_VAL_IDX}, tmp5
        lda     (tmp5), y
        bne     lobby_no

        jmp     return0

lobby_no:
        jmp     return1

ask_help:
        jsr     _clr_help
        put_help #0, #mx_ask_help
        rts

.endproc