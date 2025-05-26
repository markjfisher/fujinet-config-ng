; various macros to make asm easier to read

.macro  mwa    arg1, arg2
    .if (.match (.left (1, {arg1}), #))
        ; arg1 is immediate mode
        lda     #<(.right (.tcount ({arg1})-1, {arg1}))
        sta     arg2
        lda     #>(.right (.tcount ({arg1})-1, {arg1}))
        ; have to use "1+..." to stop assembler thinking it's an addressing mode
        sta     1+(arg2)
    .else
        lda     arg1
        sta     arg2
        lda     1+(arg1)
        sta     1+(arg2)
    .endif
.endmacro

; increments y between stores. the caller should use:
; mway foo, {(ptr1), y}
.macro mway arg1, arg2
    .if (.match (.left (1, {arg1}), #))
        lda     #<(.right (.tcount ({arg1})-1, {arg1}))
        sta     arg2
        iny
        lda     #>(.right (.tcount ({arg1})-1, {arg1}))
        sta     arg2
    .else
        lda     arg1
        sta     arg2
        iny
        lda     1+(arg1)
        sta     arg2
    .endif
.endmacro

; similar to above, but y arg is in the src
; mywa {(ptr1), y}, foo
; cannot have literal
.macro mywa arg1, arg2
    .if (.match (.left (1, {arg1}), #))
        .error "mywa: arg1 cannot be literal"
    .endif
    .if (.match (.left (1, {arg2}), #))
        .error "mywa: arg2 cannot be literal"
    .endif
    lda     arg1
    sta     arg2
    iny
    lda     arg1
    sta     1+(arg2)
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

.macro INVERT_ATASCII
    ; end of string stays same
    .charmap 0, 0
    ; add $80 for chars $01-$7F
    .repeat $7E, i
        .charmap i+1, i+1+$80
    .endrepeat
.endmacro

; inverts normal ascii chars and numbers, not any of the altered fonts etc.
.macro HELP_TEXT
    ; end of string stays same
    .charmap 0, 0
    .repeat 64, i
        .charmap i+32, i+32+$80 ; most of the ascii set
        ; .charmap i+32+$80, i+32 ; most of the ascii set
    .endrepeat
    .repeat 26, i
        .charmap i+97, i+97+$80 ; a-z
        ; .charmap i+97+$80, i+97 ; a-z inv
    .endrepeat
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

.macro axinto arg1
    sta     arg1
    stx     1+(arg1)
.endmacro

; adds values mem1 and args into mem1, or mem3 if present
; handles literals of 1 or 2 bytes as well as memory.
; examples:
; adw mem1, #$05
; adw mem1, #$05, mem2
; adw mem1, #$0500
; adw mem1, #$0500, mem2
; adw mem1, mem2
; adw mem1, mem2, mem3

.macro adw arg1, arg2, arg3
    .local l1_a, l1_b
    ; Only check arg1 for literal if we don't have 3 args
    .ifblank arg3
        .if (.match (.left (1, {arg1}), #))
            .error "adw: arg1 cannot be literal without destination arg3"
        .endif
    .endif
    .if (.match (.left (1, {arg3}), #))
        .error "adw: arg3 cannot be literal"
    .endif

    clc
    .if (.match (.left (1, {arg2}), #))
        ; immediate value in arg2
        .if (.match (.left (1, {arg1}), #))
            ; both arg1 and arg2 are immediate
            lda     #<(.right (.tcount ({arg1})-1, {arg1}))
            adc     #<(.right (.tcount ({arg2})-1, {arg2}))
            sta     arg3
            lda     #>(.right (.tcount ({arg1})-1, {arg1}))
            adc     #>(.right (.tcount ({arg2})-1, {arg2}))
            sta     1+(arg3)
        .else
            ; just arg2 is immediate
            lda     arg1
            adc     #<(.right (.tcount ({arg2})-1, {arg2}))
            .ifnblank arg3
                sta     arg3
            .else
                sta     arg1
            .endif

            .if .hibyte (.right (.tcount ({arg2})-1, {arg2})) = 0
                .ifnblank arg3
                    ; must store high byte of arg1 in arg3 still, and adjust if carry set
                    lda 1+(arg1)
                    sta 1+(arg3)
                    bcc l1_a
                    inc 1+(arg3)
l1_a:
                .else
                    ; the literal was only a byte, so only need to check carry
                    bcc l1_b
                    inc 1+(arg1)
l1_b:
                .endif
            .else
                ; full add of 2nd byte of constant
                lda     1+(arg1)
                adc     #>(.right (.tcount ({arg2})-1, {arg2}))
                .ifnblank arg3
                    sta     1+(arg3)
                .else
                    sta     1+(arg1)
                .endif
            .endif
        .endif
    .else
        .if (.match (.left (1, {arg1}), #))
            ; arg1 is immediate, arg2 is memory
            lda     #<(.right (.tcount ({arg1})-1, {arg1}))
            adc     arg2
            sta     arg3
            lda     #>(.right (.tcount ({arg1})-1, {arg1}))
            adc     1+(arg2)
            sta     1+(arg3)
        .else
            ; both are memory locations
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
    .endif
.endmacro

; sbw: subtracts word values together, or immediate bytes.
; complement of adw
.macro sbw arg1, arg2, arg3
    .local l1_a, l1_b
    ; Only check arg1 for literal if we don't have 3 args
    .ifblank arg3
        .if (.match (.left (1, {arg1}), #))
            .error "sbw: arg1 cannot be literal without destination arg3"
        .endif
    .endif
    .if (.match (.left (1, {arg3}), #))
        .error "sbw: arg3 cannot be literal"
    .endif

    sec
    .if (.match (.left (1, {arg2}), #))
        ; immediate value in arg2
        .if (.match (.left (1, {arg1}), #))
            ; both arg1 and arg2 are immediate
            lda     #<(.right (.tcount ({arg1})-1, {arg1}))
            sbc     #<(.right (.tcount ({arg2})-1, {arg2}))
            sta     arg3
            lda     #>(.right (.tcount ({arg1})-1, {arg1}))
            sbc     #>(.right (.tcount ({arg2})-1, {arg2}))
            sta     1+(arg3)
        .else
            ; just arg2 is immediate
            lda     arg1
            sbc     #<(.right (.tcount ({arg2})-1, {arg2}))
            .ifnblank arg3
                sta     arg3
            .else
                sta     arg1
            .endif

            .if .hibyte (.right (.tcount ({arg2})-1, {arg2})) = 0
                .ifnblank arg3
                    ; must store high byte of arg1 in arg3 still, and adjust if carry set
                    lda 1+(arg1)
                    sta 1+(arg3)
                    bcs l1_a
                    dec 1+(arg3)
l1_a:
                .else
                    ; the literal was only a byte, so only need to check carry
                    bcs l1_b
                    dec 1+(arg1)
l1_b:
                .endif
            .else
                ; full add of 2nd byte of constant
                lda     1+(arg1)
                sbc     #>(.right (.tcount ({arg2})-1, {arg2}))
                .ifnblank arg3
                    sta     1+(arg3)
                .else
                    sta     1+(arg1)
                .endif
            .endif
        .endif
    .else
        .if (.match (.left (1, {arg1}), #))
            ; arg1 is immediate, arg2 is memory
            lda     #<(.right (.tcount ({arg1})-1, {arg1}))
            sbc     arg2
            sta     arg3
            lda     #>(.right (.tcount ({arg1})-1, {arg1}))
            sbc     1+(arg2)
            sta     1+(arg3)
        .else
            ; both are memory locations
            lda     arg1
            sbc     arg2
            .ifnblank arg3
                sta     arg3
            .else
                sta     arg1
            .endif
            lda     1+(arg1)
            sbc     1+(arg2)
            .ifnblank arg3
                sta     1+(arg3)
            .else
                sta     1+(arg1)
            .endif
        .endif
    .endif
.endmacro

; adds byte1 to word arg1 dealing with carry, allow byte1 to be "a"
; so we can directly add accumulator to WORD
.macro adw1 arg1, byte1
    .local l1
    clc
    .if (.match ({byte1}, a))
        adc arg1
        sta arg1
    .else
        lda arg1
        adc byte1
        sta arg1
    .endif
    bcc l1
    inc 1+(arg1)
l1:
.endmacro

; subtracts byte1 from word arg1 dealing with carry, allow byte1 to be a
; although you'd probably be better going via ZP than the mess of code for subtracting a from memory
.macro sbw1 arg1, byte1
    .local l1, dec_hi
    sec
    .if (.match ({byte1}, a))
        sbc arg1
        beq :+
        bcs dec_hi
:       eor #$ff
        clc
        adc #$01
        sta arg1
        jmp l1
dec_hi:
        dec 1+(arg1)
        bcs :-
    .else
        lda arg1
        sbc byte1
        sta arg1
        bcs l1
        dec 1+(arg1)
    .endif
l1:
.endmacro

.macro put_s argX, argY, argS, yOffset
        ldx     argX
        ldy     argY
    .ifnblank yOffset
        tya
        clc
        adc   yOffset
        tay
    .endif

    .if (.match (.left (1, {argS}), #))
        lda     #<(.right (.tcount ({argS})-1, {argS}))
        sta     tmp9
        lda     #>(.right (.tcount ({argS})-1, {argS}))
        sta     1+(tmp9)
    .else
        lda     argS
        sta     tmp9
        lda     1+(argS)
        sta     tmp9+1
    .endif
        jsr     _put_s
.endmacro


.macro put_help argNum, msg
        pusha   argNum
        setax   msg
        jsr     _put_help
.endmacro

.macro put_status argNum, msg
        pusha   argNum
        setax   msg
        jsr     _put_status
.endmacro

.macro pause j
        lda     j
        jsr     _pause
.endmacro