        .export     m_l1, sline1, sline2, mhlp1, mhlp2
        .include    "fn_macros.inc"

.data

    SCREENCODE_CHARMAP
m_l1:   .byte $80, " 123456789012345678901234567890123456 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1          a                       6 ", $80
        .byte $80, " 1          b                       6 ", $80
        .byte $80, " 1          c                       6 ", $80
        .byte $80, " 1          d                       6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 1                                  6 ", $80
        .byte $80, " 123456789012345678901234567890123456 ", $80

    SCREENCODE_INVERT_CHARMAP
sline1: .byte "  status line1      123456789012345678  "
sline2: .byte "  status line2      123456789012345678  "
mhlp1:  .byte "  help line1        123456789012345678  "
mhlp2:  .byte "  help line2        123456789012345678  "

    NORMAL_CHARMAP