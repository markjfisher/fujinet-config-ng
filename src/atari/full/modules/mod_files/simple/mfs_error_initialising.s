        .export     mfs_error_initialising

        .import     _show_error
        .import     pusha

        .include    "macros.inc"

.proc mfs_error_initialising
        pusha   #26
        pusha   #1
        setax   #mfs_init_err_msg
        jmp     _show_error
.endproc

.segment "SCR_DATA"
mfs_init_err_msg:
        .byte "  Error initialising!", 0
