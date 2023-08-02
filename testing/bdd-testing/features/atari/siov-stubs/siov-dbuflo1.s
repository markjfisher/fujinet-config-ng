; stub SIOV
    .include    "atari.inc"
    .include    "../../../../../src/inc/fn_macros.inc"
    .export     t_v

    .segment "SIOSEG"
    .org SIOV
    mwa DBUFLO, $80

    ldy #0
    mva t_v, {($80), y}
    rts

t_v: .byte 0
