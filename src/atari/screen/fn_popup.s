        .export     _fn_popup


        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"

; void fn_popup(char *msg, void *selected)
.proc _fn_popup


        rts
.endproc