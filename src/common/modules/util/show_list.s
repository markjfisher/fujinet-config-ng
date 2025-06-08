        .export     show_list

        .export     sl_callback
        .export     sl_max_cnt
        .export     sl_size
        .export     sl_str_loc

        .import     _s_empty
        .import     ascii_to_code
        .import     get_scrloc

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fujinet-fuji.inc"
        .include    "fn_data.inc"
        .include    "modules.inc"

.segment "CODE2"

; show list of strings on screen, used on hosts and devices.
.proc show_list

        mwa     sl_str_loc, ptr1
        mva     #$00, sl_index

        ldy     #SL_Y
        ldx     #$00
        jsr     get_scrloc      ; ptr4 has screen location of (0, SL_Y)

        lda     sl_index        ; set A to current index for the callback
all_list:
        ; print the list number + customisations
        jsr     call_cb
        adw1    ptr4, #SL_EDIT_X      ; increment to edit location

        ; print string (or <Empty>)
        mwa     ptr1, ptr3
        ldy     #0
        lda     (ptr3), y
        bne     :+
        mwa     #_s_empty, ptr3
:
        ; print characters from s in ptr3, 1 by 1 until hit a 0, or hit x=36 in boundary
next_char:
        lda     (ptr3), y       ; char to print in A
        beq     :+              ; end of string

        jsr     ascii_to_code
        sta     (ptr4), y       ; print char
        iny                     ; move across a character, used for string and screen loc
        cpy     #(SCR_WID_NB-SL_EDIT_X)
        bne     next_char

        ; Increment ptr1/4 location to next entry and screen location
:       inc     sl_index
        adw1    ptr1, sl_size
        adw1    ptr4, {#(SCR_BYTES_W-SL_EDIT_X)}       ; 40 - 5 chars for the next list number

        lda     sl_index
        cmp     sl_max_cnt
        ; repeat for all N items in list
        bne     all_list

        rts

call_cb:
        ldx     sl_callback
        stx     ptr3
        ldx     sl_callback+1
        stx     ptr3+1
; smc:
        jmp     (ptr3)

.endproc

.segment "BANK"
sl_index:    .res 1
sl_size:     .res 1
sl_callback: .res 2
sl_max_cnt:  .res 1
sl_str_loc:  .res 2