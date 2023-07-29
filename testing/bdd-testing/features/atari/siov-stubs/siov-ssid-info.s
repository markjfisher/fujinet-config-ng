; stub SIOV
    .include    "atari.inc"
    .include    "../../../../../src/inc/macros.inc"
    .include    "../../../../../src/atari/fn_io.inc"
    .export     info

    .segment "SIOSEG"
    .org SIOV

    ; copy data into "info"
    mwa DBUFLO, $80
    ldy #8
:   mva {t_ssid, y}, {info + SSIDInfo::ssid, y}
    dey
    bpl :-
    mva t_rssi, {info + SSIDInfo::rssi}

    ; copy the test ssidinfo to the caller's buffer.
    ldy #34
:   mva {info, y}, {($80), y}
    dey
    bpl :-

    rts

t_ssid:  .byte "ssidtime"
t_rssi:  .byte $69
info:    .tag SSIDInfo
