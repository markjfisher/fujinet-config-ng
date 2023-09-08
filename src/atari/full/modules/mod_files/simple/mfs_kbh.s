        .export mfs_kbh

        .import     _edit_line
        .import     _fn_strlen
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     get_scrloc
        .import     mf_dir_pos
        .import     mf_selected
        .import     mfs_entries_cnt
        .import     mfs_kbh_select_current
        .import     mod_current
        .import     pusha
        .import     pushax

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"

; 'A' contains the keyboard ascii code
.proc mfs_kbh

; -------------------------------------------------
; right - next page of results if there are any
        cmp     #FNK_RIGHT
        beq     do_right
        cmp     #FNK_RIGHT2
        beq     do_right
        bne     not_right

do_right:
        ; if there are less than DIR_PG_CNT, we skip as we must be at end of directory on current view
        lda     mfs_entries_cnt
        cmp     #DIR_PG_CNT
        bcc     exit_reloop

        mva     #$00, mf_selected
        adw1    mf_dir_pos, #DIR_PG_CNT
        ldx     #KBH::APP_1
        rts

not_right:
; -------------------------------------------------
; left - prev page of results if there are any
        cmp     #FNK_LEFT
        beq     do_left
        cmp     #FNK_LEFT2
        beq     do_left
        bne     not_left

do_left:
        ; if we're already at 0 position, dont do anything
        cpw     mf_dir_pos, #$00
        beq     exit_reloop

        ; set selected to first, reduce dir_pos by page count and reload dirs
        mva     #$00, mf_selected
        sbw1    mf_dir_pos, #DIR_PG_CNT
        ldx     #KBH::APP_1
        rts

; -------------------------------------------------
; exit back to main KB handler with a reloop. this was a key movement we are ignoring but want to continue in files module.
; Code is in the middle so all branches can reach it
exit_reloop:
        ldx     #KBH::RELOOP
        rts

not_left:
; -------------------------------------------------
; up
        cmp     #FNK_UP
        beq     do_up
        cmp     #FNK_UP2
        beq     do_up
        bne     not_up

do_up:
        ; check if we're at position 0, if not, let global handler deal with generic up
        lda     mf_selected
        bne     :+

        ; it's first position, but is it first dir_pos?
        cpw     mf_dir_pos, #$00
        beq     exit_reloop      ; we're already at the first directory position possible, so can't go back

        ; valid up, reduce by page count, but set our cursor on last line to look cool
        mva     #(DIR_PG_CNT-1), mf_selected
        sbw1    mf_dir_pos, #DIR_PG_CNT
        ldx     #KBH::APP_1
        rts

        ; otherwise pass back to the global to process generic UP as though we didn't handle it at all
:       lda     #FNK_UP         ; reload the key into A
        ldx     #KBH::NOT_HANDLED
        rts

not_up:
; -------------------------------------------------
; down
        cmp     #FNK_DOWN
        beq     do_down
        cmp     #FNK_DOWN2
        beq     do_down
        bne     not_down

do_down:
        ; check if we're at last position, if not, let global handler deal with generic up
        lda     mf_selected     ; add 1, as selected is 0 based, and following tests are against counts (1 based)
        clc
        adc     #$01

        cmp     mfs_entries_cnt
        bcc     :+              ; not on last entry for page

        ; it's last position, but is it eod? It is EOD if our position is not DIR_PG_CNT, as that means we're on last one and not all way down bottom of page
        cmp     #DIR_PG_CNT
        bne     exit_reloop     ; must be on a EOD page, so ignore this keypress

        ; valid down, increase by page count, but set our cursor on first line to look cool
        mva     #$00, mf_selected
        adw1    mf_dir_pos, #DIR_PG_CNT
        ldx     #KBH::APP_1
        rts

        ; otherwise pass back to the global to process generic DOWN
:       lda     #FNK_DOWN         ; reload the key into A
        ldx     #KBH::NOT_HANDLED
        rts


not_down:
; --------------------------------------------------------------------------
; ESC
        cmp     #FNK_ESC
        bne     not_esc

        ; ESC for files means return to HOSTS list
        mva     #Mod::hosts, mod_current
        ldx     #KBH::EXIT    ; main kb handler exit
        rts

not_esc:
; --------------------------------------------------------------------------
; ENTER
        cmp     #FNK_ENTER
        bne     not_enter
        ; go into the dir, or choose the file

        jmp     mfs_kbh_select_current
        ; implicit rts with X containing status

not_enter:
; --------------------------------------------------------------------------
; < PARENT DIR
        cmp     #FNK_PARENT
        bne     not_parent

        ; get the current path's length
        setax   #fn_dir_path
        jsr     _fn_strlen

        ; check if path already just "/", and if so ignore this. ESC returns you to HOSTS list
        cmp     #$01
        beq     not_parent

        ; A is length of path, so look for '/' before this. There will always be one as '/' is root
        tax
        dex     ; drop one to make it 0 index based (as length is 1 based, so we'd accidentally detect the final / every time)
:       dex
        lda     fn_dir_path, x
        cmp     #'/'
        bne     :-
        
        ; X = position in path where parent '/' is, so replace everything after it up to path length ($e0) with 0
        lda     #$00
:       inx
        sta     fn_dir_path, x
        cpx     #$df
        bne     :-

        ; set selected to 0, pos to 0, and go back to the top
        mva     #$00, mf_selected
        mwa     #$00, mf_dir_pos
        ldx     #KBH::APP_1
        rts

not_parent:
; --------------------------------------------------------------------------
; F/f - Set Filter
        cmp     #FNK_FILTER
        beq     :+
        cmp     #FNK_FILTER2
        bne     not_filter

:       ldx     #5
        ldy     #1
        jsr     get_scrloc           ; sets ptr4 to given screen location

        ; allow an edit at the filter location
        pushax  #fn_dir_filter          ; filter string
        pushax  ptr4                    ; scr location
        lda     #31                     ; filter is max 32 but decrease 1 for the 'extra' 0 separating the path and filter. and this is also happily the screen width max with the "Fltr:" string and borders
        jsr     _edit_line
        beq     no_edit

        ; if there was an edit, reset selected and put back to start of dir, as the list will have changed
        mva     #$00, mf_selected
        sta     mf_dir_pos

no_edit:
        ldx     #KBH::APP_1
        rts

not_filter:
; -------------------------------------------------
; NOT HANDLED
        ldx     #KBH::NOT_HANDLED    ; flag main kb handler it should handle this code, still in A
        rts

.endproc