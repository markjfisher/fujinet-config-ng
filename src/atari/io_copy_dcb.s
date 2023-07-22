; io_copy_dcb.s
;
; defined tables for the DCB values for all io functions
; and exposes a procedure to copy the base data into DCB

        .export         io_copy_dcb
        .import         wifi_enabled
        .importzp       ptr1
        .include        "atari.inc"
        .include        "../inc/macros.inc"

; Only sets DCB
; INPUT:
;       x = index of io function. see IO_TABLES below
.proc io_copy_dcb
        mva {io_dcb_table_lo,x}, ptr1
        mva {io_dcb_table_hi,x}, ptr1+1

        ; copy 12 bytes of table into DCB
        ldy #11
:       mva {(ptr1), y}, {DCB, y}
        dey
        bpl :-
        rts
.endproc

.data

        .linecont +
        .define IO_Tables \
            io_get_wifi_enabled_table

        .linecont -

io_dcb_table_lo:
        .lobytes IO_Tables

io_dcb_table_hi:
        .hibytes IO_Tables

; DCB order is:
;             ddevic, dunit,  dcomnd, dstats, dbuflo, dbufhi, dtimlo, dunuse, dbytlo, dbythi, daux1,  daux2

io_get_wifi_enabled_table:
        .byte $70, $01, $ea, $40, <wifi_enabled, >wifi_enabled, $0f, $00, $01, $00, $00, $00
