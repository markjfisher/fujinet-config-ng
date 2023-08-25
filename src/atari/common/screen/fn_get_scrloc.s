        .export     fn_get_scrloc
        .import     m_l1
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

; INTERNAL routine to set ptr4 to the screen location for the given X,Y coordinates
; X = x coord, Y = y coord
;
; the coordinates allowable are 36x16 grid, which is inside a larger frame of 40x18
; TRASHES tmp4. Y, sets ptr4
; DO NOT TRASH OTHER ZP VALUES. for efficiency and to reduce memory usage.
.proc fn_get_scrloc
        stx     tmp4            ; x coord

        mwa     #m_l1, ptr4     ; start of screen memory
        adw1    ptr4, #$02      ; shift inside border

        ; add x coordinate to ptr4
        adw1    ptr4, tmp4

        ; now move down in lines of 40, y times
        cpy     #$00
        beq     out
:       adw     ptr4, #40     ; 40 bytes per row
        dey
        bne     :-

out:
        rts
.endproc
