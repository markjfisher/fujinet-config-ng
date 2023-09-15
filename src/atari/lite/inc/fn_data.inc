; ATARI SPECIFIC VALUES
;
; This file must be replicated for each device

; stop double loading
.ifndef ATESC
    .include    "atari.inc"
.endif

; The location where IO_DCB exists on Atari.
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

SL_EDIT_X   := 5            ; x offset for list entry
SL_Y        := 2            ; the top left corner Y position to start printing the list
SL_COUNT    := 8            ; how many entries are in a Screen List
SCR_WID_NB   := 36           ; screen width without borders

FNS_N2C     = $10           ; Screen code for '0'. Add this to 0 based index so it can be print
FNS_C_R     = $32           ; screen code for "R"
FNS_C_W     = $37           ; screen code for "W"

DIR_PG_CNT  = 16            ; Number of entries to display on a page in the file listing
DIR_MAX_LEN = 36

; KEYBOARD codes
; defines for fn_edit to use for various key codes
; to allow fn_edit to be device agnostic
; For other platforms that don't support any of these keys, use 0 for their value so fn_edit skips it.

FNK_ESC     = ATESC         ; Escape
FNK_ENTER   = ATEOL         ; Return/Enter
FNK_TAB     = ATTAB         ; Tab
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
FNK_PARENT  = $3C           ; "<" used in files to go to parent dir
FNK_FILTER  = $46           ; "F" Filter
FNK_LOBBY   = $4C           ; "L" Lobby

FNC_DIR_C   = $40           ; directory character SCREEN CODE
FNC_L_END   = $41           ; Left extra character to widen the string slightly, used for Help text
FNC_R_END   = $42           ; Right extra character to widen the string slightly, used for Help text
FNC_M_END   = $44           ; Middle extra character to widen the string slightly, used for Help text - reduces overall space on Help text
