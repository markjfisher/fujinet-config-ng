        .export     files_simple
        .export     mf_dir_or_file
        .export     mf_dir_pos
        .export     mf_selected

        .import     _ellipsize
        .import     _fn_clr_highlight
        .import     _fn_clrscr_files
        .import     _fn_edit
        .import     _fn_highlight_line
        .import     _fn_io_close_directory
        .import     _fn_io_mount_host_slot
        .import     _fn_io_open_directory
        .import     _fn_io_read_directory
        .import     _fn_io_set_directory_position
        .import     _fn_memclr
        .import     _fn_put_help
        .import     _fn_put_s
        .import     _fn_put_status
        .import     _fn_strlen
        .import     _fn_strncat
        .import     _free
        .import     _malloc
        .import     copy_path_filter_to_buffer
        .import     current_line
        .import     debug
        .import     files_simple_y_offset
        .import     fn_dir_filter
        .import     fn_dir_path
        .import     fn_get_scrloc
        .import     fn_io_buffer
        .import     fn_io_hostslots
        .import     fn_put_c
        .import     get_to_current_hostslot
        .import     host_selected
        .import     kb_global
        .import     mf_filter
        .import     mf_h1
        .import     mf_h3
        .import     mf_host
        .import     mf_path
        .import     mf_s1
        .import     mod_current
        .import     pusha
        .import     pushax
        .import     read_full_dir_name
        .import     return0
        .import     return1
        .import     select_device_slot

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"

; same as original implementation, reads dirs 1 by 1
.proc files_simple
        jsr     init_files

        ; -----------------------------------------------------
        ; mount the host.
        pusha   host_selected
        setax   #fn_io_hostslots
        jsr     _fn_io_mount_host_slot

        lda     IO_DCB::dstats
        and     #$80
        beq     no_error1
        ; TODO: display error

        ; set next module as hosts
        mva     #Mod::hosts, mod_current
        rts

no_error1:

; we'll keep looping around here until something is chosen, or we exit
l_files:
        jsr     _fn_clrscr_files      ; as soon as possible to print dir etc
        jsr     print_dir_info
        jsr     _fn_clr_highlight
        jsr     copy_path_filter_to_buffer

        ; -----------------------------------------------------
        ; open directory
        pusha   host_selected
        setax   #fn_io_buffer
        jsr     _fn_io_open_directory

        lda     IO_DCB::dstats
        and     #$80
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
        put_status #0, #mf_s1
        put_help #0, #mf_h1
        put_help #1, #mf_h3

l_entries:
        ; clear the dir/file indicator. if it's a dir, the print routine will change the value.
        ldx     mf_entry_index
        mva     #$00, {mf_dir_or_file, x}

        pusha   #DIR_MAX_LEN    ; the max length of each line for directory/file names
        pusha   #$00            ; special aux2 param
        setax   #fn_io_buffer
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

        jsr     _fn_io_close_directory

        lda     mf_kbh_running
        beq     :+
        
        ; don't redo kb handler if we're drilling down into directories, it just eats stack space, simply return and let the one previously setup to reloop
        ldx     #KBH::RELOOP
        rts

        ; start main keyboard handler, mark it's running so recursing into dirs doesn't cause stack issues by recursing into kb_global 
:       mva     #$01, mf_kbh_running
        pusha   #DIR_PG_CNT-1   ; we can highlight max of DIR_PG_CNT (i.e. 0 to DIR_PG_CNT - 1)
        pusha   #Mod::files     ; L/R arrow keys will be overridden by local kb handler
        pusha   #Mod::files     ; L/R arrow keys this will be overridden by local kb handler
        pushax  #mf_selected    ; memory address of our current chosen file/dir
        setax   #mod_files_kb   ; this mod's kb handler, the global kb handler will jump into this routine which will handle the interactions
        jmp     kb_global       ; rts from this will drop out of module
        ; implicit rts


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
        bne     enter_error

        mva     #$00, mf_selected
        jmp     l_files

enter_is_file:
        ; get user's choice of which to device to put the host
        jsr     select_device_slot
        ; and take us back to where we were on file list
        jmp     l_files

