        .export     _scr_highlight_line
        .import     _bar_show, kb_current_line, mod_current
        .include  "zeropage.inc"
        .include  "fn_macros.inc"

; void __fastcall__ dev_highlight_line(uint8_t line)
.proc _scr_highlight_line
        ; read the highlight offset for current module
        ldx     mod_current
        lda     mod_highlight_offsets, x
        tax

        lda     kb_current_line
        jsr     _bar_show
        rts
.endproc

.rodata

; Gives offsets of the BAR to move it to correct line for the particular Module
; offsets for starting rows:
; row 0: $12
; row 1: $16
; row 2: $1a
;  i.e. $04 per row, starting at $12

; the offset for each module (see Mod enum), i.e. host, device, ...
; with host and device having first row of information at y = 2 (3rd row) down screen
mod_highlight_offsets:
        .byte   $1a, $1a, $12, $12, $12, $22, $12, $12
