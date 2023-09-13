    .export     start

    .import     _main
    .import     __LOWCODE_RUN__, __LOWCODE_SIZE__
    .import     __MAIN_START__, __MAIN_SIZE__
    .import     __STACKSIZE__
    .import     callmain
    .import     donelib
    .import     initlib
    .import     zerobss

    .include    "atari.inc"
    .include    "fc_zp.inc"
    .include    "fn_macros.inc"

; This is a cut down version of cc65's atari crt0.s

.segment "STARTUP"
    rts

start:
    jsr     zerobss

    tsx
    stx     SP_save
    ldx     #$ff
    txs

    cld
    ; Stack works DOWNWARDS! So need to add the stack size here
    mwa     {#(__MAIN_START__ + __MAIN_SIZE__ + __STACKSIZE__)}, sp

    lda     LMARGN
    sta     __LMARGN_save
    ldy     #0
    sty     LMARGN

    ldx     SHFLOK
    stx     SHFLOK_save
    sty     SHFLOK

    dey                     ; Set Y to $FF
    sty     CH              ; remove keypress which might be in the input buffer

    jsr     initlib
    jsr     callmain

_exit:  
    ldx     SP_save
    txs                     ; Restore stack pointer

excexit:
    jsr     donelib         ; Run module destructors; 'excexit' is called from the exec routine

    lda     __LMARGN_save
    sta     LMARGN
    lda     SHFLOK_save
    sta     SHFLOK
    ldx     #0
    stx     CRSINH
    rts

.bss

SP_save:        .res    1
SHFLOK_save:    .res    1
__LMARGN_save:  .res    1

; ------------------------------------------------------------------------

.segment "LOWCODE"       ; have at least one (empty) segment of LOWCODE, so that the next line works even if the program doesn't make use of this segment
.assert (__LOWCODE_RUN__ + __LOWCODE_SIZE__ <= $4000 || __LOWCODE_RUN__ > $7FFF || __LOWCODE_SIZE__ = 0), warning, "'lowcode area' reaches into $4000..$7FFF bank memory window"
; check for LOWBSS_SIZE = 0 not needed since the only file which uses LOWBSS (irq.s) also uses LOWCODE
; check for LOWCODE_RUN > $7FFF is mostly for cartridges, where this segment is loaded high (into cart ROM)
; there is a small chance that if the user loads the program really high, LOWCODE is above $7FFF, but LOWBSS is below -- no warning emitted in this case
