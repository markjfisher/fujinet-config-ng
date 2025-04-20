        .export     read_full_dir_name

        .import     get_to_dir_pos
        .import     _fuji_read_directory
        .import     pushax

        .import     mf_fname_buf

        .include    "zp.inc"
        .include    "macros.inc"


; char *read_full_dir_name()
;
; gets current dir name into AX, max 255 chars.
.proc read_full_dir_name
        jsr     get_to_dir_pos    ; get ourselves at the directory position, must include filter that was used on page, else wrong file is read

        ; get filename to 255 chars
        ; do a 255 byte read of current dir entry (file)
        ; push 2 bytes onto stack, $ff, then $00 for maxlen, and aux. bit of a hack to save doing 2 jsr calls
        ; bool fuji_read_directory(unsigned char maxlen, unsigned char aux2, char *buffer)
        ; FF -> maxlen, 00 -> aux2
        pushax  #$ff00
        setax   #mf_fname_buf
        jsr     _fuji_read_directory
        setax   #mf_fname_buf
        rts
.endproc