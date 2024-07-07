        .export     mw_error_no_networks

        .import     _show_error
        .import     pusha

        .include    "macros.inc"

.proc mw_error_no_networks
        pusha   #17
        pusha   #1
        setax   #mw_no_networks_error_msg
        jmp     _show_error
.endproc

.rodata
mw_no_networks_error_msg:
        .byte " No networks", 0
