        .export     mf_new_disk
        .export     mf_cst_disk
        .export     nd_common

        .import     _clr_help
        .import     create_new_disk
        .import     cnd_args
        .import     _bzero
        .import     _fc_atoi
        .import     _fc_strlcpy
        .import     _fc_strlcpy_params
        .import     _fc_strlen
        .import     _fuji_error
        .import     _put_help
        .import     _scr_clr_highlight
        .import     show_select
        .import     ss_args
        .import     copy_path_to_buffer
        .import     debug
        .import     fuji_buffer
        .import     load_widget_x
        .import     mf_ask_buff
        .import     mf_sct_buff
        .import     mf_ask_new_disk_cst_info
        .import     mf_ask_new_disk_cust_sector_size_val
        .import     mf_ask_new_disk_name_cst
        .import     mf_ask_new_disk_name_std
        .import     mf_ask_new_disk_pu_msg
        .import     mf_ask_new_disk_sectors_cst
        .import     mf_ask_new_disk_std_info
        .import     mf_ask_new_disk_std_sizes
        .import     mf_error_too_long
        .import     mf_nd_err_saving
        .import     mf_nd_std_h1
        .import     mh_host_selected
        .import     pusha
        .import     pushax
        .import     return0
        .import     return1
        .import     save_device_choice
        .import     sdc_args
        .import     sds_pu_no_opt_devs
        .import     select_device_slot
        .import     ss_widget_idx
        .import     zero_mem_tmp9_tmp8

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "fn_data.inc"
        .include    "fn_disk.inc"
        .include    "fujinet-fuji.inc"
        .include    "popup.inc"
        .include    "args.inc"
        .include    "fc_strlcpy.inc"

; tmp1,tmp2,tmp8,tmp9,tmp10
; ptr1,ptr2

mf_new_disk:
        jsr     nd_common

        ; show the select
        mwa     #nd_std_kbh, ss_args+ShowSelectArgs::kb_cb
        mwa     #mf_ask_new_disk_std_info, ss_args+ShowSelectArgs::items
        mwa     #nd_help, ss_args+ShowSelectArgs::help_cb
        mwa     #mf_ask_new_disk_pu_msg, ss_args+ShowSelectArgs::message
        jsr     show_select

        ; return in X will be one of escape, complete, app_1
        cpx     #PopupItemReturn::escape
        beq     end_ask

        cpx     #PopupItemReturn::app_1
        beq     show_custom

        jsr     handle_device_slot
        bne     end_ask

        ; -------------------------------------------------------------------------
        ; start of params for save
        mva     mh_host_selected, cnd_args+CreateDiskArgs::host_slot
        mva     tmp3, cnd_args+CreateDiskArgs::device_slot

        ; copy the disk size value location into ptr1, we need to double it to become a DiskSize value
        mwa     {mf_ask_new_disk_std_sizes + POPUP_VAL_IDX}, ptr1
        ldy     #$00
        lda     (ptr1), y
        asl     a               ; e.g. size130 is index 1 in the list, so double it to get the DiskSize of 2
        sta     cnd_args+CreateDiskArgs::size_index

        lda     #$00
        sta     cnd_args+CreateDiskArgs::cust_num_sectors
        sta     cnd_args+CreateDiskArgs::cust_num_sectors+1
        sta     cnd_args+CreateDiskArgs::cust_size_sectors
        sta     cnd_args+CreateDiskArgs::cust_size_sectors+1
        mwa     #fuji_buffer, cnd_args+CreateDiskArgs::disk_path

        jsr     create_new_disk
        jsr     _fuji_error
        beq     end_ask

        jsr     mf_nd_err_saving

show_custom:
        ; swap to the custom disk dialogue
        ; jsr     end_ask
        jmp     mf_cst_disk

end_ask:
        jmp     return0

; ------------------------------------------------------------
; Normal Disk Keyboard Handler
;
; If they press "C", jump to CUSTOM dialog
; If they press "Enter" (Return), check the String fields, if empty, pretend we pressed E to edit instead and mark as unhandled for primary kbh to edit it
nd_std_kbh:
        ; 'a' contains the ascii keypress.
        cmp     #FNK_CUSTOM
        bne     @not_custom

        ldx     #PopupItemReturn::app_1
        rts
@not_custom:
        cmp     #FNK_ENTER
        bne     @not_enter

        ; is the Name field empty?
        mwa     {mf_ask_new_disk_name_std + POPUP_VAL_IDX}, ptr1
        ldy     #$00
        lda     (ptr1), y
        beq     @name_empty

        ; name is not empty, reset our keypress in A and return. X unchanged from default of not-handled
        lda     #FNK_ENTER
        rts

@name_empty:
        ; change focus to the NAME field, and simulate "E" for edit, set X to not-handled
        mva     #$00, ss_widget_idx
        jsr     load_widget_x
        lda     #FNK_EDIT
        ldx     #PopupItemReturn::not_handled
        rts

@not_enter:
        ; defaults to unhandled, a still contains the ascii keypress, so just return
        rts

; ------------------------------------------------------------
; CUSTOM Disk Keyboard Handler
;
; Similar to above, handles pressing Enter as though you're EDITing an empty string.
; This case checks both name and sectors before passing through enter as valid string, as you need both set

nd_cst_kbh:
        cmp     #FNK_NEWDISK
        bne     @not_new

        ldx     #PopupItemReturn::app_1
        rts
