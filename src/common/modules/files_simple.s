        .export     files_simple
        .export     mf_dir_or_file

        ; debug only
        .export     mf_dir_pos, mf_entry_index, mf_selected

        .import     debug
        .import     mod_current, host_selected, kb_global
        .import     pusha, pushax, fn_put_c, _fn_strlen, _fn_memclr, _fn_put_s, _fn_clr_highlight, _fn_clrscr, _fn_strncat
        .import     _fn_highlight_line, current_line
        .import     fn_dir_path, fn_dir_filter, fn_io_buffer
        .import     _fn_io_close_directory, _fn_io_read_directory, _fn_io_set_directory_position, _fn_io_open_directory
        .import     _fn_io_error, _fn_io_mount_host_slot
        .import     select_device_slot

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
        ; clear the dir/file indicator. if it's a dir, the print routine will change the value.
        ldx     mf_entry_index
        mva     #$00, {mf_dir_or_file, x}

        pusha   #DIR_MAX_LEN    ; the max length of each line for directory/file names
        lda     #$00            ; special aux2 param
        jsr     _fn_io_read_directory

        ; A/X contain pointer to the data just read (which is also just fn_io_buffer)
        ; an end of dir is 0x7f, 0x7f
        axinto  ptr1
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
        adw     mf_dir_pos, #$10 ; TODO: FIX MACRO TO USE #DIR_PG_CNT
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
        sbw     mf_dir_pos, #$10    ; TODO: FIX THIS TO USE #DIR_PG_CNT IN MACROS
        jmp     l_files

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
        sbw     mf_dir_pos, #$10        ; TODO: FIX THIS TO USE #DIR_PG_CNT 
        jmp     l_files

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

        cmp     mf_entries_cnt
        bcc     :+              ; not on last entry for page

        ; it's last position, but is it eod? It is EOD if our position is not DIR_PG_CNT, as that means we're on last one and not all way down bottom of page
        cmp     #DIR_PG_CNT
        bne     exit_reloop     ; must be on a EOD page, so ignore this keypress

        ; valid down, increase by page count, but set our cursor on first line to look cool
        mva     #$00, mf_selected
        adw     mf_dir_pos, #$10    ; TODO: FIX MACRO SO CAN USE #DIR_PG_CNT
        jmp     l_files

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
        ; TODO ".." parent dir handling

        ; read the dir/file indicator for current highlight for current page. don't rely on screen reading else can't port to versions that have no ability to grab screen memory
        ldx     mf_selected
        lda     mf_dir_or_file, x

        ; 0 is a file, 1 is a dir
        beq     enter_is_file

        ; we're a directory, so go into it, and restart directory listing.
        jsr     _fn_clr_highlight
        jsr     enter_dir
        mva     #$00, mf_selected
        jmp     l_files

enter_is_file:
        ; get user's choice of which to device to put the host
        jsr     select_device_slot
        ; and take us back to where we were on file list
        jmp     l_files


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
        jmp     l_files

not_parent:
; -------------------------------------------------
; NOT HANDLED
        ldx     #KBH::NOT_HANDLED    ; flag main kb handler it should handle this code, still in A
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
        ; unset the final '/' in string, we don't need to display it as we have a dir char
        mva     #$00, {(ptr1), y}
        ldx     #$00            ; x coordinate for dir
        ldy     mf_entry_index

        ; save the fact this is a dir
        mva     #$01, {mf_dir_or_file, y} 

        lda     #DIR_CHAR
        jsr     fn_put_c

skip_show_dir_char:
        put_s   #$01, mf_entry_index, ptr1
        rts

enter_dir:
        ; open dir for current path, grab the full name of this selected path, and append it to current path string.
        lda     host_selected
        jsr     _fn_io_open_directory

        ; set the directory position to top + highlighted
        lda     mf_selected
        sta     tmp1
        mva     #$00, tmp2
        adw     mf_dir_pos, tmp1, tmp3      ; pretend tmp1 is word value, and save result in tmp3/4

        setax   tmp3                        ; store this in A/X for call
        jsr     _fn_io_set_directory_position

        ; read the selected directory for as many bytes as we are able given current path value, and append path with it.
        setax   #fn_dir_path        
        jsr     _fn_strlen
        sta     tmp1

        lda     #$e0            ; max length of path
        sec
        sbc     tmp1            ; subtract current path length
        sta     mf_entry_index  ; save it in our safe temp variable used for looping elsewhere
        jsr     pusha           ; store the reduced length on stack for call
        lda     #$00            ; special aux2 param
        jsr     _fn_io_read_directory

        ; fn_io_buffer contains the dir name we need to append to the path

        pushax  #fn_dir_path     ; dst, where we will apend the path to.
        pushax  #fn_io_buffer    ; src, which has a trailing slash conveniently
        lda     mf_entry_index  ; the free space in path
        jmp     _fn_strncat
        ; implicit rts
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


mf_dir_or_file: .res DIR_PG_CNT