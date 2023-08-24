        .export     _fn_io_open_directory

        .import     _fn_io_copy_dcb, fn_io_buffer, fn_dir_path, fn_dir_filter, _fn_io_dosiov
        .import     pushax, _fn_strncat, _fn_strncpy

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; int _fn_io_open_directory(host_slot)
;
; returns 0 for success.
.proc _fn_io_open_directory
        ; save the host_slot
        sta     tmp1

        lda     fn_dir_filter    ; if filter set, we need to copy/cat
        bne     filter_set

        ; with no filter, we can simply use the fn_dir_path directly, which is the
        ; more likely case when browsing, and no filter set, and saves a lot of copying strings
        ; at the small cost of extra code
just_path:
        jsr     set_dcb

        ; set the host_slot into DAUX1
        mva     tmp1, IO_DCB::daux1

        ; and use path in call to open_directory
        mwa     #fn_dir_path, IO_DCB::dbuflo
        jsr     _fn_io_dosiov
        lda     #$00
        ldx     #$00
        rts

filter_set:
        lda     #$00            ; clear the buffer
        ldx     #$00
:       sta     fn_io_buffer, x
        inx
        bne     :-

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

        ; set the host_slot into DAUX1
        mva     tmp1, IO_DCB::daux1

        jsr     _fn_io_dosiov
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