enter_error:
        ; TODO: print message that the dir is too long to enter.

        ; need to re-highlight line
        jsr     _fn_highlight_line
        ldx     #KBH::RELOOP
        rts

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
; --------------------------------------------------------------------------
; F/f - Set Filter
        cmp     #FNK_FILTER
        beq     :+
        cmp     #FNK_FILTER2
        bne     not_filter

:       ldx     #5
        ldy     #1
        jsr     fn_get_scrloc           ; sets ptr4 to given screen location

        ; allow an edit at the filter location
        pushax  #fn_dir_filter          ; filter string
        pushax  ptr4                    ; scr location
        pusha   #31                     ; filter is max 32 but decrease 1 for the 'extra' 0 separating the path and filter. and this is also happily the screen width max with the "Fltr:" string and borders
        lda     #$00                    ; show blank on pressing ESC for empty string
        jsr     _fn_edit
        beq     no_edit

        ; if there was an edit, reset selected and put back to start of dir, as the list will have changed
        mva     #$00, mf_selected
        sta     mf_dir_pos

no_edit:
        jmp     l_files

not_filter:
; -------------------------------------------------
; NOT HANDLED
        ldx     #KBH::NOT_HANDLED    ; flag main kb handler it should handle this code, still in A
        rts

; -----------------------------------------------------
init_files:
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

        ; initialise mf_selected, and set the kbh_running flag to false so we only do 1 kbh
        mva     #$00, mf_selected
        sta     mf_kbh_running

        jsr     files_simple_y_offset
        sta     mf_y_offset

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
        tya
        clc
        adc     mf_y_offset
        tay

        lda     #DIR_CHAR
        jsr     fn_put_c

skip_show_dir_char:
        put_s   #$01, mf_entry_index, ptr1, mf_y_offset
        rts

.endproc

; Appends the directory we are trying to enter onto path, but only if it fits in the maximum path size.
; So you may be able to see the dir, but you won't be able to go into it if it makes whole path length too long.
; Returns 0 for ok, 1 for error (path too long).
.proc enter_dir
        ; get the chosen dir into 255 byte temp buffer, and then check it will fit on the end of our current path, i.e. doesn't combined go over 254 (allowing for nul)
        jsr     read_full_dir_name      ; AX holds allocated memory - must free it
        axinto  ptr1
        jsr     _fn_strlen
        sta     tmp1                    ; length of new directory we want to enter

        setax   #fn_dir_path
        jsr     _fn_strlen              ; current path length
        sta     tmp2

        ; when added to current path, will it fit? (max #$e0)
        clc
        adc     tmp1
        bcs     too_big                 ; already over $ff in length, so too big
        cmp     #$e0                    ; max dir path size
        bcs     too_big                 ; nope

        inc     tmp1                    ; extra for nul
        ; ptr1 contains the dir name we need to append to the path
        pushax  #fn_dir_path            ; dst, where we will apend the path to.
        pushax  ptr1                    ; src, which has a trailing slash conveniently
        lda     tmp1                    ; we know it will fit and it's this length
        jsr     _fn_strncat
        jsr     free_dir
        jmp     return0

too_big:
        jsr     free_dir
        jmp     return1

free_dir:
        setax   ptr1
        jmp     _free
        ; implicit rts
.endproc

.proc print_dir_info
        ; use 3 lines at the top of screen to display the Host/Filter/Path
        ; titles
        put_s   #0, #0, #mf_host
        put_s   #0, #1, #mf_filter
        put_s   #0, #2, #mf_path

        ; print values
        ; host
        jsr     get_to_current_hostslot         ; sets ptr1 to correct hostslot
        put_s   #5, #0, ptr1

        ; Filter
        lda     fn_dir_filter
        beq     :+
        put_s   #5, #1, #fn_dir_filter

:
        lda     #32             ; max length, including the 0 terminator
        jsr     pusha           ; save as parameter for ellipsize
        jsr     _malloc
        axinto  ptr1            ; save for free
        jsr     pushax          ; dst
        setax   #fn_dir_path    ; src
        jsr     _ellipsize

        ; print the ellipsized string
        put_s   #5, #2, ptr1

        ; free the memory we took
        setax   ptr1
        jsr     _free

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
; y offset for printing files
mf_y_offset:    .res 1

mf_kbh_running: .res 1

mf_dir_or_file: .res DIR_PG_CNT