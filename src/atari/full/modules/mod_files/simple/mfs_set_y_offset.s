        .export     _mfs_get_y_offset

        .include    "fn_data.inc"

.proc _mfs_get_y_offset
        lda     #MF_YOFF
        rts
.endproc