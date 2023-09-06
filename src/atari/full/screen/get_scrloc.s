        .export     get_scrloc
        .import     m_l1
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; INTERNAL routine to set ptr4 to the screen location for the given X,Y coordinates
; X = x coord, Y = y coord
;
; the coordinates allowable are (SCR_WIDTH-2) x SCR_HEIGHT grid, inside the border by 1 char
; TRASHES tmp4. Y, sets ptr4
; DO NOT TRASH OTHER ZP VALUES. for efficiency and to reduce memory usage.
.proc get_scrloc
        mwa     #m_l1, ptr4     ; start of screen memory

        ; add x coordinate to ptr4
        inx     ; shift inside border
        txa
        adw1    ptr4, a

        ; now move down in lines of SCR_WIDTH, y times
        cpy     #$00
        beq     out
:       adw1    ptr4, #SCR_BYTES_W
        dey
        bne     :-

out:
        rts
.endproc
