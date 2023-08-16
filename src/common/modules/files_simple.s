        .export     files_simple

        ; debug only
        .export     mf_dir_pos, mf_entry_index, mf_selected

        .import     mod_current, host_selected, kb_global
        .import     pusha, pushax, fn_put_c, _fn_strlen, _fn_memclr, _fn_put_s, _fn_clr_highlight, _fn_clrscr
        .import     _fn_highlight_line, current_line
        .import     fn_dir_path, fn_dir_filter
        .import     _fn_io_close_directory, _fn_io_read_directory, _fn_io_set_directory_position, _fn_io_open_directory
        .import     _fn_io_error, _fn_io_mount_host_slot

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"

; same as original implementation, reads dirs 1 by 1
.proc files_simple

        jsr     init_files

        ; -----------------------------------------------------
        ; mount the host.
        lda     host_selected
        jsr     _fn_io_mount_host_slot

        jsr     _fn_io_error
        beq     no_error1
        ; TODO: display error

        ; set next module as hosts
        mva     #Mod::hosts, mod_current
        rts

no_error1:

; we'll keep looping around here until something is chosen, or we exit
l_files:
        jsr     _fn_clr_highlight

; for some reason, the original CONFIG always closes and re-opens the directory
; we will do that to start, then test it without doing those operations, but just managing it in "enter" etc.

        ; -----------------------------------------------------
        ; open directory
        lda     host_selected
        jsr     _fn_io_open_directory

        jsr     _fn_io_error
        beq     no_error2
        ; TODO: display error
        ; TODO: unmount host?

        ; set next module as hosts
        mva     #Mod::hosts, mod_current
        rts

no_error2:

        ; -----------------------------------------------------
        ; set directory position
        setax   mf_dir_pos
        jsr     _fn_io_set_directory_position


; --------------------------------------------------------------------------
; SHOW PAGE OF ENTRIES
; --------------------------------------------------------------------------
        mva     #$00, mf_entry_index
        jsr     _fn_clrscr      ; left as late as possible before we start redisplaying entries
l_entries:
        pusha   #35             ; aka DIR_MAX_LEN, the max length of each line for directory/file names
        lda     #$00            ; special aux2 param
        jsr     _fn_io_read_directory

        ; A/X contain pointer to the data just read (which is also just fn_io_buffer)
        ; an end of dir is 0x7f, 0x7f
        getax   ptr1
        ldy     #$01
        lda     (ptr1), y

        cmp     #$7f            ; magic marker
        beq     finish_list

        jsr     print_entry

        inc     mf_entry_index
        lda     mf_entry_index
        cmp     #DIR_PG_CNT     ; entries per page
        bcc     l_entries

