        .export _fn_io_dosiov

        .import fn_io_copy_dcb
        .include "atari.inc"

; void fn_io_dosiov()
;
; This one is the implementation for the device that initiates the actual SIOV
.proc _fn_io_dosiov
        jmp     SIOV
.endproc