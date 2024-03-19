        .export     _mh_display_hosts

        .import     fuji_hostslots
        .import     mod_hosts_show_list_num
        .import     pusha
        .import     pushax
        .import     show_list

        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"

.proc _mh_display_hosts
        pushax  #mod_hosts_show_list_num
        pusha   #MAX_HOSTS
        pusha   #.sizeof(HostSlot)
        setax   #fuji_hostslots
        jmp     show_list
.endproc