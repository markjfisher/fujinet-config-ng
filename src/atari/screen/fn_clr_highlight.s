        .export     _fn_clr_highlight

        .import     _bar_clear

; void fn_clr_highlight()
;
; Clear the highlight from the screen. doesn't have to affect the line itself. device specific
.proc _fn_clr_highlight
        jmp     _bar_clear
.endproc