; defines for fn_edit to use for various key codes
; to allow fn_edit to be device agnostic

        .include    "atari.inc"


; For other platforms that don't support any of these keys, use 0 for their value so fn_edit skips it

FNK_ESC     = ATESC         ; Escape
FNK_ENTER   = ATEOL         ; Return/Enter
FNK_BS      = ATRUB         ; Backspace
FNK_DEL     = ATDEL         ; Delete
FNK_INS     = ATINS         ; Insert
FNK_LEFT    = ATLRW         ; Left Arrow
FNK_RIGHT   = ATRRW         ; Right Arrow
FNK_ASCIIL  = $20           ; Lowest ASCII code inclusive considered normal key press
FNK_ASCIIH  = $7D           ; Highest ASCII code inclusive considered normal key press
FNK_HOME    = $01           ; ctrl-a, start of line char
FNK_END     = $05           ; ctrl-e, end of line char
FNK_KILL    = $0B           ; ctrl-k, kill to end of line
