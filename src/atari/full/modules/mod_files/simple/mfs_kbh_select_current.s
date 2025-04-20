        .export     combine_path_with_selection
        .export     mfs_kbh_select_current

        .import     _fc_strlcpy
        .import     _fc_strlen
        .import     _fc_strncpy
        .import     _scr_clr_highlight
        .import     fn_dir_path
        .import     fuji_buffer
        .import     mf_dir_or_file
        .import     mf_dir_pos
        .import     mf_error_too_long
        .import     mf_selected
        .import     pusha
        .import     pushax
        .import     read_full_dir_name
        .import     return0
        .import     return1
        .import     save_device_choice
        .import     sds_pu_device_val
        .import     sds_pu_mode_val
        .import     select_device_slot
        .import     sdc_args

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "popup.inc"
        .include    "args.inc"

; Handle Selection of the currently highlighted line
; tmp1,tmp2,tmp3
; ptr1,ptr2
.proc mfs_kbh_select_current
        ; read the dir/file indicator for current highlight for current page. don't rely on screen reading else can't port to versions that have no ability to grab screen memory
        ldx     mf_selected
        lda     mf_dir_or_file, x

        ; 0 is a file, 1 is a dir
        beq     is_file

is_dir:
        ; we're a directory, so go into it, and restart directory listing.
        lda     #$e0                    ; max size of dir
        jsr     combine_path_with_selection
        bne     too_long_error

        ; copy fuji_buffer to fn_dir_path
        pushax  #fn_dir_path
        pushax  #fuji_buffer
        lda     #$e0
        jsr     _fc_strncpy

        mva     #$00, mf_selected
        sta     mf_dir_pos
        ldx     #KBH::APP_1
        rts

is_file:
        lda     #$ff
        jsr     combine_path_with_selection
        bne     too_long_error

        ; get user's choice of which to device to put the host
        lda     #$01                            ; show options
        jsr     select_device_slot

        ; CHECK IF ESC pressed (return value from show_select is type PopupItemReturn, with value #PopupItemReturn::escape for esc)
        cpx     #PopupItemReturn::escape
        beq     :+

        ; use the mode/device_slot from select to save our choice        
        mva     sds_pu_mode_val, sdc_args+SaveDeviceChoiceArgs::mode
        mva     sds_pu_device_val, sdc_args+SaveDeviceChoiceArgs::device_slot
        jsr     save_device_choice

:       ldx     #KBH::APP_1
        rts

too_long_error:
        jsr     mf_error_too_long
        ldx     #KBH::APP_1
        rts
.endproc


; Appends the directory/filename onto path, but only if it fits in the maximum path size.
; So you may be able to see the dir/file, but you won't be able to use it if it makes whole path length too long.
; Returns 0 for ok, 1 for error (path too long).
.proc combine_path_with_selection
        sta     tmp3                 ; max length

        ; ---------------------------------------------
        ; path + file size checking
        ; ---------------------------------------------

        ; get the chosen dir into 255 byte temp buffer, and then check it will fit on the end of our current path, i.e. doesn't combined go over 254 (allowing for nul)
        jsr     read_full_dir_name      ; AX holds buffer location of dir name string
        axinto  ptr1
        jsr     _fc_strlen
        sta     tmp2                    ; length of new directory/file chosen

        setax   #fn_dir_path
        jsr     _fc_strlen             ; returns length of src (i.e. path)
        sta     tmp1

        ; when added to current path, will it fit? (max #$e0)
        clc
        adc     tmp2
        bcs     too_big                 ; already over $ff in length, so too big
        cmp     tmp3                    ; specified max size, for dirs it's $e0, for files $ff
        beq     :+
        bcs     too_big

        ; --------------------------------------------
        ; all good, append values
        ; --------------------------------------------

:       mwa     #fuji_buffer, ptr2
        adw1    ptr2, tmp1
        inc     tmp2                    ; allow for nul char in strlcpy. this should be done AFTER the size check!
        pushax  ptr2                    ; dst, where we will apend the entry to.
        pushax  ptr1                    ; src, which has a trailing slash conveniently if it's a dir
        lda     tmp2                    ; we know it will fit and it's this length
        jsr     _fc_strlcpy

        jmp     return0

        ; --------------------------------------------
        ; ERROR path + extra are too long, return 1
        ; --------------------------------------------
too_big:
        jmp     return1

.endproc
