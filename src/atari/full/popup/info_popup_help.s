        .export     info_popup_help
        .export     pu_err_title

        .import     _put_help
        .import     pusha

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

.proc info_popup_help
        put_help #1, #pu_err_h1
        rts
.endproc

.segment "SCREEN"

pu_err_h1:
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0

pu_err_title:
                INVERT_ATASCII
                .byte "Error", 0