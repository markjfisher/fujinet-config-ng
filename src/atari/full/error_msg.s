        .export     _error_msg

        .import     _fn_clr_highlight
        .import     _fn_memclr
        .import     _fn_put_help
        .import     _fn_strlen
        .import     _fn_strncpy
        .import     _free
        .import     _malloc
        .import     _show_select
        .import     pusha
        .import     pushax

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "popup.inc"

; void error_msg(char *msg)
;
; simple 1 line popup error message, press esc to exit
; this turned from an example into a drunken mess on a saturday night.
.proc _error_msg
        setax   em_loc
        jsr     _fn_strlen              ; how long is the message?
        sta     tmp1
        clc
        adc     #$05+8                  ; 2 spaces either side, plus 2 0's for the blank lines, plus 1 for the nul of the string, e.g. "1" -> 2 spaces, 2 x blank lines + 1 nul.
        sta     tmp2

        ; TODO: need complete popup data, not just lines. we need finish bit at the end, so 8 more
        jsr     _malloc
        axinto  ptr1                    ; location of memory for putting our lines to show

        ; write 0s to the entire 13 bytes
        jsr     pushax
        lda     #13
        jsr     _fn_memclr

        ; we can now write the string in em_loc - TODO, ALL NEEDS DOING HERE
        adw1    ptr1, #$01              ; there's a 0 at start before message for the blank line
        pushax  ptr1                    ; dst
        pushax  em_loc                  ; src
        lda     tmp1                    ; len
        jsr     _fn_strncpy             ; slot the message into place

        ; we need to create a popup string item with location of our data to display.
        lda     #$00
        sta     em_lines+1
        sta     em_lines+2
        sta     em_lines+5
        sta     em_lines+6
        mva     #$03, em_lines
        mwa     ptr1, em_lines+3

        jsr     _fn_clr_highlight       ; preserves ptr1

        pusha   tmp2                    ; width of window
        pushax  em_mem                  ; location of the popup data
        pushax  #err_help               ; help callback
        setax   #err_msg                ; the title
        jsr     _show_select

        ; free mem
        setax   em_mem
        jmp     _free

err_help:
        put_help #1, #err_h1
        rts
.endproc

.bss
em_loc:         .res 2          ; message to display
em_mem:         .res 2          ; allocated memory
em_lines:       .res 7          ; the PopUp item for strings

.rodata
;err_pu_lines:   .byte PopupItemType::string,   3,  0, 0, <err_lines, >err_lines, 0, 0
err_pu_end:     .byte PopupItemType::finish,   0, 0, 0, 0, 0, 0, 0

.segment "SCREEN"
                INVERT_ATASCII
err_msg:        .byte "Error!"
                NORMAL_CHARMAP

err_lines:      .byte 0
                .byte "  Another line", 0
                .byte 0

err_h1:
                NORMAL_CHARMAP
                .byte $81, "ESC", $82
                INVERT_ATASCII
                .byte "Exit", 0