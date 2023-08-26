; stub SIOV
    .include    "fn_macros.inc"
    .include    "fn_data.inc"
    .include    "fn_io.inc"
    .export     t_v

    .segment "SIO"
    .org SIOV
    mwa IO_DCB::dbuflo, $80

    ldy #0
    mva t_v, {($80), y}
    rts

t_v: .byte 0
