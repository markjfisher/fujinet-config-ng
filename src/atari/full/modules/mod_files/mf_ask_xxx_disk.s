        .export     mf_ask_new_disk
        .export     mfs_ask_cst_disk

        .import     _clr_help
        .import     _create_new_disk
        .import     _fc_strlcpy
        .import     _fc_strlen
        .import     _free
        .import     _malloc
        .import     _scr_clr_highlight
        .import     _show_select
        .import     copy_path_to_buffer
        .import     debug
        .import     fn_io_buffer
        .import     md_device_selected
        .import     mf_ask_new_disk_cst_info
        .import     mf_ask_new_disk_name_cst
        .import     mf_ask_new_disk_name_std
        .import     mf_ask_new_disk_pu_msg
        .import     mf_ask_new_disk_sectors_cst
        .import     mf_ask_new_disk_std_info
        .import     mf_ask_new_disk_std_sizes
        .import     mf_error_too_long
        .import     mh_host_selected
        .import     pusha
        .import     pushax
        .import     return0
        .import     return1

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fc_mods.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "popup.inc"

; tmp1,tmp2,tmp8,tmp9,tmp10
; ptr1,ptr2
mf_ask_new_disk:
        jsr     nd_common

        ; show the select
        pushax  #mf_ask_new_disk_std_info
        pushax  #std_help
        setax   #mf_ask_new_disk_pu_msg
        jsr     _show_select

        ; deal with return from select (type PopupItemReturn)
        cmp     #PopupItemReturn::escape
        beq     end_ask

        ; get the device slot to use


        jsr     join_path_and_filename


        ; fn_io_buffer now holds whole dirpath and filename of new disk

        ; -------------------------------------------------------------------------
        ; start of params for save
        ; set host_slot
        pusha   mh_host_selected

        ; set device_slot
        pusha   md_device_selected

        ; copy the disk size value location into ptr1, we need to double it to become a DiskSize value
        mwa     {mf_ask_new_disk_std_sizes + POPUP_VAL_IDX}, ptr1
        ldy     #$00
        lda     (ptr1), y
        asl     a               ; e.g. size130 is index 1 in the list, so double it to get the DiskSize of 2
        jsr     pusha

        pushax  #$00            ; not custom (sectors number)
        jsr     pushax          ; not custom (sectors size)
        setax   #fn_io_buffer   ; path to disk to create
        jsr     _create_new_disk

        ; TODO: error?

end_ask:
        setax   mf_ask_new_disk_name_std + POPUP_VAL_IDX
        jsr     _free
        jmp     return0

mfs_ask_cst_disk:
        jsr     nd_common
        jsr     alloc_sector_cnt

        ; show the select
        pushax  #mf_ask_new_disk_cst_info
        pushax  #cst_help
        setax   #mf_ask_new_disk_pu_msg
        jsr     _show_select

        ; deal with return from select (type PopupItemReturn)
        cmp     #PopupItemReturn::escape
        beq     end_ask

        ; save the disk

        setax   mf_ask_new_disk_sectors_cst + POPUP_VAL_IDX
        jsr     _free
        jmp     end_ask

nd_common:
        jsr     _scr_clr_highlight

        ; THIS IS A BIT LAZY - USING FACT THE RODATA IS NOT ACTUALLY RO
        ; TODO: Copy the popup structure into RAM and use that instead of just adjusting the ::string value fields here.
        ; WHEN I DID THIS IT WAS SUNDAY NIGHT 8PM AND I COULDN'T BE ARSED.

        ; allocate memory for the edit string, and put the location in the name value
        ; we need ~26 bytes (read from appropriate value in popup structure)
        lda     mf_ask_new_disk_name_std + POPUP_LEN_IDX
        sta     tmp8            ; save size
        ldx     #$00
        jsr     _malloc
        axinto  tmp9

        ; save location in the popups - being lazy and saving it in both, cheaper then deciding which to save it in
        sta     mf_ask_new_disk_name_std + POPUP_VAL_IDX
        stx     mf_ask_new_disk_name_std + POPUP_VAL_IDX+1
        sta     mf_ask_new_disk_name_cst + POPUP_VAL_IDX
        stx     mf_ask_new_disk_name_cst + POPUP_VAL_IDX+1

        ; zero the memory
        lda     #$00
        ldy     #$00
:       sta     (tmp9), y
        iny
        cpy     tmp8
        bne     :-

        rts

alloc_sector_cnt:
        lda     mf_ask_new_disk_sectors_cst + POPUP_LEN_IDX
        sta     tmp8            ; save size
        ldx     #$00
        jsr     _malloc
        axinto  tmp9
        sta     mf_ask_new_disk_sectors_cst + POPUP_VAL_IDX
        stx     mf_ask_new_disk_sectors_cst + POPUP_VAL_IDX+1

        ; zero the memory
        lda     #$00
        ldy     #$00
:       sta     (tmp9), y
        iny
        cpy     tmp8
        bne     :-

        rts

std_help:
        jsr     _clr_help
;        put_help #0, #mfss_h1
        rts

cst_help:
        jsr     _clr_help
;        put_help #0, #mfss_h1
        rts

join_path_and_filename:
        ; prepend the full path to name. couldn't get here with long path, but need to check adding on the file name doesn't go over limit
        jsr     copy_path_to_buffer
        setax   #fn_io_buffer
        jsr     _fc_strlen
        sta     tmp1

        ; check if the filename plus path are over limit
        setax   mf_ask_new_disk_name_std + POPUP_VAL_IDX
        axinto  ptr1
        
        ; TODO: This is a copy of the code in combine_path_with_selection
        jsr     _fc_strlen
        sta     tmp2            ; capture the length for the append later
        clc
        adc     tmp1
        bcs     too_long         ; over $100, must be too long, anything else is ok

        ; append the filename to fn_io_buffer
        mwa     #fn_io_buffer, ptr2
        adw1    ptr2, tmp1
        inc     tmp2            ; allow for null in strlcpy
        pushax  ptr2            ; dst
        pushax  ptr1            ; src
        lda     tmp2
        jmp     _fc_strlcpy     ; append
        ; implicit rts

too_long:
        jsr     mf_error_too_long
        jmp     return1
