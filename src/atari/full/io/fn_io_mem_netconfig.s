        .export     fn_io_netconfig

        .include    "fn_io.inc"

.segment "BUFFER"
fn_io_netconfig:      .res .sizeof(NetConfig)
