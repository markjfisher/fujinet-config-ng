        .export     detect_banks, _bank_table, _bank_count
        .include    "fc_zp.inc"
        .include    "atari.inc"
        .include    "fc_macros.inc"

.segment "INIT"

MAX_BANKS       := 64
ext_b           := $4000

; adapted from http://atariki.krap.pl/index.php/Obs%C5%82uga_standardowego_rozszerzenia_pami%C4%99ci_RAM

; void detect_banks()
.proc detect_banks
        mva     #$00, SDMCTL

        ; wait for screen to refresh x 2 so it's fully black and get no corruption. It will come back on later
        jsr     pause_vcount1
        jsr     pause_vcount1

        lda     PORTB
        pha
        lda     #$ff
        sta     PORTB
        lda     ext_b
        pha

        ldx     #$0f       ; save ext bytes (from 16 64k blocks) 
_p0:    jsr     setpb
        lda     ext_b
        sta     bsav,x
        dex
        bpl     _p0

        ldx     #$0f       ; reset them (w separate loop, because it is not known 
_p1:    jsr     setpb      ; which PORTB bit combinations select the same banks) 
        lda     #$00
        sta     ext_b
        dex
        bpl     _p1

        stx     PORTB      ; eliminate core memory (X=$FF) 
        stx     ext_b
        stx     $00        ; necessary for some extensions up to 256k

        ldy     #$00       ; block counting loop 64k
        ldx     #$0f
_p2:    jsr     setpb
        lda     ext_b      ; if ext_b is non-zero, block 64k already counted
        bne     _n2

        dec     ext_b      ; otherwise mark as counted 

        lda     ext_b      ; check if it is marked; if not -> something wrong with the hardware
        bpl     _n2

        lda     PORTB      ; enter the value of PORTB into the array for bank 0
        sta     banks,y
        eor     #%00000100 ; fill in values ​​for banks 1, 2, 3 
        sta     banks+1,y
        eor     #%00001100
        sta     banks+2,y
        eor     #%00000100
        sta     banks+3,y
        iny
        iny
        iny
        iny

_n2:    dex
        bpl     _p2

        ldx     #$0f       ; restore content ext
_p3:    jsr     setpb
        lda     bsav,x
        sta     ext_b
        dex
        bpl     _p3

        stx     PORTB      ; X = $FF

        pla
        sta     ext_b

        pla
        sta     PORTB

        ; copy MAX_BANKS from banks into _bank_table, which is permanent memory
        ldx     #$00
:       lda     banks, x
        beq     finished
        sta     _bank_table, x
        inx
        cpx     #MAX_BANKS
        bne     :-

finished:
        stx     _bank_count

        rts

; subroutines
setpb:  txa     ; change bit order: %0000dcba -> %cba000d0
        lsr            
        ror
        ror
        ror
        adc     #$01 ; set bit 1 depending on state C
        ora     #$01 ; set OS ROM control bit to default value [1]
        ; and    #$fe ; alternate version if OS ROM should be DISABLED
        sta     PORTB
        rts

pause_vcount1:
:       lda     VCOUNT
        bne     :-

:       lda     VCOUNT
        beq     :-
        rts


.endproc

; don't store it in the file, just some memory that will be overwritten after routine finished
.segment "INIT_NS"
bsav:   .res 16
banks:  .res 64

.segment "LOW_DATA"
_bank_count:     .byte 0
_bank_table:     .res MAX_BANKS, 0
