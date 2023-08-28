        .export     fn_io_hostslots

        .include    "fn_io.inc"

.segment "BUFFER"
fn_io_hostslots:      .res 8 * .sizeof(HostSlot)
