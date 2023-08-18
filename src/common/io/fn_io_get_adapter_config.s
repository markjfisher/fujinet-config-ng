        .export         _fn_io_get_adapter_config
        .import         _fn_io_copy_dcb, _fn_io_dosiov

        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "fn_data.inc"

; void _fn_io_get_adapter_config(void *adapterConfig)
;
; caller needs to supply the location to write the config
.proc _fn_io_get_adapter_config
        ; store the memory location of the adapter config
        getax   adapter_location

        setax   #t_io_get_adapter_config
        jsr     _fn_io_copy_dcb

        ; set the memory address for DCB to write to and call SIOV
        mwa     adapter_location, IO_DCB::dbuflo
        jmp     _fn_io_dosiov

.endproc

.bss
adapter_location:       .res 2

.rodata
.define ACsz .sizeof(AdapterConfig)

t_io_get_adapter_config:
        .byte $e8, $40, $ff, $ff, $0f, $00, <ACsz, >ACsz, $00, $00
