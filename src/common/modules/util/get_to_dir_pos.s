        .export     get_to_dir_pos

        .import     _fn_io_open_directory
        .import     _fn_io_set_directory_position
        .import     copy_path_filter_to_buffer
        .import     fn_io_buffer
        .import     mf_dir_pos
        .import     mf_selected
        .import     mh_host_selected
        .import     pusha

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"

.proc get_to_dir_pos
        ; open dir for current path, grab the full name of this selected path, and append it to current path string.
        ; always need the filter that was used, as we are doing selections, which differ if a filter is set
        jsr     copy_path_filter_to_buffer
        pusha   mh_host_selected
        setax   #fn_io_buffer
        jsr     _fn_io_open_directory

        ; set the directory position to top + highlighted
        mwa     mf_dir_pos, tmp9
        adw1    tmp9, mf_selected

        ; setax   tmp9  ; a is already tmp9
        ldx     tmp9+1
        jmp     _fn_io_set_directory_position
        ; implicit rts
.endproc