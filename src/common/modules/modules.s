        .export     mod_table, mod_current
        .import     mod_init, mod_hosts, mod_devices, mod_wifi, mod_info, mod_done
        .include    "fn_mods.inc"

; -------------------------------------------------------------------------------
.rodata

; address table of routine to fetch data for current state.
; using Stack Based dispatch with RTS, so need to subtract 1 from addresses.
; see https://www.nesdev.org/wiki/Jump_table


mod_table:
        .addr (mod_hosts - 1)
        .addr (mod_devices - 1)
        .addr (mod_wifi - 1)
        .addr (mod_info - 1)
        .addr (mod_done - 1)
        .addr (mod_init - 1)

; -------------------------------------------------------------------------------
.data
; current module index, each module changes this depending on interaction within the module
; e.g. moving right or left
mod_current:    .byte Mod::init