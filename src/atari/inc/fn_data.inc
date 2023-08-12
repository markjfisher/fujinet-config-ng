; mostly used to directly get daux1 address
.struct IO_DCB
    .org $0300
    ddevic  .byte
    dunit   .byte
    dcomnd  .byte
    dstats  .byte
    dbuflo  .byte
    dbufhi  .byte
    dtimlo  .byte
    dunuse  .byte
    dbytlo  .byte
    dbythi  .byte
    daux1   .byte
    daux2   .byte
.endstruct

; show_list constants for screen coordinate starting points etc.
SL_X        := 2
SL_Y        := 2
SL_DX       := 3
SL_COUNT    := 8
