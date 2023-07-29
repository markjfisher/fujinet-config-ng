        .export     io_open_directory, dir_path, dir_filter
        .import     io_copy_dcb, io_buffer
        .import     pusha, pushax, tmp1, strncat, strncpy
        .include    "atari.inc"
        .include    "../inc/macros.inc"
        .include    "io.inc"

; int io_open_directory(host_slot)
;
; returns 0 for success.
.proc io_open_directory
        pha                     ; store the host_slot. can't use tmp1 it's trashed by strncpy/cat

        lda     dir_filter      ; if filter set, we need to copy/cat
        bne     filter_set

        ; with no filter, we can simply use the dir_path directly, which is the
        ; more likely case when browsing, and no filter set, and saves a lot of copying strings
        ; at the small cost of extra code
just_path:
        jsr     set_dcb

        pla
        ; set the host_slot into DAUX1
        sta     IO_DCB::daux1

        ; and use path in call to open_directory
        mwa     #dir_path, DBUFLO
        jsr     SIOV
        lda     #$00
        ldx     #$00
        rts

filter_set:
        lda #$00            ; clear the buffer
        ldx #$00
:       sta io_buffer, x
        inx
        bne :-

        ; merge path and filter
        pushax  #io_buffer
        pushax  #dir_path
        lda     #$e0
        jsr     strncpy

        pushax  #io_buffer
        pushax  #dir_filter
        lda     #$20
        jsr     strncat

        ; check if the strncat worked, errors if there was NO end-of-string (0) in path.
        bne     error

        jsr     set_dcb

        pla     ; set the host_slot into DAUX1
        sta     IO_DCB::daux1
        ; set the location of the path and filter
        mwa     #io_buffer, DBUFLO
        jsr     SIOV
        lda     #$00    ; mark success and fall through to return

error:  ; already non-zero in the error case
        ldx     #$00
        rts

set_dcb:
        setax   #t_io_get_open_directory
        jmp     io_copy_dcb
        ; implicit rts

.endproc

.data

t_io_get_open_directory:
        .byte $f7, $80, <io_buffer, >io_buffer, $0f, $00, $00, $01, $ff, $00

.bss
; 256 bytes temp area for storing filter and path
dir_filter: .res $20
dir_path:   .res $e0