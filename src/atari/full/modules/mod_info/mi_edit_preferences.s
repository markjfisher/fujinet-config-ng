        .export         _mi_edit_preferences

        .import         _cng_prefs
        .import         _kb_get_c_ucase
        .import         _put_s
        .import         get_scrloc
        .import         hexb
        .import         mi_selected
        .import         pusha
        .import         temp_num

        .import         debug
        .import         _wait_scan1

        .include        "fn_data.inc"
        .include        "macros.inc"
        .include        "modules.inc"
        .include        "zp.inc"

.proc _mi_edit_preferences
        jsr     debug
        ; keep a copy of the real value so we can revert if user presses ESC
        ldx     mi_selected
        inx
        lda     _cng_prefs, x
        sta     pref_copy

        ; find number of chars to display for current selection, store in tmp1
        lda     mi_prefs_char_count-1, x
        sta     tmp1            ; keep track of the chars count

        jsr     print_copy

        ; TODO: change the HELP to "up/down edit, return accept, esc exit"

        ; now, start a mini keyboard routine that checks for 4 keys, and manipulates the current value
        ; we can use _cng_prefs + mi_selected as the value we are editing, as the screen has same order as the structure.

start_kb_get:
        jsr     _kb_get_c_ucase
        cmp     #$00
        beq     start_kb_get

:       cmp     #FNK_UP
        beq     is_up
        cmp     #FNK_UP2
        bne     not_up

is_up:
        ; if this is colour/shade, we wrap 0 to F, otherwise wrap to FF
        ; tmp1 is 0 for first case, 1 otherwise
        ldx     pref_copy
        dex                     ; reduce by 1
        lda     tmp1
        bne     no_wrap         ; don't need to worry about full byte wrap
        cpx     #$ff
        bne     no_wrap
        ldx     #$0f            ; we wrapped to $ff, but should be $0f

no_wrap:
        ; store and print the new value
        stx     pref_copy
        jsr     print_copy

not_up:

; --------------------------------------------------------------------
; ESC - leave processing
; --------------------------------------------------------------------
        cmp     #FNK_ESC
        bne     not_esc

        ; exit with escape code, caller will act on it.
        lda     #$00
        ldx     #$00
        rts

not_esc:


        ; jsr     _wait_scan1
        ; jsr     _wait_scan1
        ; jsr     _wait_scan1
        ; jsr     debug

        jmp     start_kb_get

print_copy:
        lda     pref_copy
        ; convert A to hex in temp_num
        jsr     pusha
        setax   #temp_num
        jsr     hexb

        ; invert first 2 bytes of the ascii string
        ldy     #1
:       lda     temp_num, y
        ora     #$80
        sta     temp_num, y
        dey
        bpl     :-

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


.data

; the lengths of each option shown
mi_prefs_char_count:
                .byte 0, 0, 1, 1, 1


.bss
pref_copy:      .res 1