finish_list:
        ; make the mf_entries_cnt be 0 based
        ; dec     mf_entry_index ; BREAKS EVERYTHING
        ; save the number we showed, so we know if we can move highlight down, and if we are at EOD yet (if it's equal to DIR_PG_CNT, we still have more pages to show)
        mva     mf_entry_index, mf_entries_cnt
        ; turn our cursor back on
        mva     mf_selected, current_line
        jsr     _fn_highlight_line

        ; TODO: check if we can manage this better. LESS SIO PLX
        lda     host_selected
        jsr     _fn_io_close_directory

        ; handle keyboard
        lda     #DIR_PG_CNT
        sec
        sbc     #$01
        jsr     pusha           ; we can highlight max of DIR_PG_CNT (i.e. 0 to DIR_PG_CNT - 1)
        pusha   #Mod::files     ; L/R arrow keys will be overridden by local kb handler
        pusha   #Mod::files     ; L/R arrow keys this will be overridden by local kb handler
        pushax  #mf_selected    ; memory address of our current file/dir
        setax   #mod_files_kb   ; this kb handler, the global kb handler will jump into this routine which will handle the interactions
        jmp     kb_global       ; rts from this will drop out of module

error:
        rts


; --------------------------------------------------------------------------
; KEYBOARD HANDLER
; --------------------------------------------------------------------------
mod_files_kb:
; -------------------------------------------------
; right - next page of results if there are any
        cmp     #FNK_RIGHT
        beq     do_right
        cmp     #FNK_RIGHT2
        beq     do_right
        bne     not_right

do_right:
        ; if there are less than DIR_PG_CNT, we skip as we must be at end of directory on current view
        lda     mf_entries_cnt
        cmp     #DIR_PG_CNT
        bcc     exit_reloop

        mva     #$00, mf_selected
        adw     mf_dir_pos, #$10
        jmp     l_files

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
        sbw     mf_dir_pos, #$10
        jmp     l_files

; -------------------------------------------------
; exit back to main KB handler with a reloop. this was a key movement we are ignoring but want to continue in files module.
; Code is in the middle so all branches can reach it
exit_reloop:
        ldx     #$01
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
        sbw     mf_dir_pos, #$10
        jmp     l_files

        ; otherwise pass back to the global to process generic UP as though we didn't handle it at all
:       lda     #FNK_UP         ; reload the key into A
        ldx     #$00
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

        cmp     mf_entries_cnt
        bcc     :+              ; not on last entry for page

        ; it's last position, but is it eod? It is EOD if our position is not DIR_PG_CNT, as that means we're on last one and not all way down bottom of page
        cmp     #DIR_PG_CNT
        bne     exit_reloop     ; must be on a EOD page, so ignore this keypress

        ; valid down, increase by page count, but set our cursor on first line to look cool
        mva     #$00, mf_selected
        adw     mf_dir_pos, #$10
        jmp     l_files

        ; otherwise pass back to the global to process generic DOWN
:       lda     #FNK_DOWN         ; reload the key into A
        ldx     #$00
        rts


not_down:
; --------------------------------------------------------------------------
; ESC
        cmp     #FNK_ESC
        bne     :+

        ; ESC for files means return to HOSTS list
        mva     #Mod::hosts, mod_current
        ldx     #$02    ; main kb handler exit
        rts

:
; --------------------------------------------------------------------------
; ENTER
        cmp     #FNK_ENTER
        bne     :+
        ; go into the dir, or choose the file

        ; we are highlighting a DIR if


enter_is_file:
        ; move to devices module
        mwa     #Mod::devices, mod_current

        ldx     #$02
        rts

:
; -------------------------------------------------
; NOT HANDLED
        ldx     #$00    ; flag main kb handler it should handle this code, still in A
        rts

; -----------------------------------------------------
init_files:
        lda     host_selected
        jsr     _fn_io_close_directory

        mwa     #$00, mf_dir_pos

        ; clear path
        pusha   #$e0
        setax   #fn_dir_path
        jsr     _fn_memclr

        ; clear filter
        pusha   #$20
        setax   #fn_dir_filter
        jsr     _fn_memclr

        ; set initial path to '/'
        mwa     #fn_dir_path, ptr1
        ldy     #$00
        mva     #'/', {(ptr1), y}

        ; initialise mf_selected
        mva     #$00, mf_selected

        rts

print_entry:
        ; display the entry, read it from ptr1

        ; is this a dir? last char of name is '/' - ASSUMPTION - string never 0 length
        setax   ptr1
        jsr     _fn_strlen
        tay
        dey
        lda     (ptr1), y       ; the last character of string
        cmp     #'/'
        bne     skip_show_dir_char
        ldx     #$00
        ldy     mf_entry_index
        lda     #DIR_CHAR
        jsr     fn_put_c

skip_show_dir_char:
        put_s   #$02, mf_entry_index, ptr1
        rts

.endproc

.bss
; the current directory position value while browsing of first entry on screen
mf_dir_pos:     .res 2
; a place to hold the loop index for files being shown on screen
mf_entry_index: .res 1
; currently highlighted option
mf_selected:    .res 1
; the total number of entries on the current screen
mf_entries_cnt: .res 1