        .export     _scr_clr_highlight

        .import     _bar_clear

; void scr_clr_highlight()
;
; Clear the highlight from the screen. doesn't have to affect the line itself. device specific
.proc _scr_clr_highlight
        jmp     _bar_clear
.endproc