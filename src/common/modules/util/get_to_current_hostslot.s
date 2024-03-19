        .export     get_to_current_hostslot

        .import     fuji_hostslots
        .import     mh_host_selected

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fujinet-fuji.inc"

.proc get_to_current_hostslot
        mwa     #fuji_hostslots, ptr1
        ldx     mh_host_selected
        beq     over_inc
:       adw     ptr1, #.sizeof(HostSlot)
        dex
        bne     :-
over_inc:
        rts
.endproc