        .export     _mx_error_booting

        .import     _show_error
        .import     pusha

        .include    "macros.inc"

.proc _mx_error_booting
        pusha   #19
        pusha   #2
        setax   #mx_boot_error_msg
        jmp     _show_error
.endproc

.rodata
mx_boot_error_msg:
        .byte "Failed to boot with", 0
        .byte "  chosen options.", 0
