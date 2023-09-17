        .export     mfs_ask_new_disk
        .export     mfs_ask_cst_disk

        .import     _clr_help
        .import     _free
        .import     _malloc
        .import     _scr_clr_highlight
        .import     _show_select
        .import     debug
        .import     fn_io_buffer
        .import     mfs_ask_new_disk_cst_info
        .import     mfs_ask_new_disk_std_info
        .import     mfs_ask_new_disk_name_cst
        .import     mfs_ask_new_disk_name_std
        .import     mfs_ask_new_disk_pu_msg
        .import     mfs_ask_new_disk_sectors_cst
        .import     mfs_size_cst
        .import     mfs_size_std
        .import     pushax
        .import     return0

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fc_mods.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "popup.inc"

mfs_ask_new_disk:
        jsr     nd_common               ; allocates "name" field memory in ptr9/10

        ; show the select
        pushax  #mfs_ask_new_disk_std_info
        pushax  #std_help
        setax   #mfs_ask_new_disk_pu_msg
        jsr     _show_select

        ; deal with return from select (type PopupItemReturn)
        cmp     #PopupItemReturn::escape
        beq     end_ask

        ; prepend the full path to name
        ; save the disk

end_ask:
        setax   tmp9
        jsr     _free
        jmp     return0

mfs_ask_cst_disk:
        jsr     debug
        jsr     nd_common
        jsr     alloc_sector_cnt

        ; show the select
        pushax  #mfs_ask_new_disk_cst_info
        pushax  #cst_help
        setax   #mfs_ask_new_disk_pu_msg
        jsr     _show_select

        ; deal with return from select (type PopupItemReturn)
        cmp     #PopupItemReturn::escape
        beq     end_ask

        ; save the disk

        setax   tmp7
        jsr     _free
        jmp     end_ask

nd_common:
        jsr     _scr_clr_highlight

        ; THIS IS A BIT LAZY - USING FACT THE RODATA IS NOT ACTUALLY RO
        ; TODO: Copy the popup structure into RAM and use that instead of just adjusting the ::string value fields here.
        ; WHEN I DID THIS IT WAS SUNDAY NIGHT 8PM AND I COULDN'T BE ARSED.

        ; allocate memory for the edit string, and put the location in the name value
        ; we need ~26 bytes (read from appropriate value in popup structure)
        lda     mfs_ask_new_disk_name_std + POPUP_LEN_IDX
        sta     tmp8            ; save size
        jsr     _malloc
        axinto  tmp9

        ; save location in the popups - being lazy and saving it in both, cheaper then deciding which to save it in
        sta     mfs_ask_new_disk_name_std + POPUP_VAL_IDX
        stx     mfs_ask_new_disk_name_std + POPUP_VAL_IDX+1
        sta     mfs_ask_new_disk_name_cst + POPUP_VAL_IDX
        stx     mfs_ask_new_disk_name_cst + POPUP_VAL_IDX+1

        ; zero the memory
        lda     #$00
        ldy     #$00
:       sta     (tmp9), y
        iny
        cpy     tmp8
        bne     :-

        rts

alloc_sector_cnt:
        lda     mfs_ask_new_disk_sectors_cst + POPUP_LEN_IDX
        sta     tmp6            ; save size
        jsr     _malloc
        axinto  tmp7
        sta     mfs_ask_new_disk_sectors_cst + POPUP_VAL_IDX
        stx     mfs_ask_new_disk_sectors_cst + POPUP_VAL_IDX+1

        ; zero the memory
        lda     #$00
        ldy     #$00
:       sta     (tmp7), y
        iny
        cpy     tmp6
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
