; Display list handling, and DLI routines to support screen.

; Heavily influenced by U1MB/S3 by FJC.

    icl "inc/antic.inc"
    icl "inc/gtia.inc"
    icl "inc/os.inc"
    icl "../macros.mac"

    .public init_dl
    .extrn decompress .proc
    .extrn d_dst, d_src .byte
    .reloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initialise display
; sets up dlist memory, and DLI/VBLANK/NMI routines

init_dl .proc
        ; decompress the heading gfx into target
        mwa #ghdz d_src
        mwa #ghd d_dst
        decompress

        ; turn off screen and IRQs while we change things
        jsr init_screen

        ; setup VBLANK routine
        mwa #do_vblank vvblki

        ; point to the new dlist instructions
        mwa #main_dlist dlistl

        ; mvy #$01 prior      ; Player 0 - 3, playfield 0 - 3, BAK
        mvy #$02 chactl          ; cursor: opaque/absent
        mva #$e0 chbase     ; fonts e400

        ; mva #$30 hposp1
        ; mva #$c8 hposp2
        ; mva #$c7 hposm0
        ; sty      sizep1
        ; sty      sizep2
        ; sty      sizep3
        ; sty      hposm1
        ; sty      hposm2
        ; sty      hposm3
        ; iny
        ; sty sizep0

        ;; whole routine started at $c31e, ends up affecting PACTL
        mva #$3c PACTL      ; cassette motor off, porta register

        ; jsr highlight_current_option

        ; now need to fill lines with text for current option
        jsr fill_lines

        mva #$00 colpf3 // back
        mva #$28 colpf0 // ball         (red)
        mva #$ca colpf1 // fujinet logo (yellow)
        mva #$94 colpf2 // items        (blue)

        ; show screen, implicit RTS at the end
        jmp show_screen

.endp

; clear sdmctl and gractl at start of screen.
init_screen
        mva #$00 nmien      ; don't allow interrupts while we work
        jsr wait_scan1
        mva #$00 sdmctl
        sta      gractl
        sta      dmactl
        ; jmp wait_scan1      ; implicit RTS

wait_scan1
        ; use MADS 'repeat' loops to wait for VCOUNT = 0, then VCOUNT = 1
        lda:rne vcount
        lda:req vcount
        rts

show_screen
        mva #$40 nmien      ; just VBI
        mva #$22 sdmctl     ; no more dlis
        mva #$22 dmactl
        jmp wait_scan1

fill_lines
        ; this will call the option specific routine to display lines of text
        ; and will eventually move out of this file
        rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VBLANK routine

; without doing a vblank that does nothing, the screen resets... why?

do_vblank
        plr
        rti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DATA

; colour values. high nyble is the colour number. low is dark/medium/high brightness
s_col_0 dta $10
s_col_1 dta $18
s_col_2 dta $1e
s_col_3 dta $08  ; brightness of text. this was applied each line, e=bright, 8=med

; current option
i_opt   dta $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main display list

main_dlist
        dta DL_BLK4

        ; main graphics header
        dta DL_MODED + DL_LMS, a(ghd)       ; start of 28 line graphics header
    :27 dta DL_MODED

        ; spacers, gbk = 40 x ff
    :2  dta DL_MODEF + DL_LMS, a(gbk)

        ; status line for current state
        dta DL_MODE2 + DL_LMS, a(sline)

        ; spacers, gbk = 40 x ff
    :2  dta DL_MODEF + DL_LMS, a(gbk)

        ; gwht = 40 x 00
    ;:1  dta DL_MODEF + DL_LMS, a(gwht)

        ; inner curve TOP of main text area
        dta DL_MODEF + DL_LMS, a(gintop1)
        dta DL_MODEF;  + DL_LMS, a(gintop2)   ; this runs after last, so dropping LMS instruction
        ; top of text (for L1)
        dta DL_MODEF + DL_LMS, a(gintop2)              ; DLI 4 (top of L1)

        ; LINE 1
        dta DL_MODE2 + DL_LMS, a(m_l1)

    :17  dta DL_MODE2                          ; L2 - L..

        ; inner curve BOTTOM of main text area
    :2  dta DL_MODEF + DL_LMS, a(gintop2)

        dta DL_MODEF + DL_LMS, a(gintop1)                ; (end of close inner curve)

        ; spacers, gbk = 40 x ff
    :2  dta DL_MODEF + DL_LMS, a(gbk)

        ; help text
        dta DL_MODE2 + DL_LMS, a(m_help)

        ; spacers, gbk = 40 x ff
    :2  dta DL_MODEF + DL_LMS, a(gbk)

;         ; close curve
;     :2  dta DL_MODEF + DL_LMS, a(goutbtm1)
;         dta DL_MODEF + DL_LMS, a(goutbtm2)
;         dta DL_MODEF + DL_LMS, a(gl1)
;         dta DL_MODEF + DL_LMS, a(gwht)

        ; finally, wsync jump back to top
        dta DL_JVB, a(main_dlist)

; END OF DLIST

gbk     ; simple full line
    :40 dta $ff

; curved lines
gintop1
        dta $ff, $e0
    :36 dta $00
        dta $07, $ff

gintop2
        dta $ff, $80
    :36 dta $00
        dta $01, $ff

; ghd     ins 'fn320x24.hex'
; test decompression, reserve space for decompressed image
; 40x24x2
;ghd :960 dta $00
; 40x28x4 ??
ghd :1120 dta $00

; actual compressed data
; ghdz    ins 'fn320x24.z'
ghdz    ins 'fn-160x28x4c.z'


m_l1    dta $80, d' line 1                         01234 ', $80
m_l2    dta $80, d' line 2                         01234 ', $80
m_l3    dta $80, d' line 3                         01234 ', $80
m_l4    dta $80, d' line 4                         01234 ', $80
m_l5    dta $80, d' line 5                         01234 ', $80
m_l6    dta $80, d' line 6                         01234 ', $80
m_l7    dta $80, d' line 7                         01234 ', $80
m_l8    dta $80, d' line 8                         01234 ', $80
m_l9    dta $80, d' line 9                         01234 ', $80
m_l10   dta $80, d' line 10                        01234 ', $80
m_l11   dta $80, d' line 11                        01234 ', $80
m_l12   dta $80, d' line 12                        01234 ', $80
m_l13   dta $80, d' line 13                        01234 ', $80
m_l14   dta $80, d' line 14                        01234 ', $80
m_l15   dta $80, d' line 15                        01234 ', $80
m_l16   dta $80, d' line 16                        01234 ', $80
m_l17   dta $80, d' line 17                        01234 ', $80
m_l18   dta $80, d' line 18                        01234 ', $80

sline   dta d'  status line       123456789012345678  '*
m_help  dta d'  help line         123456789012345678  '*
