        .export     mod_files
        .export     mf_h1, mf_h3, mf_s1

        .import     _fn_clrscr, _fn_clr_highlight
        .import     _fn_put_help, _fn_put_status
        .import     files_simple
        .import     pusha

        .include    "fn_macros.inc"

.proc mod_files
        jsr     _fn_clrscr
        put_status #0, #mf_s1
        put_help #1, #mf_h1
        put_help #3, #mf_h3

        jsr     _fn_clr_highlight

        ; TODO: check which mode we're in, simple or block.
        ; check if we're low memory and force it to simple.
        ; otherwise if we have 4000-7fff free, we can start block reading

        ; WARNING - that's device specific stuff!

        jmp     files_simple

.endproc

.segment "SCREEN"
mf_s1:
                INVERT_ATASCII
                .byte "DISK IMAGES", 0

mf_h1:
                NORMAL_CHARMAP
                .byte $81, $1c, $1d, $82        ; endL up down endR
                INVERT_ATASCII
                .byte "Move "
                NORMAL_CHARMAP
                .byte $81, "<", $82
                INVERT_ATASCII
                .byte "Up Dir  "
                NORMAL_CHARMAP
                .byte $81, "Ret", $82
                INVERT_ATASCII
                .byte "Choose", 0

mf_h3:
                NORMAL_CHARMAP
                .byte $81, $1e, $1f, $82
                INVERT_ATASCII
                .byte "Prev/Next Pg   "
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0
