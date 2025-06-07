        .export     mf_init

        .import     _fuji_close_directory
        .import     _mfs_get_y_offset
        .import     fn_dir_path
        .import     kb_cb_function
        .import     mf_dir_pos
        .import     mf_kb_cb
        .import     mf_kbh_running
        .import     mf_selected
        .import     mf_y_offset
        .import     return0
        .import     return1

        .import     _fuji_error
        .import     _fuji_mount_host_slot
        .import     fuji_hostslots
        .import     mh_host_selected
        .import     pusha

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"

.proc mf_init
        jsr     _fuji_close_directory

        mwa     #$00, mf_dir_pos
        sta           mf_selected
        sta           mf_kbh_running

        ; set initial dir path to '/'. make most of A=0 to set the 2nd byte first
        ldx     #$01
        sta     fn_dir_path, x
        dex
        mva     #'/', {fn_dir_path, x}

        lda     #MF_YOFF
        sta     mf_y_offset

        ; -----------------------------------------------------
        ; mount the host.
        lda     mh_host_selected
        jmp     _fuji_mount_host_slot

.endproc