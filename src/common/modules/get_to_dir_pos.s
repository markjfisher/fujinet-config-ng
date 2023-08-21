        .export     get_to_dir_pos

        .import     host_selected
        .import     mf_selected
        .import     mf_dir_pos
        .import     _fn_io_open_directory
        .import     _fn_io_set_directory_position

        .include    "zeropage.inc"
        .include    "fn_macros.inc"

.proc get_to_dir_pos
        ; open dir for current path, grab the full name of this selected path, and append it to current path string.
        lda     host_selected
        jsr     _fn_io_open_directory

        ; set the directory position to top + highlighted
        lda     mf_selected
        sta     tmp1
        mva     #$00, tmp2
        adw     mf_dir_pos, tmp1, tmp3      ; pretend tmp1 is word value, and save result in tmp3/4

        setax   tmp3                        ; store this in A/X for call
        jmp     _fn_io_set_directory_position
.endproc