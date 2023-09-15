        .export     read_full_dir_name

        .import     get_to_dir_pos
        .import     _fn_io_read_directory
        .import     _malloc
        .import     pusha

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"


; char *read_full_dir_name()
;
; gets current dir name into AX, max 255 chars.
; CALLER MUST RELEASE MEMORY AFTER USING RETURN STRING.
.proc read_full_dir_name
        jsr     get_to_dir_pos                          ; get ourselves at the directory position

        ; get filename to 255 chars
        setax   #$ff
        jsr     pusha                   ; push size for read dir call
        jsr     _malloc
        axinto  ptr1                    ; memloc = ptr1

        ; do a 255 byte read of current dir entry (file)
        pusha   #$00                    ; aux
        setax   ptr1
        jmp     _fn_io_read_directory
        ; implicit rts, AX holds result of memory with path name in that must be free'd.
.endproc