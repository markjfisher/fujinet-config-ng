
    .extrn mod_hosts .word
    .public mod_table, mod_d
    .reloc

; address table of routine to fetch data for current option.
; using Stack Based dispatch with RTS, so need to subtract 1 from addresses.
; see https://www.nesdev.org/wiki/Jump_table
mod_table
    dta a(mod_hosts - 1)

; location that modules will change to point to its own data
mod_d   dta a($0000)
