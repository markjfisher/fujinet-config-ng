.macro  mwa    arg1, arg2
    .if (.match (.left (1, {arg1}), #))
        ; arg1 is immediate mode
        lda     #<(.right (.tcount ({arg1})-1, {arg1}))
        sta     arg2
        lda     #>(.right (.tcount ({arg1})-1, {arg1}))
        ; have to use "1+..." to stop assembler thinking it's an addressing mode
        sta     1+(arg2)
    .else
        ; assume absolute or zero page
        lda     arg1
        sta     arg2
        lda     1+(arg1)
        sta     1+(arg2)
    .endif
.endmacro

.macro  mva     arg1, arg2
    ; this could be immediate or absolute, doesn't matter.
    ; commas are arg separators, so `mva #$00, {($80),y}` is how to use this with addressing modes
    lda     arg1
    sta     arg2
.endmacro

.macro plr
    pla
    tay
    pla
    tax
    pla
.endmacro

.macro phr
    pha
    txa
    pha
    tya
    pha
.endmacro

.macro LMS      mode, address, count
    .ifnblank count
        .repeat count
    .endif

    .byte mode + DL_LMS
    .addr address

    .ifnblank count
        .endrepeat
    .endif

.endmacro


.macro SCREENCODE_CHARMAP
    ; atascii 0 to $1f -> $40 to $5f
    .repeat $20, i
        .charmap i, $40 + i
        .charmap i + $80, $40 + i + $80
    .endrepeat

    ; atascii $20 to $5f -> $00 to $3f
    .repeat $40, i
        .charmap $20 + i, $00 + i
        .charmap $20 + i + $80, $00 + i + $80
    .endrepeat

    ; atascii $60 to $7f -> $60 to $7f
    .repeat $20, i
        .charmap $60 + i, $60 + i
        .charmap $60 + i + $80, $60 + i + $80
    .endrepeat
.endmacro

.macro SCREENCODE_INVERT_CHARMAP
    ; atascii 0 to $1f -> $40 to $5f + $80
    .repeat $20, i
        .charmap i, $40 + i + $80
        .charmap i + $80, $40 + i
    .endrepeat

    ; atascii $20 to $5f -> $00 to $3f
    .repeat $40, i
        .charmap $20 + i, $00 + i + $80
        .charmap $20 + i + $80, $00 + i
    .endrepeat

    ; atascii $60 to $7f -> $60 to $7f
    .repeat $20, i
        .charmap $60 + i, $60 + i + $80
        .charmap $60 + i + $80, $60 + i
    .endrepeat
.endmacro

.macro NORMAL_CHARMAP
    .repeat $100, i
        .charmap i, i
    .endrepeat
.endmacro

.macro cpb arg1, arg2
    lda arg1
    cmp arg2
.endmacro

.macro cpw arg1, arg2
    .local s1, s2
    .if (.match (.left (1, {arg2}), #))
        lda     1+(arg1)
        cmp     #>(.right (.tcount ({arg2})-1, {arg2}))
        bne     s1
        lda     arg1
        cmp     #<(.right (.tcount ({arg2})-1, {arg2}))
s1:
    .else
        lda     1+(arg1)
        cmp     1+(arg2)
        bne     s2
        lda     arg1
        cmp     arg2
s2:
    .endif
.endmacro

.macro add_sta  arg1
    clc
    adc arg1
    sta arg1
.endmacro

.macro scc_inc  arg1
    .local skip1
    bcc skip1
    inc arg1
skip1:
.endmacro

.macro sne_inc  arg1
    .local skip1
    bne skip1
    inc arg1
skip1:
.endmacro

.macro add      arg1
    clc
    adc arg1
.endmacro
