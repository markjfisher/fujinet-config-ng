        .export     _fn_io_open_directory, fn_dir_path, fn_dir_filter
        .import     _fn_io_copy_dcb, fn_io_buffer
        .import     pushax, _fn_strncat, _fn_strncpy
        .include    "atari.inc"
        .include    "../inc/macros.inc"
        .include    "fn_io.inc"

; int _fn_io_open_directory(host_slot)
;
; returns 0 for success.
.proc _fn_io_open_directory
        pha                     ; store the host_slot. can't use tmp1 it's trashed by _fn_strncpy/cat

        lda     fn_dir_filter      ; if filter set, we need to copy/cat
        bne     filter_set

        ; with no filter, we can simply use the fn_dir_path directly, which is the
        ; more likely case when browsing, and no filter set, and saves a lot of copying strings
        ; at the small cost of extra code
just_path:
        jsr     set_dcb

        pla
        ; set the host_slot into DAUX1
        sta     IO_DCB::daux1

        ; and use path in call to open_directory
        mwa     #fn_dir_path, DBUFLO
        jsr     SIOV
        lda     #$00
        ldx     #$00
        rts

filter_set:
        lda #$00            ; clear the buffer
        ldx #$00
:       sta fn_io_buffer, x
        inx
        bne :-

        ; merge path and filter
        pushax  #fn_io_buffer
        pushax  #fn_dir_path
        lda     #$e0
        jsr     _fn_strncpy

        pushax  #fn_io_buffer
        pushax  #fn_dir_filter
        lda     #$20
        jsr     _fn_strncat

        ; check if the _fn_strncat worked, errors if there was NO end-of-string (0) in path.
        bne     error

        jsr     set_dcb

        pla     ; set the host_slot into DAUX1
        sta     IO_DCB::daux1
        ; set the location of the path and filter
        mwa     #fn_io_buffer, DBUFLO
        jsr     SIOV
        lda     #$00    ; mark success and fall through to return

error:  ; already non-zero in the error case
        ldx     #$00
        rts

set_dcb:
        setax   #t_io_open_directory
        jmp     _fn_io_copy_dcb
        ; implicit rts

.endproc

.rodata
t_io_open_directory:
        .byte $f7, $80, <fn_io_buffer, >fn_io_buffer, $0f, $00, $00, $01, $ff, $00

.bss
; 256 bytes temp area for storing filter and path
fn_dir_filter: .res $20
fn_dir_path:   .res $e0