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

; Atari specific values for Screen Display bits

SCR_WIDTH   := 40           ; the global screen width value, including borders
SCR_WID_NB  := SCR_WIDTH-2  ; screen width without borders
SCR_HEIGHT  := 22           ; number of lines in total in screen area

SCR_BYTES_W := 40           ; the number of bytes in a line
SCR_BWX2    := 80           ; pre-calculate 2 widths so we don't have to keep doing it in code, used for clearing status/help lines which are 2 lines tall

; show_list constants for screen coordinate starting points etc.
SL_EDIT_X   := 5            ; x offset for list entry
SL_Y        := 2            ; the top left corner Y position to start printing the list

MF_YOFF     := 4            ; Mod Files Y Offset for shifting file list down screen

FNS_N2C     = $10           ; Screen code for '0'. Add this to 0 based index so it can be print
FNS_C_R     = $32           ; screen code for "R"
FNS_C_W     = $37           ; screen code for "W"

; DIR_PG_CNT  = 18            ; Number of entries to display on a page in the file listing
DIR_MAX_LEN = 36            ; old config was 36, but we don't quite have space on screen for 36 with borders.

MAX_NETS    = 10            ; networks to show when scanning for wifis
MAX_HOSTS   = 8             ; how many hosts can be displayed
MAX_DEVICES = 8             ; how many devices can be displayed

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
FNK_CUSTOM  = $43           ; "C" Custom Size New Disk (only on New Disk Popup)
FNK_COPY    = $43           ; "C" Copy Disk
FNK_EDIT    = $45           ; "E" Edit string field
FNK_FILTER  = $46           ; "F" Filter
FNK_LOBBY   = $4C           ; "L" Lobby
FNK_NEWDISK = $4E           ; "N" New Disk (Files)
FNK_EXITCOPY= $58           ; "X" eXit Copy mode
FNK_QUIT    = $51           ; "Q" Quit application

; CHARACTER SCREEN CODES FOR HIGHLIGHTING/POPUP BOX etc
FNC_TLW     = $4A           ; Top Left WIDE
FNC_TRW     = $4B           ; Top Right WIDE
FNC_BLW     = $4C           ; Bottom Left WIDE
FNC_BRW     = $4F           ; Bottom Right WIDE

FNC_TL      = $46           ; Top Left Corner Thin
FNC_TR      = $47           ; Top Right Corner Thin
FNC_BL      = $48           ; Bottom Left Corner Thin
FNC_BR      = $49           ; Bottom Right Corner Thin

; above + $80
FNC_TL_I    = $C6           ; Top Left Corner Thin INVERSE (makes WIDE outer)
FNC_TR_I    = $C7           ; Top Right Corner Thin INVERSE (makes WIDE outer)
FNC_BL_I    = $C8           ; Bottom Left Corner Thin INVERSE (makes WIDE outer)
FNC_BR_I    = $C9           ; Bottom Right Corner Thin INVERSE (makes WIDE outer)

FNC_DN_BLK  = $55           ; ctrl-U under normal, 4 rows blank, 4 rows filled
FNC_UP_BLK  = $D5           ; INV ctrl-U under normal, 4 rows filled, 4 rows blank
FNC_LT_BLK  = $59           ; ctrl-Y, 4 columns filled, 4 columns blank - NEW BORDER LEFT CHAR
FNC_RT_BLK  = $D9           ; INV ctrl-Y, 4 columns blank, 4 columns filled - NEW BORDER RIGHT CHAR

FNC_BL_SEP  = $57           ; Left border separator that connects border to bar line, looks like T rotated CCW 90 - this replaces the border char on left
FNC_BR_SEP  = $58           ; Right border separator that connects border to bar line, looks like T rotated CW 90 - this replaces the border char on right
FNC_MD_SEP  = $52           ; Middle border separator that connects BL and BR chars across page, standard "-" like char

FNC_BLANK   = $00           ; space
FNC_FULL    = $80           ; inv-space

FNC_DIR_C   = $40           ; directory character
FNC_L_END   = $41           ; Left extra character to widen the string slightly, used for Help text
FNC_R_END   = $42           ; Right extra character to widen the string slightly, used for Help text
FNC_M_END   = $44           ; Middle extra character to widen the string slightly, used for Help text - reduces overall space on Help text

FNC_L_HL    = $50           ; Pointer to selection L
FNC_LEND_ST = $54           ; Pointer to selection R

FNC_WIFI1   = $56           ; wifi 1 bar
FNC_WIFI2   = $4D           ; wifi 2 bar
FNC_WIFI3   = $4E           ; wifi 3 bar

FNC_STAR    = $0A           ; '*' char for passwords
