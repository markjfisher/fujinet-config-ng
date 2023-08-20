        .export     run_module
        .export     mod_table, mod_current
        .import     mod_init, mod_hosts, mod_devices, mod_wifi, mod_info, mod_done
        .import     mod_files, mod_sel_host_slot, mod_select_device_slot

        .include    "fn_mods.inc"

; executes code for the current module
.proc run_module
        ; stack based dispatch to jump to appropriate module handler
        lda     mod_current
        asl
        tax
        lda     mod_table+1, x
        pha
        lda     mod_table, x
        pha
        rts     ; JMP! rts in the module will return to previous caller
.endproc

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
        .addr (mod_files - 1)
        .addr (mod_init - 1)

; -------------------------------------------------------------------------------
.data
; current module index, each module changes this depending on interaction within the module
; e.g. moving right or left with cursor keys
mod_current:    .byte Mod::init
