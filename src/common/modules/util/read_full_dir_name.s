        .export     read_full_dir_name

        .import     get_to_dir_pos
        .import     _fuji_read_directory
        .import     _malloc
        .import     pusha

        .include    "zp.inc"
        .include    "macros.inc"


; char *read_full_dir_name()
;
; gets current dir name into AX, max 255 chars.
; CALLER MUST RELEASE MEMORY AFTER USING RETURN STRING.
.proc read_full_dir_name
        jsr     get_to_dir_pos    ; get ourselves at the directory position, must include filter that was used on page, else wrong file is read

        ; get filename to 255 chars
        setax   #$ff
        jsr     pusha                   ; push size for read dir call, doesn't change x
        jsr     _malloc
        axinto  ptr1                    ; memloc = ptr1

        ; do a 255 byte read of current dir entry (file)
        pusha   #$00                    ; aux
        setax   ptr1
        jsr     _fuji_read_directory
        setax   ptr1
        rts
        ; AX holds result of memory with path name in that must be free'd.
.endproc