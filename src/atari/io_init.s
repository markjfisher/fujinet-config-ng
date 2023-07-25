        .export     io_init
        .include    "atari.inc"
        .include    "../inc/macros.inc"

; void io_init()
.proc io_init
        mva #$ff, NOCLIK
        mva #$00, SHFLOK
        mva #$9f, COLOR0
        mva #$0f, COLOR1
        mva #$90, COLOR2
        sta       COLOR4
        mva #$01, COLDST
        mva #$00, SDMCTL
        rts
.endproc