        .export     mod_hosts
        .import     _fn_io_get_host_slots, fn_io_hostslots
        .include    "zeropage.inc"
        .include    "fn_macros.inc"

;  handle HOST LIST
.proc mod_hosts

        ; do we have hosts data read?
        lda     hosts_fetched
        bne     over

        jsr     _fn_io_get_host_slots
        mva     #$01, hosts_fetched

over:
        jsr     display_hosts
        rts

display_hosts:
        ; fn_io_hostslots is an array of 8 strings up to 32 bytes each, representing the strings of the hosts to display
        ldx     #$00


.endproc

.data
hosts_fetched:  .byte 0
