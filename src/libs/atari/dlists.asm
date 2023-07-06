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

        mvy #$01 prior      ; Player 0 - 3, playfield 0 - 3, BAK
        iny
        sty chactl          ; cursor: opaque/absent
        mva #$e0 chbase     ; fonts e400

        mva #$30 hposp1
        mva #$c8 hposp2
        mva #$c7 hposm0
        sty      sizep1
        sty      sizep2
        sty      sizep3
        sty      hposm1
        sty      hposm2
        sty      hposm3
        iny
        sty sizep0

        ;; whole routine started at $c31e, ends up affecting PACTL
        mva #$3c PACTL      ; cassette motor off, porta register

        jsr highlight_current_option

        ; now need to fill lines with text for current option
        jsr fill_lines

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
        mva #$c0 nmien
        mva #$21 sdmctl     ; the next vblank will start the DLI routines
        jmp wait_scan1
;        rts

highlight_current_option
        jsr wait_scan1
        ldx i_opt
        mva opt_hp,x hposp0
        rts

fill_lines
        ; this will call the option specific routine to display lines of text
        ; and will eventually move out of this file
        rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VBLANK routine

do_vblank
        lda sdmctl
        bne screen_active
        sta colbk
        rti

screen_active
        mva s_col_0 colbk
        mva s_col_1 colpm1
        sta         colpm2
        mva s_col_2 colpm0
        sta         colpm3

        ; reset DLI to first entry
        mva #$00 i_dli
        mwa #dli_0 vdslst
        mva sdmctl dmactl

        plr
        rti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DLI routines for dlist

; these use 3 color values and rotate around to achieve
; the correct background/foreground colours for text
; and graphics at each part of the screen as it changes.
; Players are used for the side bars, and highlighting current option.
; The DLIs setup dmactl to set bytes per line.
; Reverse engineered from U1MB by FJC.

; top of the screen
dli_0
        pushAX
        lda s_col_1
        ldx s_col_0
        sta wsync
        sta colpf1
        stx colpf2

        mva #$22 dmactl

        ; player posn behind the FujiNet
        ; mva #$34 hposp3
        ; mva #$03 sizep3
        jmp next_dli

; top of outer curve
dli_1
        pushAX
        ; ldx #$fe            ; white behind FN logo
        ; mvx #$22 wsync
        ; stx      grafp0
        ; inx
        ; stx grafp3
        ; sta dmactl          ; #$22: enable DMA Fetch + normal playerfield
        jmp next_dli

; (above) status line - change colours to invert and merge into header colours 
dli_2
        pushAX
        ; mva #$00 wsync
        ; inverse for status line - this really looks nice, maybe if it's just an image and we have severl for each
        ; top level option copied in, it will mean being able to remove the DLI
        lda s_col_2
        ldx s_col_1
        sta wsync
        sta colpf1
        stx colpf2

        ; ; PMs for the side bars
        ; mva #$00 grafp0
        ; sta      grafp3
        ; mva #$fc grafp1
        ; mva #$3f grafp2
        jmp next_dli

; top of inner curve
dli_3
        pushAX
        lda s_col_1
        ldx s_col_0
        sta wsync
        sta colpf1
        stx colpf2
        jmp next_dli

; top of L1
dli_4
        pushAX
        mva s_col_3  wsync
        sta          colpf1
        mva #$21 dmactl     ; enable DMA fetch + narrow playfield
        mva #$00 grafm
        ; run into next_dli

; change to next dli routine in the table
next_dli
        inc i_dli
        ldx i_dli
        mva dli_tl,x vdslst
        mva dli_th,x vdslst+1
        pullAX
        rti

; top of close inner curve (smaller section before help text)
dli_5
        pushAX
        mva s_col_1 wsync
        sta colpf1
        mva #$22 dmactl
        mva #$00 grafm
        beq next_dli

; bottom of close inner curve (still above help)
dli_6
        pushAX
        lda s_col_2
        ldx s_col_1
        sta wsync
        sta colpf1
        stx colpf2
        jmp next_dli

; bootom of profile line
dli_7
        pushAX
        ldx s_col_0
        mva #$00 wsync
        sta      grafp1
        sta      grafp2
        stx colpf2
        mva s_col_1 colpf1
        jmp next_dli

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DATA

; colour values. high nyble is the colour number. low is dark/medium/high brightness
s_col_0 dta $10
s_col_1 dta $18
s_col_2 dta $1e
s_col_3 dta $08  ; brightness of text. this was applied each line, e=bright, 8=med

; dli routine index
i_dli   dta $00

; current option
i_opt   dta $00

