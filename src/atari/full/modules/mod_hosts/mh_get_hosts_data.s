        .export     _mh_get_hosts_data

        .import     _fuji_get_host_slots
        .import     fuji_hostslots
        .import     mh_is_hosts_data_fetched
        .import     pushax

        .include    "macros.inc"

.proc _mh_get_hosts_data
        lda     mh_is_hosts_data_fetched
        bne     :+

        pushax  #fuji_hostslots
        ; setax    #$08 ; not required on atari
        jsr     _fuji_get_host_slots
        mva     #$01, mh_is_hosts_data_fetched

:       rts
.endproc