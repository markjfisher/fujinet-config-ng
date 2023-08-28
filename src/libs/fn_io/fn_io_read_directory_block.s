        .export     _fn_io_read_directory_block
        .import     fn_io_copy_dcb, popa, _fn_io_dosiov

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"

; void *fn_io_read_directory_block(uint8_t maxlen, uint8_t pages, uint8_t extended_mode, void *buffer)
;
; pages is number of 256 blocks to request
.proc _fn_io_read_directory_block
        axinto  ptr1    ; buffer location
        popa    tmp4    ; extended mode, 1 = on, 0 = off
        
        ; PAGES in tmp1
        popa    tmp1    ; pages
        sec
        sbc     #$01    ; force into 0-7 range (from 1-8 from caller) to fit into 3 bits
        ora     #$C0    ; force bits 7&8 to mark this as block mode
        sta     tmp3

        ; tmp3 = (PAGES | 0xC0) + if extended ? 0x20 : 0
        ldx     tmp4
        beq     :+      ; not extended

        ; Add extended mode flag
        ora     #$20    ; set the extended mode flag        
        sta     tmp3

:       popa    tmp2    ; maxlen

        setax   #t_io_read_directory_block
        jsr     fn_io_copy_dcb

        mva     tmp1, IO_DCB::dbythi    ; pages to expect back 
        mva     tmp2, IO_DCB::daux1     ; maxlen
        mva     tmp3, IO_DCB::daux2     ; pages | 0xC0 | 0x20 if extended dir info requested
        mwa     ptr1, IO_DCB::dbuflo

        jsr     _fn_io_dosiov
        setax   ptr1
        rts

.endproc

.rodata
t_io_read_directory_block:
        .byte $f6, $40, $ff, $ff, $0f, $00, $00, $ff, $ff, $ff
