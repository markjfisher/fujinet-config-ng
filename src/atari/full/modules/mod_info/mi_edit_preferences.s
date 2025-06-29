        .export         _mi_edit_preferences

        .import         _bar_setcolor
        .import         _clr_help
        .import         _cng_prefs
        .import         _just_rts
        .import         _kb_get_c_ucase
        .import         _pmg_space_left
        .import         _pmg_space_right
        .import         _put_help
        .import         _put_s
        .import         _scr_highlight_line
        .import         _write_prefs
        .import         get_scrloc
        .import         hexb
        .import         hex_out
        .import         joy_process
        .import         mi_selected
        .import         mi_set_pmg_widths
        .import         mx_h1
        .import         mx_pref_edit_help
        .import         pusha
        .import         temp_num

        .import         debug

        .include        "cng_prefs.inc"
        .include        "fn_data.inc"
        .include        "macros.inc"
        .include        "modules.inc"
        .include        "zp.inc"

.segment "CODE2"

.proc _mi_edit_preferences
        ; keep a copy of the real value so we can revert if user presses ESC
        jsr     copy_pref_to_temp

        mva     #$00, char_count
        ; Get max value for this preference, which also determines display format
        ; x is currently mi_selected + 1, so reduce address by 1 to compensate
        lda     mi_prefs_max_values-1, x
        sta     max_value       ; store max value for bounds checking
        ; If max value < $10, it's a single digit display
        cmp     #$10
        bcc     :+
        inc     char_count

:       mva     #$00, tmp2      ; invert the values
        jsr     display_pref
        jsr     edit_start

        put_help   #0, #mx_pref_edit_help

        ; now, start a mini keyboard routine that checks for 4 keys, and manipulates the current value
        ; we can use _cng_prefs + mi_selected as the value we are editing, as the screen has same order as the structure.

; --------------------------------------------------------------------
; START PROCESSING KEYBOARD
; --------------------------------------------------------------------

; char_count is used to hold the chars count for pref being edited
; tmp2 is used to flag the print routine to invert the text (0), or not (1+)

start_kb_get:
        jsr     joy_process
        cmp     #$00
        bne     some_input
        jsr     _kb_get_c_ucase
        cmp     #$00
        beq     start_kb_get

some_input:

; --------------------------------------------------------------------
; DOWN - decrease the value of highlighted field
; --------------------------------------------------------------------
        cmp     #FNK_DOWN
        beq     is_down
        cmp     #FNK_DOWN2
        bne     not_down

is_down:
        ; Check if value would wrap below 0
        ldx     pref_copy

        ; Get max value for this preference
        ldy     mi_selected
        lda     mi_prefs_max_values,y
        sta     max_value

        ; Decrement and check for underflow
        txa
        sec
        sbc     #1             ; Try to decrement
        bcc     wrap_max       ; If carry clear, we underflowed
        tax                    ; Save decremented value
        jmp     do_update      ; Use new value

wrap_max:
        ldx     max_value      ; Wrap to max value
        bne     do_update

not_down:

; --------------------------------------------------------------------
; UP - increase the value of highlighted field
; --------------------------------------------------------------------
        cmp     #FNK_UP
        beq     is_up
        cmp     #FNK_UP2
        bne     not_up

is_up:
        ; Check if value would exceed max
        ldx     pref_copy

        ; Get max value for this preference
        ldy     mi_selected
        lda     mi_prefs_max_values,y
        sta     max_value

        ; Increment and check for overflow
        txa
        clc
        adc     #1             ; Try to increment
        bcs     wrap_zero      ; If carry set, we overflowed
        tax                    ; Save incremented value
        cpx     max_value      ; Compare against max
        bcc     do_update
        beq     do_update

wrap_zero:
        ldx     #$00           ; Wrap to 0
        ; fall through

; common code to the UP/DOWN options
do_update:
        ; store and print the new value in X
        stx     pref_copy
        jsr     display_pref
        jsr     enact_pref_change
        jmp     start_kb_get

not_up:
; --------------------------------------------------------------------
; ESC - leave processing restoring current value
; --------------------------------------------------------------------
        cmp     #FNK_ESC
        bne     not_esc

        ; restore the value on screen, as the edit was cancelled
        jsr     copy_pref_to_temp
        sta     bar_colour
        mva     #$01, tmp2              ; don't invert
        jsr     display_pref
        jsr     enact_pref_change       ; reset colours to previous values
        jsr     mi_set_pmg_widths       ; set the widths back to normal
        jsr     reset_help
        lda     _cng_prefs + CNG_PREFS_DATA::bar_conn
        sta     bar_colour
        jmp     change_bar_colour

not_esc:
; --------------------------------------------------------------------
; ENTER - accept changes and write to prefs
; --------------------------------------------------------------------
        cmp     #FNK_ENTER
        bne     not_enter

        ; print the new value to screen uninverted
        mva     #$01, tmp2              ; don't invert
        jsr     display_pref
        ; store it in our actual prefs location
        ldx     mi_selected             ; index of preference to save
        inx                             ; skip version byte!
        lda     pref_copy               ; new value
        sta     _cng_prefs, x           ; store it
        jsr     _write_prefs            ; save them
        jsr     mi_set_pmg_widths       ; set the widths back to normal

        jsr     reset_help
        lda     _cng_prefs + CNG_PREFS_DATA::bar_conn
        sta     bar_colour
        jmp     change_bar_colour

