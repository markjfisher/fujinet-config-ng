; Display list handling, and DLI routines to support screen.

; Heavily influenced by U1MB/S3 by FJC.

    icl "inc/antic.inc"
    icl "inc/gtia.inc"
    icl "inc/os.inc"
    icl "../macros.mac"

    .public init_dl, i_opt, run_module
    .extrn decompress .proc
    .extrn d_dst, d_src .byte
    .extrn t1, t2 .byte
    .extrn mod_table, mod_d .word
    .reloc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initialise display
; sets up dlist memory, and DLI/VBLANK/NMI routines

init_dl .proc
        ; turn off screen and IRQs while we change things
        jsr init_screen

        ; setup VBLANK routine
        mwa #do_vblank vvblki

        ; point to the new dlist instructions
        mwa #main_dlist dlistl

        mva #$02 chactl         ; cursor: opaque/absent
        mva #$3c PACTL          ; cassette motor off, porta register

        ; colours from header graphics.
        ; mva #$00 colpf3 // back
        ; mva #$28 colpf0 // ball         (red)
        ; mva #$ca colpf1 // fujinet logo (yellow)
        ; mva #$94 colpf2 // items        (blue)

        mva s_col_0 colpf1
        mva s_col_1 colpf2
        mva s_col_2 colpf3
        mva #$00 colpf0

        jmp show_screen
.endp

; clear sdmctl and gractl at start of screen.
init_screen
        mva #$00 nmien      ; don't allow interrupts while we work
        jsr wait_scan1
        mva #$00 sdmctl
        sta      gractl
        sta      dmactl

wait_scan1
        ; use MADS 'repeat' loops to wait for VCOUNT = 0, then VCOUNT = 1
        lda:rne vcount
        lda:req vcount
        rts

show_screen
        mva #$40 nmien      ; just VBI
        mva #$22 sdmctl
        mva #$22 dmactl
        jmp wait_scan1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run_module
;
; this will execute any code for the current module

run_module      .proc
        jsr call_module

        ; copy 38x16 bytes from mod_d to m_l1+2
        mwa mod_d t1
        mwa #m_l1 t2
        adw t2 #$2
        ldx #15           ; rows
ycol    ldy #35           ; columns
xrow    lda (t1), y
        sta (t2), y
        dey
        bpl xrow
        ; increment src and targets, catering for the initial space
        adw t1 #36     ; src is only 36 bytes wide
        adw t2 #40     ; target is 40 bytes wide
        dex
        bpl ycol
        rts

call_module
        ; call the module, allows it to set mod_d to 36x16 data to show
        lda i_opt
        asl
        tax
        lda mod_table + 1, x
        pha
        lda mod_table, x
        pha
        rts             ; Stack based dispatch - THIS DOES A JMP to mod_table address for current index
        ; the rts in the module will return to previous caller

        .endp

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
        dta DL_MODE2 + DL_LMS, a(sline1)
        dta DL_MODE2 + DL_LMS, a(sline2)

        ; spacers
    :2  dta DL_MODEF + DL_LMS, a(gbk)

        ; inner curve TOP of main text area
        dta DL_MODEF + DL_LMS, a(gintop1)
        dta DL_MODEF;  + DL_LMS, a(gintop2)   ; this runs after last, so dropping LMS instruction
        ; top of text (for L1)
        dta DL_MODEF + DL_LMS, a(gintop2)

        ; LINE 1 - 16
        dta DL_MODE2 + DL_LMS, a(m_l1)
    :15 dta DL_MODE2

        ; inner curve BOTTOM of main text area
    :2  dta DL_MODEF + DL_LMS, a(gintop2)

        dta DL_MODEF + DL_LMS, a(gintop1)

        ; spacers
    :2  dta DL_MODEF + DL_LMS, a(gbk)

        ; help text
        dta DL_MODE2 + DL_LMS, a(m_help1)
        dta DL_MODE2 + DL_LMS, a(m_help2)

        ; spacers
    :2  dta DL_MODEF + DL_LMS, a(gbk)

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

ghd    ins 'fn-160x28x4c.hex'

; main screen area. Information will be copied into here
m_l1    dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'          initialising...             ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80
        dta $80, d'                                      ', $80

sline1  dta d'  status line1      123456789012345678  '*
sline2  dta d'  status line2      123456789012345678  '*
m_help1 dta d'  help line1        123456789012345678  '*
m_help2 dta d'  help line2        123456789012345678  '*
