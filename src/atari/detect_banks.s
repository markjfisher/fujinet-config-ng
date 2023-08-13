        .export     detect_banks, bank_table
        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"

.segment "PREINIT"

MAX_BANKS   := 8

.proc detect_banks

        ; rts

        ; cut down detection of banks. we just want up to 8 (16kb x 8 = 128kb) for paging dir structures etc.

        ; courtesy of FJC
        ; https://forums.atariage.com/topic/150125-challenge-determining-amount-of-ram-in-800xl/?do=findComment&comment=1832615

        mva     #$00, SDMCTL

        ; wait for screen to refresh x 2 so it's fully black and get no corruption. It will come back on later
        jsr     pause_vcount1
        jsr     pause_vcount1

        sei
        lda     NMIEN
        pha                     ; save NMIEN
        mva     #$00, NMIEN     ; turn off interrupts
        lda     PORTB
        pha                     ; save PORTB

        ; try values in PORTB and then check which caused us to write the X value and read it back indicating a valid PORTB for new bank

        ldx     #$00
test_lp1:
        stx     PORTB
        lda     $4000
        sta     save_table, x
        lda     $4001
        sta     save_table+256, x

        txa
        sta     $4000
        clc
        adc     #$04
        sta     $4001
        inx
        bne     test_lp1

        ldy     #0
test_lp2:
        stx     PORTB
        cpx     $4000
        bne     not_same
        txa
        clc
        adc     #$04
        cmp     $4001
        bne     not_same
        txa
        cmp     #$ff            ; ignore main bank $ff
        beq     not_same
        sta     bank_table, y
        iny
        cpy     #MAX_BANKS      ; MAX BANK COUNT
        beq     finish

not_same:
        inx
        bne     test_lp2

finish:
        ldx     #0
restore:
        stx     PORTB
        lda     save_table, x
        sta     $4000
        lda     save_table+256, x
        sta     $4001
        inx
        bne     restore

        pla
        sta     PORTB
        pla
        sta     NMIEN
        cli

        rts

pause_vcount1:
:       lda VCOUNT
        bne :-

:       lda VCOUNT
        beq :-
        rts



.endproc

; don't store it in the file
.segment "PREINIT2"
save_table:     .res 512

.segment "LOWDATA"
bank_table:     .byte 0, 0, 0, 0, 0, 0, 0, 0
