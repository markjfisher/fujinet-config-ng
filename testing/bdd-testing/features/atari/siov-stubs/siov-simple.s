; stub SIOV
    .include    "atari.inc"
    .include    "../../../../../src/inc/macros.inc"

    .segment "SIOSEG"
    .org SIOV
    mva #$01, $80
    rts
