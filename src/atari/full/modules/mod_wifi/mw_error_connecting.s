        .export     mw_error_connecting

        .import     _show_error
        .import     pusha

        .include    "macros.inc"

.proc mw_error_connecting
        pusha   #21
        pusha   #2
        setax   #mw_connect_error_msg
        jmp     _show_error
.endproc

.rodata
mw_connect_error_msg:
                .byte " Could not connect", 0
                .byte "    to network!", 0