@not_new:
        cmp     #FNK_ENTER
        bne     @not_enter

        ; is the Name field empty?
        mwa     {mf_ask_new_disk_name_cst + POPUP_VAL_IDX}, ptr1
        ldy     #$00
        lda     (ptr1), y
        beq     @name_empty

        ; check the disk sectors string
        mwa     {mf_ask_new_disk_sectors_cst + POPUP_VAL_IDX}, ptr1
        lda     (ptr1), y
        beq     @sectors_empty

        lda     #FNK_ENTER
        rts

@name_empty:
        ; change focus to the NAME field, and simulate "E" for edit, set X to not-handled
        mva     #$00, ss_widget_idx
        jsr     load_widget_x
        ldx     #PopupItemReturn::not_handled
        lda     #FNK_EDIT
        rts

@sectors_empty:
        ; change focus to the SECTORS field, and simulate "E" for edit, set X to not-handled
        mva     #$02, ss_widget_idx
        jsr     load_widget_x
        ldx     #PopupItemReturn::not_handled
        lda     #FNK_EDIT
        rts

@not_enter:
        ; defaults to unhandled, a still contains the ascii keypress, so just return
        rts



mf_cst_disk:
        jsr     nd_common

        ; show the select
        mwa     #nd_cst_kbh, ss_args+ShowSelectArgs::kb_cb
        mwa     #mf_ask_new_disk_cst_info, ss_args+ShowSelectArgs::items
        mwa     #nd_help, ss_args+ShowSelectArgs::help_cb
        mwa     #mf_ask_new_disk_pu_msg, ss_args+ShowSelectArgs::message
        jsr     show_select

        ; deal with return from select (type PopupItemReturn)
        ; return will be one of escape, complete, app_1
        cpx     #PopupItemReturn::escape
        beq     end_ask2

        cpx     #PopupItemReturn::app_1
        beq     show_std

        jsr     handle_device_slot              ; sets tmp3 to device_slot
        bne     end_ask2

        ; -------------------------------------------------------------------------
        ; start of params for save
        ; set host_slot
        mva     mh_host_selected, cnd_args+CreateDiskArgs::host_slot
        mva     tmp3, cnd_args+CreateDiskArgs::device_slot
        mva     #DiskSize::sizeCustom, cnd_args+CreateDiskArgs::size_index

        ; convert the sectors number into word value, atoi!!
        ; we have a very limited string, 1-65535, do minimal calc from string to word
        setax   mf_ask_new_disk_sectors_cst + POPUP_VAL_IDX
        jsr     _fc_atoi
        ; can't have under 4 sectors (firmware bugs out if you do), so if it's below that, set it to 4
        cpx     #$00
        bne     over_4
        cmp     #$04
        bcs     over_4
        lda     #$04
over_4:
        axinto  cnd_args+CreateDiskArgs::cust_num_sectors

        ; sector size is 0=128, 1=256, 2=512
        ldy     mf_ask_new_disk_cust_sector_size_val
        bne     :+

        lda     #$80                    ; 128
        ldx     #$00
        beq     push_size               ; always

:       cpy     #$01
        bne     :+

        ldx     #$01                    ; 256
        lda     #$00
        beq     push_size

:       setax   #$200                   ; 512

push_size:
        axinto  cnd_args+CreateDiskArgs::cust_size_sectors
        mwa     #fuji_buffer, cnd_args+CreateDiskArgs::disk_path
        jsr     create_new_disk
        jsr     _fuji_error
        beq     end_ask2

        jsr     mf_nd_err_saving

end_ask2:
        jmp     return0

show_std:
        ; swap to the standard disk dialogue
        jmp     mf_new_disk

nd_common:
        jsr     _scr_clr_highlight

        pushax  #mf_ask_buff
        lda     mf_ask_new_disk_name_std + POPUP_LEN_IDX
        ldx     #$00
        jsr     _bzero

        pushax  #mf_sct_buff
        lda     mf_ask_new_disk_sectors_cst + POPUP_LEN_IDX
        ldx     #$00
        jmp     _bzero

nd_help:
        jsr     _clr_help
        put_help #0, #mf_nd_std_h1
        rts


join_path_and_filename:
        ; prepend the full path to name. couldn't get here with long path, but need to check adding on the file name doesn't go over limit
        jsr     copy_path_to_buffer
        setax   #fuji_buffer
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

        ; append the filename to fuji_buffer
        mwa     #fuji_buffer, ptr2
        adw1    ptr2, tmp1
        inc     tmp2            ; allow for null in strlcpy

        ; Setup fc_strlcpy params
        mwa     ptr2, _fc_strlcpy_params+fc_strlcpy_params::dst
        mwa     ptr1, _fc_strlcpy_params+fc_strlcpy_params::src
        mva     tmp2, _fc_strlcpy_params+fc_strlcpy_params::size
        jsr     _fc_strlcpy     ; append
        ; TODO: should we check if the copy worked?
        jmp     return0

too_long:
        jsr     mf_error_too_long
        jmp     return1


handle_device_slot:
        ; get the device slot to use
        lda     #$00                    ; don't show options
        jsr     select_device_slot
        cpx     #PopupItemReturn::escape
        beq     :+

        ldy     #$00
        mwa     {sds_pu_no_opt_devs + POPUP_VAL_IDX}, ptr1
        lda     (ptr1), y
        sta     tmp3                    ; store the device slot we want to use

        jsr     join_path_and_filename
        bne     :+

        ; fuji_buffer now holds whole dirpath and filename of new disk
        ; tmp3 holds the device slot to populate

        ; save the device slot choice

        mva     #$01, sdc_args+SaveDeviceChoiceArgs::mode
        mva     tmp3, sdc_args+SaveDeviceChoiceArgs::device_slot
        jsr     save_device_choice
        ; all ok
        jmp     return0

        ; there was an issue
:       jmp     return1
