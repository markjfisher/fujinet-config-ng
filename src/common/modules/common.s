        .export     show_list
        .import     _fn_put_digit, _fn_put_s, s_empty
        .import     popa, pushax
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"
        .include    "fn_mods.inc"

; --------------------------------------------
; code common to multiple modules
; --------------------------------------------

; void show_list(uint8 dataSize, void * ptrToData)
;
; show 8 strings on screen in list fashion, used on hosts and devices.
.proc show_list
        getax   ptr1            ; ptrToData, the string to display's location
        popa    sl_size         ; how much to move down each data block

        mva     #$00, sl_index

        ; A has sl_index at this point
l_all:  clc
        adc     #SL_Y
        pha                     ; save current y coord

        ; --------- print digit
        tay                     ; y coord for fn_put_digit
        ldx     #SL_X           ; x coord for fn_put_digit
        lda     sl_index        ; digit to display, C is 0 already
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
        ; x + DX for start of the string to display in x coordinate
        lda     #SL_X
        clc
        adc     #SL_DX
        tax                     ; x coordinate of the string to display

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
        cmp     #SL_COUNT
        ; repeat for all N items in list
        bne     l_all

        rts
.endproc

.bss
sl_index:   .res 1
sl_size:    .res 1
