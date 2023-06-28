; Display list handling, and DLI routines to support screen.

; Heavily influenced by U1MB/S3 by FJC.

    icl "inc/antic.inc"

    .public init_dl
    .reloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initialise display list

init_dl .proc
        ; make new dlist active
        mwa #dlist SDLSTL
        rts
.endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main display list

dlist
        ; blank lines and initial DLIs
        dta DL_BLK2
        dta DL_BLK6 + DL_DLI                                    ; DLI 0
        dta DL_BLK8
        dta DL_BLK4 + DL_DLI                                    ; DLI 1

        ; curved header
        dta DL_MODEF + DL_LMS, a(gl1)       ; 0f ff x 38 f0
        dta DL_MODEF                        ; 3f ff x 38 fc
        dta DL_MODEF                        ; 7f ff x 38 fe
        dta DL_MODEF                        ; 7f ff x 38 fe

        ; spacer
    :6  dta DL_MODEF + DL_LMS, a(gbk)       ; 6 x ff x 40

        ; main graphics header
        dta DL_MODEF + DL_LMS, a(ghd)       ; start of 24 line graphics header
    :23 dta DL_MODEF

        ; spacers, gbk = 40 x ff
    :8  dta DL_MODEF + DL_LMS, a(gbk)
        dta DL_MODEF + DL_LMS + DL_DLI, a(gbk)                  ; DLI 2

        ; status line for current state
        dta DL_MODE2 + DL_LMS, a(sline)

        ; gwht = 40 x 00
        dta DL_MODEF + DL_LMS, a(gwht)
        dta DL_MODEF + DL_LMS + DL_DLI, a(gwht)                 ; DLI 3

        ; inner curve TOP of main text area
        dta DL_MODEF + DL_LMS, a(gintop1)
        dta DL_MODEF + DL_LMS, a(gintop2)   ; this runs after last, could drop the LMS bit
        ; top of text DLI (for L1)
        dta DL_MODEF + DL_LMS + DL_DLI, a(gintop2)              ; DLI 4 (top of L1)

        dta DL_BLK2
        ; LINE 1 + DLI (which triggers for L2)
        dta DL_MODE2 + DL_LMS + DL_DLI, a(m_l1)                 ; DLI 5 (top of L2)

        ; LINE 2, TODO: why not BL_BLK2 here?
    :2  dta DL_BLK1
        dta DL_MODE2

        ; LINE 3-9 - at this point DLI is on blank line before the text line
        dta DL_BLK1 + DL_DLI, DL_BLK1, DL_MODE2                 ; DLI 6 (top of L3)
        dta DL_BLK1 + DL_DLI, DL_BLK1, DL_MODE2                 ; DLI 7 (top of L4)
        dta DL_BLK1 + DL_DLI, DL_BLK1, DL_MODE2                 ; DLI 8 (top of L5)
        dta DL_BLK1 + DL_DLI, DL_BLK1, DL_MODE2                 ; DLI 9 (top of L6)
        dta DL_BLK1 + DL_DLI, DL_BLK1, DL_MODE2                 ; DLI 10 (top of L7)
        dta DL_BLK1 + DL_DLI, DL_BLK1, DL_MODE2                 ; DLI 11 (top of L8)
        dta DL_BLK1 + DL_DLI, DL_BLK1, DL_MODE2                 ; DLI 12 (top of L9)

        ; LINE 10
        dta DL_BLK1 + DL_DLI, DL_MODE2                          ; DLI 13 (top of L10)

        ; inner curve BOTTOM of main text area
        dta DL_BLK2 + DL_DLI                                    ; DLI 14 (top of close inner curve)
    :2  dta DL_MODEF + DL_LMS, a(gintop2)

        dta DL_MODEF + DL_LMS + DL_DLI, a(gintop1)              ; DLI 15 (end of close inner curve)

        ; spacer, 40x00 x 3
    :3  dta DL_MODEF + DL_LMS, a(gwht)

        ; help text
        dta DL_MODE2 + DL_LMS, a(m_help)

        ; why m3 here?
        dta DL_MODE2 + DL_LMS, a(gwht)

        ; profile line
        dta DL_MODE2 + DL_LMS + DL_DLI, a(m_prf)                ; DLI 16 (end of profile, before close curve)

        ; spacer
        dta DL_MODEF + DL_LMS, a(gbk)

        ; close curve
    :2  dta DL_MODEF + DL_LMS, a(goutbtm1)
        dta DL_MODEF + DL_LMS, a(goutbtm2)
        dta DL_MODEF + DL_LMS, a(gl1)
        dta DL_MODEF + DL_LMS, a(gwht)

        ; finally, wsync jump back to top
        dta DL_JVB, a(dlist)


gl1     ; a few lines of graphics for the curved section above main graphics
        dta $0f
    :38 dta $ff
        dta $f0

        dta $3f
    :38 dta $ff
        dta $fc

        dta $7f
    :38 dta $ff
        dta $fe

        dta $7f
    :38 dta $ff
        dta $fe

gbk     ; simple full line
    :40 dta $ff

gwht    ; simple empty line
    :40 dta $00

gintop1
        dta $ff, $fe
    :36 dta $00
        dta $7f, $ff

gintop2
        dta $ff, $f8
    :36 dta $00
        dta $1f, $ff

goutbtm1
        dta $7f
    :38 dta $ff
        dta $fe

goutbtm2
        dta $3f
    :38 dta $ff
        dta $fc

ghd     ins 'fn320x24.hex'

sline   dta d'  status line       123456789012345678  '
m_l1    dta d'  line 1            123456789012345678  '
m_l2    dta d'  line 2            123456789012345678  '
m_l3    dta d'  line 3            123456789012345678  '
m_l4    dta d'  line 4            123456789012345678  '
m_l5    dta d'  line 5            123456789012345678  '
m_l6    dta d'  line 6            123456789012345678  '
m_l7    dta d'  line 7            123456789012345678  '
m_l8    dta d'  line 8            123456789012345678  '
m_l9    dta d'  line 9            123456789012345678  '
m_l10   dta d'  line 10           123456789012345678  '
m_help  dta d'  help line         123456789012345678  '
m_prf   dta d'  profile           123456789012345678  '
