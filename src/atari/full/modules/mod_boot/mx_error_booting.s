        .export     _mx_error_booting

        .import     _show_error
        .import     pusha

        .include    "fc_macros.inc"

.proc _mx_error_booting
        pusha   #19
        pusha   #2
        setax   #mx_boot_error_msg
        jmp     _show_error
.endproc

.segment "SCR_DATA"
mx_boot_error_msg:
        .byte "Failed to boot with", 0
        .byte "  chosen options.", 0
