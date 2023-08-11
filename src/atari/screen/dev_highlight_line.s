        .export     _dev_highlight_line
        .import     _bar_show, current_line, mod_current, mod_highlight_offsets
        .include  "zeropage.inc"
        .include  "fn_macros.inc"

; void __fastcall__ dev_highlight_line(uint8 line)
.proc _dev_highlight_line
        ; read the highlight offset for current module
        ldx     mod_current
        lda     mod_highlight_offsets, x
        tax

        lda     current_line
        jsr     _bar_show
        rts
.endproc