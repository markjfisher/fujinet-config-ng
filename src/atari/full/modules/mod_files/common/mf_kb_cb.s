        .export     mf_kb_cb
        .export     mf_kb_cb_reset_anim

        .import     kb_idle_counter
        .import     mf_selected
        .import     mf_y_offset
        .import     mfp_filename_cache
        .import     mf_filename_lengths
        .import     _put_s
        .import     pushax

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

.segment "CODE2"

mf_kb_cb:
        ; Save registers and zero page variables (DLI context)
        pha
        txa
        pha
        tya
        pha
        
        ; Save zero page variables we'll use
        mwa     ptr1, saved_ptr1
        mwa     ptr2, saved_ptr2  
        mwa     tmp9, saved_tmp9

        ; Get pre-calculated filename length
        ldx     mf_selected
        lda     mf_filename_lengths,x
        sta     filename_len
        
        ; Check if animation is needed (length > screen width)
        cmp     #SCR_WID_NB-2       ; -2 for space + border on right side
        bcc     done                ; filename fits, no animation needed

        ; Get pointer to current filename from cache
        ; mfp_filename_cache[mf_selected * 2] -> ptr1
        lda     mf_selected
        asl                         ; multiply by 2 for pointer array
        tay
        mywa    {mfp_filename_cache, y}, ptr1

        ; Check if pointer is valid (non-zero)
        lda     ptr1
        ora     ptr1+1
        beq     done                ; No filename cached yet

        ; Calculate starting position in filename
        lda     anim_index
        clc
        adc     ptr1
        sta     ptr2
        lda     ptr1+1
        adc     #$00
        sta     ptr2+1

        ; Display the filename starting from animation offset
        put_s   #$01, mf_selected, ptr2, mf_y_offset

        ; Update animation index
        lda     anim_direction
        beq     move_right
        
move_left:
        ; Moving left (decreasing index)
        lda     anim_index
        beq     reverse_to_right    ; Hit left boundary
        dec     anim_index
        jmp     done

move_right:
        ; Moving right (increasing index)
        ; Check if we can advance without going past the end
        ; Last valid position: filename_len - (SCR_WID_NB-2)
        lda     filename_len
        sec
        sbc     #SCR_WID_NB-2       ; filename_len - display_width (space + border on right)
        cmp     anim_index
        beq     reverse_to_left     ; We're at the last valid position
        bcc     reverse_to_left     ; We've gone past it (shouldn't happen)
        inc     anim_index
        jmp     done

reverse_to_right:
        mva     #0, anim_direction  ; Change to moving right
        inc     anim_index
        jmp     done

reverse_to_left:
        mva     #1, anim_direction  ; Change to moving left
        dec     anim_index
        ; fall through to done

done:
        ; Restore zero page variables
        mwa     saved_ptr1, ptr1
        mwa     saved_ptr2, ptr2
        mwa     saved_tmp9, tmp9
        
        ; Restore registers
        pla
        tay
        pla
        tax
        pla
        rts

; Reset animation state when selection changes
mf_kb_cb_reset_anim:
        mva     #0, anim_index
        mva     #0, anim_direction
        rts

.bss
anim_index:     .res 1      ; Current starting position in filename
anim_direction: .res 1      ; 0=moving right, 1=moving left  
filename_len:   .res 1      ; Length of current filename

; Saved zero page variables for DLI context
saved_ptr1:     .res 2
saved_ptr2:     .res 2
saved_tmp9:     .res 2