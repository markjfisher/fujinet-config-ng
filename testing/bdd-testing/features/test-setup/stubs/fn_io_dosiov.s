                .export   _fn_io_dosiov

                .include  "fn_data.inc"

; This is the implementation of the only device specific function required for fn_io.
; Everything else is board agnostic (other than an expectation of the DDEVIC structure for calling FN)
; and calls through here to reach SIO

.proc _fn_io_dosiov
        jmp     SIOV
.endproc