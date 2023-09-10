        .export     fn_io_ssidinfo

        .include    "fn_io.inc"

.segment "BUFFER"
fn_io_ssidinfo:      .res .sizeof(SSIDInfo)
