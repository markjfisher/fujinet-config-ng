        .export     mx_ask_lobby

        .import     _clr_help
        .import     _put_help
        .import     _scr_clr_highlight
        .import     show_select
        .import     ss_args
        .import     mx_ask_help
        .import     mx_ask_lobby_info
        .import     mx_ask_lobby_option
        .import     mx_ask_pu_msg
        .import     _just_rts
        .import     pusha
        .import     pushax
        .import     return0
        .import     return1

        .include    "macros.inc"
        .include    "popup.inc"
        .include    "zp.inc"

.proc mx_ask_lobby
        jsr     _scr_clr_highlight
        mwa     #_just_rts, ss_args+ShowSelectArgs::kb_cb
        mwa     #mx_ask_lobby_info, ss_args+ShowSelectArgs::items
        mwa     #ask_help, ss_args+ShowSelectArgs::help_cb
        mwa     #mx_ask_pu_msg, ss_args+ShowSelectArgs::message

        jsr     show_select        ; return value is type PopupItemReturn in X

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