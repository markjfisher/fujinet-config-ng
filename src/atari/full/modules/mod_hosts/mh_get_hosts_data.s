        .export     _mh_get_hosts_data

        .import     _fn_io_get_host_slots
        .import     fn_io_hostslots
        .import     mh_is_hosts_data_fetched

        .include    "fn_macros.inc"

.proc _mh_get_hosts_data
        lda     mh_is_hosts_data_fetched
        bne     :+

        setax   #fn_io_hostslots
        jsr     _fn_io_get_host_slots
        mva     #$01, mh_is_hosts_data_fetched

:       rts
.endproc