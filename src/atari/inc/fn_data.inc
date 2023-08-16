; ATARI SPECIFIC VALUES
;
; This file must be replicated for each device

; stop double loading
.ifndef ATESC
    .include    "atari.inc"
.endif

; The location where IO_DCB exists on Atari.
; This structure is used to set the location of parameters that eventually get sent to FN device.
; I assume all devices have similar.
.struct IO_DCB
    .org $0300
    ddevic  .byte
    dunit   .byte
    dcomnd  .byte
    dstats  .byte
    dbuflo  .byte
    dbufhi  .byte
    dtimlo  .byte
    dunuse  .byte
    dbytlo  .byte
    dbythi  .byte
    daux1   .byte
    daux2   .byte
.endstruct

; Atari specific values for Screen Display bits
; show_list constants for screen coordinate starting points etc.
SL_X        := 2    ; the top right corner X posisition to start printing the list
SL_Y        := 2    ; the top left corner Y position to start printing the list
SL_DX       := 3    ; The X value to add to the index position before printing the string
SL_COUNT    := 8    ; how many entries are in a Screen List


; Directory ASCII Character Code
DIR_CHAR    := $58  ; 'X' until I do the fonts
DIR_PG_CNT  := $10  ; Number of entries to display on a page in the file listing
DIR_MAX_LEN := 35   ; old config was 36, but we don't quite have space on screen for 36 with borders.

; KEYBOARD codes
; defines for fn_edit to use for various key codes
; to allow fn_edit to be device agnostic
; For other platforms that don't support any of these keys, use 0 for their value so fn_edit skips it.

FNK_ESC     = ATESC         ; Escape
FNK_ENTER   = ATEOL         ; Return/Enter
FNK_BS      = ATRUB         ; Backspace
FNK_DEL     = ATDEL         ; Delete
FNK_INS     = ATINS         ; Insert
FNK_LEFT    = ATLRW         ; Left Arrow
FNK_LEFT2   = $2B           ; Left Arrow   Alt "+"
FNK_RIGHT   = ATRRW         ; Right Arrow
FNK_RIGHT2  = $2A           ; Right Arrow  Alt "*" 
FNK_UP      = ATURW         ; Up Arrow
FNK_UP2     = $2D           ; Up Arrow     Alt "-"
FNK_DOWN    = ATDRW         ; Down Arrow
FNK_DOWN2   = $3D           ; Down Arrow   Alt "="
FNK_ASCIIL  = $20           ; Lowest ASCII code inclusive considered normal key press
FNK_ASCIIH  = $7D           ; Highest ASCII code inclusive considered normal key press
FNK_HOME    = $01           ; ctrl-a, start of line char
FNK_END     = $05           ; ctrl-e, end of line char
FNK_KILL    = $0B           ; ctrl-k, kill to end of line
