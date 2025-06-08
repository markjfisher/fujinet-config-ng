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
        ; Save minimal registers for length check only
        pha
        txa
        pha

        ; Get pre-calculated filename length
        ldx     mf_selected
        lda     mf_filename_lengths,x

        ; Check if animation is needed (length > screen width)
        cmp     #SCR_WID_NB-2       ; -2 for space + border on right side
        bcs     need_animation      ; animation needed, save more and continue

        ; No animation needed - restore minimal registers and exit
        pla
        tax
        pla
        rts

need_animation:
        ; Animation needed - save remaining registers and zero page variables
        sta     filename_len        ; save filename length
        tya
        pha

        ; Save zero page variables we'll use
        mwa     ptr1, saved_ptr1
        mwa     tmp9, saved_tmp9

        ; Get pointer to current filename from cache
        ; mfp_filename_cache[mf_selected * 2] -> ptr1
        lda     mf_selected
        asl                         ; multiply by 2 for pointer array
        tay
        mywa    {mfp_filename_cache, y}, ptr1

        ; Calculate starting position in filename (modify ptr1 directly)
        lda     anim_index
        clc
        adc     ptr1
        sta     ptr1
        bcc     :+
        inc     ptr1+1
:
        ; Display the filename starting from animation offset
        put_s   #$01, mf_selected, ptr1, mf_y_offset

        ; Update animation index
        lda     anim_direction
        beq     move_right

move_left:
        ; Moving left (decreasing index)
        lda     anim_index
        bne     continue_left       ; Not at left boundary yet

        ; At left boundary - pause then reverse to right
        lda     #0                  ; new direction = right
        beq     handle_boundary_pause

continue_left:
        dec     anim_index
        bpl     done                ; always positive

move_right:
        ; Moving right (increasing index)
        ; Check if we can advance without going past the end
        ; Last valid position: filename_len - (SCR_WID_NB-2)
        lda     filename_len
        sec
        sbc     #SCR_WID_NB-2       ; filename_len - display_width (space + border on right)
        cmp     anim_index
        bne     continue_right      ; Not at right boundary yet

        ; At right boundary - pause then reverse to left  
        lda     #1                  ; new direction = left
        bne     handle_boundary_pause

continue_right:
        inc     anim_index
        bne     done                ; will always branch

; Handle pause at boundary - A contains new direction (0=right, 1=left)
; Returns: C=0 if still pausing, C=1 if pause complete
handle_boundary_pause:
        sta     temp_direction      ; Save new direction
        inc     pause_counter
        lda     pause_counter
        cmp     #4
        bcc     done                ; still pausing

        ; fall through to pause completed
pause_complete:
        lda     temp_direction
        sta     anim_direction      ; Set new direction
        mva     #0, pause_counter   ; Reset pause counter

done:
        ; Restore zero page variables
        mwa     saved_ptr1, ptr1
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
        mva     #0, pause_counter
        rts

.segment "BANK"
anim_index:     .res 1      ; Current starting position in filename
anim_direction: .res 1      ; 0=moving right, 1=moving left  
pause_counter:  .res 1      ; Pause cycles at boundaries before reversing
temp_direction: .res 1      ; Temporary storage for new direction during pause
filename_len:   .res 1      ; Length of current filename

; Saved zero page variables for DLI context
saved_ptr1:     .res 2
saved_tmp9:     .res 2