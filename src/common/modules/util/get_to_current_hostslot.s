        .export     get_to_current_hostslot

        .import     fn_io_hostslots
        .import     mh_host_selected

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fn_io.inc"

.proc get_to_current_hostslot
        mwa     #fn_io_hostslots, ptr1
        ldx     mh_host_selected
        beq     over_inc
:       adw     ptr1, #.sizeof(HostSlot)
        dex
        bne     :-
over_inc:
        rts
.endproc