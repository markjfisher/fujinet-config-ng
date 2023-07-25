; mostly various MADS macros reimplemented to make asm easier to read

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

; 'add a to arg1 and store byte into arg1'
.macro add_sta arg1
    clc
    adc arg1
    sta arg1
.endmacro

; 'skip if carry clear, and do inc'
.macro scc_inc arg1
    .local skip1
    bcc skip1
    inc arg1
skip1:
.endmacro

; 'skip if not equal, and do inc'
.macro sne_inc arg1
    .local skip1
    bne skip1
    inc arg1
skip1:
.endmacro

; lest we forget to clc
.macro add arg1
    clc
    adc arg1
.endmacro

; use CA65 function calling conventions, passing values into SP via pushax
.macro pushax arg1
    .if (.match (.left (1, {arg1}), #))
        lda     #<(.right (.tcount ({arg1})-1, {arg1}))
        ldx     #>(.right (.tcount ({arg1})-1, {arg1}))
        jsr     pushax
    .else
        lda     arg1
        ldx     1+(arg1)
        jsr     pushax
    .endif
.endmacro

; push arg1 into SP from A
.macro pusha arg1
    lda     arg1
    jsr     pusha
.endmacro

; same as pushax, but without the push to SP, preparing the args directly for consumption
.macro setax arg1
    .if (.match (.left (1, {arg1}), #))
        lda     #<(.right (.tcount ({arg1})-1, {arg1}))
        ldx     #>(.right (.tcount ({arg1})-1, {arg1}))
    .else
        lda     arg1
        ldx     1+(arg1)
    .endif
.endmacro

.macro popax arg1
    jsr     popax
    sta     arg1
    stx     1+(arg1)
.endmacro

.macro popa arg1
    jsr     popa
    sta     arg1
.endmacro

.macro getax arg1
    sta     arg1
    stx     1+(arg1)
.endmacro

; short copy <$7F bytes (uses bpl), using Y to index
.macro copy_y arg1, arg2, arg3
    .local L1
    ldy arg1-1
L1: lda arg2
    sta arg3
    dey
    bpl L1
.endmacro

; adw: adds word values together.
; adw src #$40
; adw src #$4000
; adw a b
; adw src #$40 dst
; adw src #$4000 dst
; adw a b c
; NOTE: param 1 and 3 cannot be literal
.macro adw arg1, arg2, arg3
    clc
    .if (.match (.left (1, {arg2}), #))
        ; immediate value in arg2
        lda     arg1
        ; TODO - can we do a short version of this if arg2 < $100, as it's only 1 byte
        adc     #<(.right (.tcount ({arg2})-1, {arg2}))
        .ifnblank arg3
            sta     arg3
        .else
            sta     arg1
        .endif
        lda     1+(arg1)
        adc     #>(.right (.tcount ({arg2})-1, {arg2}))
        .ifnblank arg3
            sta     1+(arg3)
        .else
            sta     1+(arg1)
        .endif
    .else
        lda     arg1
        adc     arg2
        .ifnblank arg3
            sta     arg3
        .else
            sta     arg1
        .endif
        lda     1+(arg1)
        adc     1+(arg2)
        .ifnblank arg3
            sta     1+(arg3)
        .else
            sta     1+(arg1)
        .endif
    .endif
.endmacro
