        .export     files_simple

        ; debug only
        .export     mf_dir_pos, mf_entry_index, mf_selected

        .import     mod_current, host_selected, kb_global
        .import     pusha, pushax, fn_put_c, _fn_strlen, _fn_memclr, _fn_put_s
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

; we'll keep looping around here until something is chosen, or we exit
l_files:
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
        ; -----------------------------------------------------
        ; open directory
        lda     host_selected
        jsr     _fn_io_open_directory

        jsr     _fn_io_error
        beq     no_error2
        ; TODO: display error

        ; set next module as hosts
        mva     #Mod::hosts, mod_current
        rts

no_error2:
        ; -----------------------------------------------------
        ; set directory position, if it's >0
        lda     mf_dir_pos
        beq     no_set_dir_pos

        setax   mf_dir_pos
        jsr     _fn_io_set_directory_position

no_set_dir_pos:

        mva     #$00, mf_entry_index
l_entries:
        pusha   #36             ; aka DIR_MAX_LEN, the max length of each line for directory/file names
        lda     #$00            ; special aux2 param
        jsr     _fn_io_read_directory

        ; A/X contain pointer to the data just read (which is also just fn_io_buffer)
        ; an end of dir is 0x7f, 0x7f
        getax   ptr1
        ldy     #$01
        lda     (ptr1), y

        cmp     #$7f            ; magic marker
        beq     dir_end

        jsr     print_entry

        inc     mf_entry_index
        lda     mf_entry_index
        cmp     #$10            ; 16 entries per page
        bcc     l_entries

dir_end:
        lda     host_selected
        jsr     _fn_io_close_directory


        ; reshow the bar at row 0, as this is a new page load
        mva     #$00, mf_selected
        mva     mf_selected, current_line
        jsr     _fn_highlight_line

        ; handle keyboard
        pusha   #15             ; all 16 lines can be used
        pusha   #Mod::files     ; L/R arrow keys will be overridden by local kb handler
        pusha   #Mod::files     ; L/R arrow keys this will be overridden by local kb handler
        pushax  #mf_selected    ; memory address of our current file/dir
        setax   #mod_files_kb   ; this kb handler
        jmp     kb_global       ; rts from this will drop out of module

error:
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


mod_files_kb:
; -------------------------------------------------
; right - next page of results if there are any
        cmp     #FNK_RIGHT
        beq     do_right
        cmp     #FNK_RIGHT2
        beq     do_right
        bne     :+

do_right:
        lda     #$ff

        ldx     #$01    ; tell main kb handler it can re-loop
        rts
:
; -------------------------------------------------
; left - prev page of results if there are any
        cmp     #FNK_LEFT
        beq     do_left
        cmp     #FNK_LEFT2
        beq     do_left
        bne     :+

do_left:
        lda     #$ff

        ldx     #$01    ; tell main kb handler it can re-loop
        rts
:
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

        ; is there a more sophisticated way to tell the entry is a dir?
        lda     #$ff

        ; go into the dir, or choose the file


enter_is_file:
        ; file chosen, set that as our value, and exit to DEVICES page
        ; TODO: write name to some address to keep
        mwa     #Mod::devices, mod_current

        ldx     #$02
        rts

:
; -------------------------------------------------
; up
        cmp     #FNK_UP
        beq     do_up
        cmp     #FNK_UP2
        beq     do_up
        bne     :+

do_up:
        ; check if we're at position 0, if so, go to previous page
        ; and set position to last in list
        lda     #$ff


        ; otherwise pass back to the global to process generic UP
        lda     #FNK_UP         ; reload the key into A
        ldx     #$00
        rts

:
; -------------------------------------------------
; down
        cmp     #FNK_DOWN
        beq     do_down
        cmp     #FNK_DOWN2
        beq     do_down
        bne     :+

do_down:
        ; check if we're at last position in list, if so, go to next page
        ; and set position to first in list
        lda     #$ff

        ; otherwise pass back to the global to process generic DOWN
        lda     #FNK_DOWN         ; reload the key into A
        ldx     #$00
        rts


:
; -------------------------------------------------
; NOT HANDLED

        ldx     #$00    ; flag main kb handler it should handle this code, still in A
        rts

.endproc

.bss
; the current directory position value while browsing of first entry on screen
mf_dir_pos:     .res 2
; a place to hold the loop index for files being shown on screen
mf_entry_index: .res 1
; currently highlighted option
mf_selected:    .res 1
