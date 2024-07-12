        .export         _mi_edit_preferences

        .import         _cng_prefs
        .import         _kb_get_c_ucase
        .import         _put_s
        .import         _write_prefs
        .import         get_scrloc
        .import         hexb
        .import         mi_selected
        .import         pusha
        .import         temp_num

        .import         debug
        .import         _wait_scan1

        .include        "cng_prefs.inc"
        .include        "fn_data.inc"
        .include        "macros.inc"
        .include        "modules.inc"
        .include        "zp.inc"

.proc _mi_edit_preferences
        jsr     debug
        ; keep a copy of the real value so we can revert if user presses ESC
        jsr     copy_pref_to_temp

        ; find number of chars to display for current selection, store in tmp1
        lda     mi_prefs_char_count-1, x
        sta     tmp1            ; keep track of the chars count

        mva     #$00, tmp2      ; invert the values
        jsr     display_pref

        ; TODO: change the HELP to "up/down edit, return accept, esc exit"

        ; now, start a mini keyboard routine that checks for 4 keys, and manipulates the current value
        ; we can use _cng_prefs + mi_selected as the value we are editing, as the screen has same order as the structure.

; --------------------------------------------------------------------
; START PROCESSING KEYBOARD
; --------------------------------------------------------------------

; tmp1 is used to hold the chars count for pref being edited
; tmp2 is used to flag the print routine to invert the text (0), or not (1+)

start_kb_get:
        jsr     _kb_get_c_ucase
        cmp     #$00
        beq     start_kb_get

; --------------------------------------------------------------------
; DOWN - decrease the value of highlighted field
; --------------------------------------------------------------------
        cmp     #FNK_DOWN
        beq     is_down
        cmp     #FNK_DOWN2
        bne     not_down

is_down:
        ; if this is colour/shade, we wrap 0 to F, otherwise wrap to FF
        ; tmp1 is 0 for first case, 1 otherwise
        ldx     pref_copy
        dex                     ; reduce by 1
        lda     tmp1
        bne     :+              ; don't need to worry about full byte wrap
        cpx     #$ff
        bne     :+
        ldx     #$0f            ; we wrapped to $ff, but should be $0f

:
        jmp     do_update
not_down:

; --------------------------------------------------------------------
; UP - increase the value of highlighted field
; --------------------------------------------------------------------
        cmp     #FNK_UP
        beq     is_up
        cmp     #FNK_UP2
        bne     not_up

is_up:
        ; if this is colour/shade, we wrap 0 to F, otherwise wrap to FF
        ; tmp1 is 0 for first case, 1 otherwise
        ldx     pref_copy
        inx                     ; reduce by 1
        lda     tmp1
        bne     :+              ; don't need to worry about full byte wrap
        cpx     #$10
        bne     :+
        ldx     #$00            ; we wrapped to $10, but should be $00

:
        jmp     do_update


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
        mva     #$01, tmp2              ; don't invert
        jsr     display_pref
        jsr     enact_pref_change       ; reset colours to previous values
        rts
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

        rts

not_enter:

        ; reloop until we accept or exit
        jmp     start_kb_get


copy_pref_to_temp:
        ldx     mi_selected
        inx
        lda     _cng_prefs, x
        sta     pref_copy
        rts

.endproc


; displays the current value of the preference value in pref_copy
; INPUTS:  tmp2, if 0 will invert the text (used during editing), otherwise in normal text (e.g. resetting value)
.proc display_pref
        lda     pref_copy
        ; convert A to hex in temp_num
        jsr     pusha
        setax   #temp_num
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
        lda     tmp1            ; if 0 we skip a byte by moving tmp9 on by 1
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

.proc update_bar_conn
        rts
.endproc

.proc update_bar_disconn
        rts
.endproc

.proc update_bar_copy
        rts
.endproc



.rodata

; the lengths of each option shown - 1
mi_prefs_char_count:
                .byte 0, 0, 0, 1, 1, 1

update_table:
                .addr (update_colour - 1)
                .addr (update_brightness - 1)
                .addr (update_shade - 1)
                .addr (update_bar_conn - 1)
                .addr (update_bar_disconn - 1)
                .addr (update_bar_copy - 1)

.bss
pref_copy:      .res 1