not_enter:
; --------------------------------------------------------------------
; RELOOP
; --------------------------------------------------------------------
        ; reloop until we accept or exit
        jmp     start_kb_get


copy_pref_to_temp:
        ldx     mi_selected
        inx
        lda     _cng_prefs, x
        sta     pref_copy
        rts

reset_help:
        jsr     _clr_help
        pusha   #0
        setax   #mx_h1
        jmp     _put_help

.endproc

; displays the current value of the preference value in pref_copy
; INPUTS:  tmp2, if 0 will invert the text (used during editing), otherwise in normal text (e.g. resetting value)
.proc display_pref
        mwa     #temp_num, {hex_out+1}
        lda     pref_copy
        jsr     hexb

        ; if tmp2 is 0, invert the text, otherwise don't
        lda     tmp2
        bne     skip_invert
        ; invert first 2 bytes of the ascii string
        ldy     #1
:       lda     temp_num, y
        ora     #$80
        sta     temp_num, y
        dey
        bpl     :-

skip_invert:
        ; setup tmp9 to point to the correct part of the string for put_s
        mwa     #temp_num, tmp9
        lda     char_count      ; if 0 we skip a byte by moving tmp9 on by 1
        bne     :+
        adw1    tmp9, #1

:
        ; print and highlight the chars
        lda     mi_selected
        ; numbers start at x=20, y=mi_selected+7
        clc
        adc     #7              ; mi_selected + 7
        tay                     ; the y coordinate to use in getscrloc
        ldx     #20
        jmp     _put_s

.endproc

.proc edit_start
        ; for the selected preference, call its edit start function using dispatch table / rts jmp
        lda     mi_selected
        asl
        tax
        lda     on_edit+1, x
        pha
        lda     on_edit, x
        pha
        rts
.endproc

.proc enact_pref_change
        ; for the selected preference, call its update function using dispatch table / rts jmp
        lda     mi_selected
        asl
        tax
        lda     update_table+1, x
        pha
        lda     update_table, x
        pha
        rts
.endproc

.proc update_colour
        lda     pref_copy
        asl     a
        asl     a
        asl     a
        asl     a
        tax                     ; store the $X0 value from pref
        ora     _cng_prefs + CNG_PREFS_DATA::brightness
        sta     COLOR1

        txa                     ; get $X0 back into A
        ; add the darkness into the lower nybble to get $XY
        ora     _cng_prefs + CNG_PREFS_DATA::shade
        sta     COLOR2
        sta     COLOR4

        rts
.endproc

.proc update_brightness
        lda     _cng_prefs + CNG_PREFS_DATA::colour
        asl     a
        asl     a
        asl     a
        asl     a               ; becomes $X0
        ora     pref_copy
        sta     COLOR1
        rts
.endproc

.proc update_shade
        ; base colour value
        lda     _cng_prefs + CNG_PREFS_DATA::colour
        asl     a
        asl     a
        asl     a
        asl     a               ; becomes $X0
        ora     pref_copy       ; becomes $XY
        sta     COLOR2
        sta     COLOR4
        rts
.endproc

.proc update_bar
        ; update the current bar colour, same for all routines
        lda     pref_copy
        sta     bar_colour
        jsr     widen_bar
        jmp     change_bar_colour
.endproc


.proc on_edit_bar
        ; change the current bar to full width to make it easier to view for editing
        ldx     mi_selected
        inx                             ; skip version byte, then selected line is same as index into config structure
        lda     _cng_prefs, x
        sta     bar_colour
        jsr     widen_bar
        jmp     change_bar_colour
.endproc

.proc widen_bar
        ; max out the bar for easier viewing
        mva     #1, _pmg_space_left
        sta         _pmg_space_right
        rts
.endproc

.proc change_bar_colour
        jsr     _scr_highlight_line     ; this does a wait_scan, so bar won't be near drawing yet when we get to the line it's needed, so there should be no flash here
        lda     bar_colour
        jmp     _bar_setcolor
.endproc

.rodata

; Maximum values for each preference
mi_prefs_max_values:
        .byte $0F             ; colour (0-F)
        .byte $0F             ; brightness (0-F)
        .byte $0F             ; shade (0-F)
        .byte $FF             ; bar_conn (00-FF)
        .byte $FF             ; bar_disconn (00-FF)
        .byte $FF             ; bar_copy (00-FF)
        .byte $0F             ; anim_delay (0-F)
        .byte $02             ; date_format (0-2)
        .byte $01             ; use_banks (0-1)

update_table:
        .addr (update_colour - 1)
        .addr (update_brightness - 1)
        .addr (update_shade - 1)
        .addr (update_bar - 1)
        .addr (update_bar - 1)
        .addr (update_bar - 1)
        .addr (_just_rts - 1)
        .addr (_just_rts - 1)
        .addr (_just_rts - 1)

on_edit:
        .addr (_just_rts - 1)   ; colour, do nothing
        .addr (_just_rts - 1)   ; brightness, do nothing
        .addr (_just_rts - 1)   ; shade, do nothing
        .addr (on_edit_bar - 1)
        .addr (on_edit_bar - 1)
        .addr (on_edit_bar - 1)
        .addr (_just_rts - 1)   ; anim, do nothing
        .addr (_just_rts - 1)   ; date_format, do nothing
        .addr (_just_rts - 1)   ; use_banks, do nothing

.segment "BANK"
pref_copy:      .res 1
char_count:     .res 1
max_value:      .res 1
bar_colour:     .res 1