        .export     run_module
        .export     mod_table, mod_current
        .import     _mod_init, _mod_hosts, _mod_devices, _mod_wifi, _mod_info, _mod_boot
        .import     _mod_files, mod_sel_host_slot, mod_select_device_slot

        .include    "modules.inc"

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
        .addr (_mod_hosts - 1)
        .addr (_mod_devices - 1)
        .addr (_mod_wifi - 1)
        .addr (_mod_info - 1)
        .addr (_mod_files - 1)
        .addr (_mod_init - 1)
        .addr (_mod_boot - 1)

; -------------------------------------------------------------------------------
.data
; current module index, each module changes this depending on interaction within the module
; e.g. moving right or left with cursor keys
mod_current:    .byte Mod::init
