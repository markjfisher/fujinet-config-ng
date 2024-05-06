        .export     get_scrloc
        .import     m_l1
        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

; INTERNAL routine to set ptr4 to the screen location for the given X,Y coordinates
; X = x coord, Y = y coord
;
; the coordinates allowable are (SCR_WIDTH-2) x SCR_HEIGHT grid, inside the border by 1 char
; TRASHES Y, ptr3, sets ptr4
; DO NOT TRASH OTHER ZP VALUES. for efficiency and to reduce memory usage.
.proc get_scrloc
        mwa     #m_l1, ptr4     ; start of screen memory

        ; add x coordinate to ptr4
        inx     ; shift inside border
        txa
        adw1    ptr4, a

        ; now move down y lines
        cpy     #$00
        beq     out

        ; use table lookup to speed up screen offset calculation
        mwa     #add_width_table_lo, ptr3
        lda     (ptr3), y
        adw1    ptr4, a

        adw1    ptr3, #22       ; make it point to hi byte
        lda     (ptr3), y
        beq     out             ; first 7 lines don't need to add hi byte
        adw1    ptr4+1, a

out:
        rts
.endproc

.rodata

; calculate tables for the sum of (SCR_WIDTH_W) * y
add_width_table_lo:
        .repeat 22, I
                .byte .lobyte(SCR_BYTES_W * I)
        .endrep
add_width_table_hi:
        .repeat 22, I
                .byte .hibyte(SCR_BYTES_W * I)
        .endrep
