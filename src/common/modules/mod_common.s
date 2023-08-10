        .export     show_list
        .import     _fn_put_digit, _fn_put_s, s_empty
        .import     popa, pushax
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

; void show_list(uint8 dataSize, void * ptrToData)
;
; common code for hosts and devices that show 8 strings on screen in list fashion.
.proc show_list
        getax   ptr1            ; ptrToData
        popa    sl_size         ; how much to move down each data block

        ; thought these would be params: TODO: if they never change, inline them.
        mva     #$04, sl_x
        mva     #$02, sl_y
        mva     #$08, sl_count

        mva     #$00, sl_index

        ; A has sl_index at this point
l_all:  clc
        adc     sl_y
        pha                     ; save current y coord

        ; --------- print digit
        tay                     ; y coord for fn_put_digit
        ldx     sl_x            ; x coord for fn_put_digit
        lda     sl_index        ; digit to display
        adc     #$01            ; index is 0 based, need to increment for screen. C is clear already
        jsr     _fn_put_digit

        ; --------- print string
        ; TODO: ELIPSES FOR LONG STRINGS
        ldy     #0
        lda     (ptr1), y
        beq     display_empty   ; if the string is null, display <Empty> instead

        pushax  ptr1
        jmp     j1

display_empty:
        pushax  #s_empty

j1:
        ; x+2 for start of the string to display in x coordinate
        ldx     sl_x
        inx
        inx

        pla                     ; restore current y
        tay
        jsr     _fn_put_s

        ; Increment ptr1 location to next entry
        lda     ptr1
        clc
        adc     sl_size
        sta     ptr1
        bcc     :+
        inc     ptr1+1

:       inc     sl_index
        lda     sl_index
        cmp     sl_count
        ; repeat for all N items in list
        bne     l_all

        rts
.endproc

.bss
sl_index:   .res 1
sl_size:    .res 1
sl_x:       .res 1
sl_y:       .res 1
sl_count:   .res 1
