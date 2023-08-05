        .export     vbl_main
        .include    "atari.inc"
        .include    "fn_macros.inc"

.proc   vbl_main
        plr

        ; update the clock, so we can do timed stuff
        inc     RTCLOK+2
        bne     out
        inc     RTCLOK+1
        bne     out
        inc     RTCLOK

out:
        rti

.endproc