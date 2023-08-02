        .export     mod_table, mod_current
        .import     mod_hosts

; -------------------------------------------------------------------------------
.rodata

; address table of routine to fetch data for current option.
; using Stack Based dispatch with RTS, so need to subtract 1 from addresses.
; see https://www.nesdev.org/wiki/Jump_table
mod_table:  .addr (mod_hosts - 1)

; -------------------------------------------------------------------------------
.bss
; current module index
mod_current:    .res 1