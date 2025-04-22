        .export mfs_kbh

        .import     _clr_status
        .import     _edit_string
        .import     _es_params
        .import     _fc_strlen
        .import     debug
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     get_scrloc
        .import     mf_dir_pg_cnt
        .import     mf_dir_pos
        .import     mf_selected
        .import     mf_new_disk
        .import     mf_cst_disk
        .import     mf_copy_end
        .import     mf_copy_err
        .import     mf_copy_start
        .import     mf_copying
        .import     mf_dir_or_file
        .import     mfs_entries_cnt
        .import     mf_is_eod
        .import     mfs_kbh_select_current
        .import     mod_current

        .include    "edit_string.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "macros.inc"
        .include    "modules.inc"
        .include    "zp.inc"

.segment "CODE2"

; 'A' contains the keyboard ascii code
; ptr4
.proc mfs_kbh

; -------------------------------------------------
; right - next page of results if there are any
        cmp     #FNK_RIGHT
        beq     do_right
        cmp     #FNK_RIGHT2
        beq     do_right
        bne     not_right

do_right:
        ; allow right if we're not at EOD. is_eod = 1 if we are on last page
        lda     mf_is_eod
        bne     exit_reloop

        mva     #$00, mf_selected
        adw1    mf_dir_pos, mf_dir_pg_cnt
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
        sbw1    mf_dir_pos, mf_dir_pg_cnt
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
        mva     mf_dir_pg_cnt, mf_selected
        dec     mf_selected                     ; mf_selected = mf_dir_pg_cnt - 1
        sbw1    mf_dir_pos, mf_dir_pg_cnt
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
        ; check if we're at last position, if not, let global handler deal with generic down
        lda     mf_selected     ; add 1, as selected is 0 based, and following tests are against counts (1 based)
        clc
        adc     #$01

        cmp     mfs_entries_cnt
        bcc     :+              ; not on last entry for page

        ; it's last position, but is it eod?
        lda     mf_is_eod
        cmp     #$01
        beq     exit_reloop     ; must be on a EOD page, so ignore this keypress

        ; valid down, increase by page count, but set our cursor on first line to look cool
        mva     #$00, mf_selected
        adw1    mf_dir_pos, mf_dir_pg_cnt
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
        jsr     _fc_strlen

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
; F - Set Filter
        cmp     #FNK_FILTER
        bne     not_filter

        mwa     #fn_dir_filter, {_es_params + edit_string_params::initial_str}
        mva     #$06, {_es_params + edit_string_params::x_loc}
        mva     #$01, {_es_params + edit_string_params::y_loc}
        mva     #$1f, {_es_params + edit_string_params::max_length}   ; 31 bytes for length and viewport to fit nicely on screen
        sta     _es_params + edit_string_params::viewport_width

        mva     #$00, {_es_params + edit_string_params::is_password}
        sta     _es_params + edit_string_params::is_number
        sta     _es_params + edit_string_params::max_length + 1

        jsr     _edit_string
        beq     no_edit

        ; if there was an edit, reset selected and put back to start of dir, as the list will have changed
        mva     #$00, mf_selected
        sta     mf_dir_pos

no_edit:
        ldx     #KBH::APP_1
        rts

not_filter:

; --------------------------------------------------------------------------
; N - New Disk
        cmp     #FNK_NEWDISK
        bne     not_new_disk

        jsr     mf_new_disk
        ldx     #KBH::APP_1
        rts

not_new_disk:
; --------------------------------------------------------------------------
; C - COPY
        cmp     #FNK_COPY
        bne     not_copy

        ; if mf_copying is false, then need to take current selection as source, but only if it's a file
        ; if it's true, start the copy into the current path 

        lda     mf_copying
        bne     @perform_copy

        ; not in copying mode, so this initiates the copy. check it's a file, not a dir
        ldx     mf_selected
        lda     mf_dir_or_file, x              ; 0 is a file, 1 is a dir
        bne     @copy_err_is_dir

        ; the selection is a file, initiate the copy
        jsr     mf_copy_start

        ; and just reloop waiting for the user to pick a destination
        ldx     #KBH::APP_1
        rts

@perform_copy:
        ; 2nd half of the copy
        jsr     mf_copy_end

        ldx     #KBH::APP_1
        rts

@copy_err_is_dir:
        jsr     mf_copy_err
        ldx     #KBH::APP_1
        rts

not_copy:

; --------------------------------------------------------------------------
; X - Stop copy mode
        cmp     #FNK_EXITCOPY
        bne     not_exit_copy

        mva     #$00, mf_copying
        jsr     _clr_status
        ldx     #KBH::APP_1
        rts

not_exit_copy:
; -------------------------------------------------
; NOT HANDLED
        ldx     #KBH::NOT_HANDLED    ; flag main kb handler it should handle this code, still in A
        rts

.endproc