; stub SIOV
    .include    "fn_data.inc"
    .include    "fn_macros.inc"

    .segment "SIO"
    .org SIOV

stubbed_sio:
    mva #$01, $80
    rts
