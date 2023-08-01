        .export     _fn_io_init
        .include    "atari.inc"
        .include    "../inc/macros.inc"

; void _fn_io_init()
.proc _fn_io_init
        mva #$ff, NOCLIK
        mva #$00, SHFLOK

        mva #$01, COLDST
        mva #$00, SDMCTL
        rts
.endproc