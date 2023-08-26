        .export         _main, t_netconfig_loc
        .import         _fn_io_get_ssid

        .include        "fn_macros.inc"

.proc _main
        setax   t_netconfig_loc

        jsr     _fn_io_get_ssid
        rts
.endproc

.bss
t_netconfig_loc:   .res 2