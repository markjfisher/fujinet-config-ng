        .export     _mh_display_hosts

        .import     show_list
        .import     sl_callback
        .import     sl_max_cnt
        .import     sl_size
        .import     sl_str_loc

        .import     fuji_hostslots
        .import     mod_hosts_show_list_num

        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"

.proc _mh_display_hosts
        mwa     #mod_hosts_show_list_num, sl_callback
        mva     #MAX_HOSTS, sl_max_cnt
        mva     #.sizeof(HostSlot), sl_size
        mwa     #fuji_hostslots, sl_str_loc
        jmp     show_list
.endproc