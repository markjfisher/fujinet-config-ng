        .export     _mi_display_prefs

        .include    "zp.inc"
        .include    "macros.inc"

.proc _mi_display_prefs

        ; show:
        ;  colour (0-F), darkness (0-F)
        ;  bar: conn, (0-FF), disconn (0-FF), copy (0-FF)

        ; we will allow the bar to show on the 5 values, and then popup to edit each one.
        ; so we need a generic key/value showing, and then those in a 

        rts
.endproc