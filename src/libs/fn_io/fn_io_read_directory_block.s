        .export     _fn_io_read_directory_block
        .import     _fn_io_copy_dcb, fn_io_buffer, popa, _fn_memclr_page, _fn_io_dosiov

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; char *fn_io_read_directory_block(uint8 maxlen, uint8 pages, uint8 extended_mode)
;
; pages is number of 256 blocks to request
.proc _fn_io_read_directory_block
        sta     tmp4    ; extended mode, 1 = on, 0 = off
        
        ; PAGES in tmp1
        popa    tmp1    ; pages
        sec
        sbc     #$01    ; force into 0-7 range (from 1-8 from caller)
        ora     #$C0    ; force bits 7&8 to mark this as block mode
        sta     tmp3

        ; PAGES + 0xC0 + 0x20 if extended in tmp3
        ldx     tmp4
        beq     :+      ; not extended

        ; Add extended mode flag
        ora     #$20    ; set the extended mode flag        
        sta     tmp3

:       popa    tmp2    ; maxlen

        setax   #t_io_read_directory_block
        jsr     _fn_io_copy_dcb

        mva     tmp1, IO_DCB::dbythi    ; pages to expect back 
        mva     tmp2, IO_DCB::daux1     ; maxlen
        mva     tmp3, IO_DCB::daux2     ; pages | 0xC0 | 0x20 if extended dir info requested
        mva     #$7f, fn_io_buffer

        jsr     _fn_io_dosiov
        setax   #fn_io_buffer
        rts

.endproc

.rodata
; force into $4000
t_io_read_directory_block:
        .byte $f6, $40, <$4000, >$4000, $05, $00, $00, $ff, $ff, $ff
