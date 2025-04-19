        .export     _mfs_get_y_offset

        .include    "fn_data.inc"

.segment "CODE2"

.proc _mfs_get_y_offset
        lda     #MF_YOFF
        rts
.endproc