; table of hposp0 positions for the options on top. only first cacluated so far.
opt_hp  dta $57 //, $61, $6f, $7e, $8c, $9a, $a8, $b6

; tables of dli L/H addresses.
; use mads looping to define them all from 0..7
; note using l() and h() works with relocatable code. using < and > didn't
dli_tl
    .rept 8, #
    dta l(dli_:1)
    .endr

dli_th
    .rept 8, #
    dta h(dli_:1)
    .endr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main display list

main_dlist
        ; blank lines and initial DLIs
        dta DL_BLK1
        dta DL_BLK1 + DL_DLI                                    ; DLI 0
        dta DL_BLK1
        dta DL_BLK1 + DL_DLI                                    ; DLI 1

        ; curved header
        dta DL_MODEF + DL_LMS, a(gl1)       ; 0f ff x 38 f0
        dta DL_MODEF                        ; 3f ff x 38 fc
        dta DL_MODEF                        ; 7f ff x 38 fe
        dta DL_MODEF                        ; 7f ff x 38 fe

        ; spacer
    :1  dta DL_MODEF + DL_LMS, a(gbk)       ; 6 x ff x 40

        ; main graphics header
        dta DL_MODEF + DL_LMS, a(ghd)       ; start of 24 line graphics header
    :23 dta DL_MODEF

        ; spacers, gbk = 40 x ff
    :2  dta DL_MODEF + DL_LMS, a(gbk)
        dta DL_MODEF + DL_LMS + DL_DLI, a(gbk)                  ; DLI 2

        ; status line for current state
        dta DL_MODE2 + DL_LMS, a(sline)

        ; gwht = 40 x 00
        dta DL_MODEF + DL_LMS, a(gwht)
        dta DL_MODEF + DL_LMS + DL_DLI, a(gwht)                 ; DLI 3

        ; inner curve TOP of main text area
        dta DL_MODEF + DL_LMS, a(gintop1)
        dta DL_MODEF;  + DL_LMS, a(gintop2)   ; this runs after last, so dropping LMS instruction
        ; top of text DLI (for L1)
        dta DL_MODEF + DL_LMS + DL_DLI, a(gintop2)              ; DLI 4 (top of L1)

        dta DL_BLK1
        ; LINE 1
        dta DL_MODE2 + DL_LMS, a(m_l1)                          ; (top of L2)

    :17  dta DL_BLK1, DL_MODE2                          ; L2 - L18

        ; inner curve BOTTOM of main text area
        dta DL_BLK1 + DL_DLI                                    ; DLI 5 (top of close inner curve)
    :2  dta DL_MODEF + DL_LMS, a(gintop2)

        dta DL_MODEF + DL_LMS + DL_DLI, a(gintop1)              ; DLI 6 (end of close inner curve)

        ; spacer, 40x00 x 3
    :2  dta DL_MODEF + DL_LMS, a(gwht)

        ; help text
        dta DL_MODE2 + DL_LMS, a(m_help)

    :1  dta DL_MODEF + DL_LMS + DL_DLI, a(gwht)                 ; DLI 7 (before close curve)

        ; close curve
    :2  dta DL_MODEF + DL_LMS, a(goutbtm1)
        dta DL_MODEF + DL_LMS, a(goutbtm2)
        dta DL_MODEF + DL_LMS, a(gl1)
        dta DL_MODEF + DL_LMS, a(gwht)

        ; finally, wsync jump back to top
        dta DL_JVB, a(main_dlist)

; END OF DLIST

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

; ghd     ins 'fn320x24.hex'
; test decompression, reserve space for decompressed image
ghd :960 dta $00

; actual compressed data
ghdz    ins 'fn320x24.z'

;; use raw images for the 

; 40 chars wide for status
sline   dta d'  status line       123456789012345678  '
; 32 chars wide for main lines
m_l1    dta d'line 1                     01234'
m_l2    dta d'line 2                     01234'
m_l3    dta d'line 3                     01234'
m_l4    dta d'line 4                     01234'
m_l5    dta d'line 5                     01234'
m_l6    dta d'line 6                     01234'
m_l7    dta d'line 7                     01234'
m_l8    dta d'line 8                     01234'
m_l9    dta d'line 9                     01234'
m_l10   dta d'line 10                    01234'
m_l11   dta d'line 11                    01234'
m_l12   dta d'line 12                    01234'
m_l13   dta d'line 13                    01234'
m_l14   dta d'line 14                    01234'
m_l15   dta d'line 15                    01234'
m_l16   dta d'line 16                    01234'
m_l17   dta d'line 17                    01234'
m_l18   dta d'line 18                    01234'
; 40 chars wide for lower text
m_help  dta d'  help line         123456789012345678  '
