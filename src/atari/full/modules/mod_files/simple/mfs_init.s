        .export     mfs_init

        .import     _fn_io_close_directory
        .import     _mfs_get_y_offset
        .import     fn_dir_path
        .import     mf_dir_pos
        .import     mfs_kbh_running
        .import     mf_selected
        .import     mfs_y_offset
        .import     return0
        .import     return1

        .import     _fn_io_error
        .import     _fn_io_mount_host_slot
        .import     fn_io_hostslots
        .import     mh_host_selected
        .import     pusha

        .include    "zp.inc"
        .include    "macros.inc"

.proc mfs_init
        jsr     _fn_io_close_directory

        mwa     #$00, mf_dir_pos
        sta          mf_selected
        sta          mfs_kbh_running

        ; set initial dir path to '/'. make most of A=0 to set the 2nd byte first
        ldx     #$01
        sta     fn_dir_path, x
        dex
        mva     #'/', {fn_dir_path, x}

        jsr     _mfs_get_y_offset
        sta     mfs_y_offset

        ; -----------------------------------------------------
        ; mount the host.
        lda     mh_host_selected
        jsr     _fn_io_mount_host_slot
        jsr     _fn_io_error
        beq     :+

        ; return an error
        jmp     return1

        ; all good
:       jmp     return0

.endproc