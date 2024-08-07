        .export     _scr_highlight_line
        .export     mod_highlight_offsets

        .import     _bar_show
        .import     _set_highlight_colour
        .import     kb_current_line
        .import     mod_current

        .include    "zp.inc"
        .include    "macros.inc"

; void _scr_highlight_line()
.proc _scr_highlight_line
        jsr     _set_highlight_colour

        ; read the highlight offset for current module
        ldx     mod_current
        lda     mod_highlight_offsets, x
        ldy     kb_current_line
        jmp     _bar_show
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


;; must be in the same order as Mod enum:
; hosts
; devices
; wifi
; info
; files
; init
; exit


mod_highlight_offsets:
        .byte   $1a             ; hosts
        .byte   $1a             ; devices
        .byte   $36             ; wifi (only when choosing network)
        .byte   $2e             ; info
        .byte   $22             ; files
        .byte   $12             ; init (no highlight)
        .byte   $12             ; boot (no highlight)
