        .export     _dev_highlight_line
        .import     _bar_show, current_line

; void __fastcall__ dev_highlight_line(uint8 line, uint8 offset)
; A holds current line, X holds  highlight offset
.proc _dev_highlight_line
        lda     current_line
        jsr     _bar_show
        rts
.endproc