        .export     show_list
        .import     s_empty, get_scrloc, ascii_to_code
        .import     popa, pushax, popax

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"
        .include    "modules.inc"

; void show_list(void *index_print_cb, uint8_t max_count, uint8_t dataSize, char *str)
;
; show 8 strings on screen in list fashion, used on hosts and devices.
.proc show_list
        axinto  ptr1            ; str, the string to display's location
        popa    sl_size         ; how much to move down each data block
        popa    sl_max_cnt      ; maximum number to display in list
        popax   sl_callback     ; routine to call that takes list number in A and prints up to 5 chars for index value (allowing customisation). It expects ptr4 to point to start of printing area

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
        mwa     #s_empty, ptr3
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
        jmp     (sl_callback)
        ; implicit rts in callback

.endproc

.bss
sl_index:    .res 1
sl_size:     .res 1
sl_callback: .res 2
sl_max_cnt:  .res 1