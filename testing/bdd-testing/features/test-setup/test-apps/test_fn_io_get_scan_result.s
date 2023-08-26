        .export         _main, t_network_index, t_ssidinfo_loc
        .import         _fn_io_get_scan_result, pusha

        .include        "fn_macros.inc"

.proc _main
        pusha   t_network_index
        setax   t_ssidinfo_loc

        jsr     _fn_io_get_scan_result
        rts
.endproc

.bss
t_network_index:  .res 1
t_ssidinfo_loc:   .res 2