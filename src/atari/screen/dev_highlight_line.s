        .export     _dev_highlight_line
        .import     _bar_show, current_line, mod_current
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

.rodata

; Gives offsets of the BAR to move it to correct line for the particular Module
; offsets for starting rows:
; row 0: $18
; row 1: $1c
; row 2: $20
;  i.e. $04 per row, starting at $18

; the offset for each module (see Mod enum), i.e. host, device, ...
; with host and device having first row of information at y = 2 (3rd row) down screen
mod_highlight_offsets:
        .byte   $20, $20, $18, $18, $18, $18, $18, $18
