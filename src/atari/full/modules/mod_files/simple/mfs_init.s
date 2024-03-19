        .export     mfs_init

        .import     _fuji_close_directory
        .import     _mfs_get_y_offset
        .import     fn_dir_path
        .import     mf_dir_pos
        .import     mfs_kbh_running
        .import     mf_selected
        .import     mfs_y_offset
        .import     return0
        .import     return1

        .import     _fuji_error
        .import     _fuji_mount_host_slot
        .import     fuji_hostslots
        .import     mh_host_selected
        .import     pusha

        .include    "zp.inc"
        .include    "macros.inc"

.proc mfs_init
        jsr     _fuji_close_directory

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
        jsr     _fuji_mount_host_slot
        ;; TODO: in 2.2.2 of fujinet-lib, value already returned, so can use it, BUT needs inverting in the callers of this function
        jmp     _fuji_error

.endproc