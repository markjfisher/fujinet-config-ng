        .export     _mh_display_hosts

        .import     fn_io_hostslots
        .import     mod_hosts_show_list_num
        .import     pusha
        .import     pushax
        .import     show_list

        .include    "fc_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"

.proc _mh_display_hosts
        pushax  #mod_hosts_show_list_num
        pusha   #MAX_HOSTS
        pusha   #.sizeof(HostSlot)
        setax   #fn_io_hostslots
        jmp     show_list
.endproc