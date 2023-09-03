        .export     display_space

        .import     block_line
        .import     return0

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; just put a blank line. keyboard movement will skip over it
.proc display_space
        mva     #FNC_LT_BLK, tmp1
        mva     #FNC_BLANK, tmp2
        mva     #FNC_RT_BLK, tmp3
        jsr     block_line
        jmp     return0
.endproc
