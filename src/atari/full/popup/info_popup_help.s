        .export     info_popup_help

        .import     _fn_put_help
        .import     pusha

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

.proc info_popup_help
        put_help #1, #err_h1
        rts
.endproc

.segment "SCREEN"

err_h1:
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0