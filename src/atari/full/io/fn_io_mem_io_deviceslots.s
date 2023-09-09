        .export fn_io_deviceslots
        .include    "fn_io.inc"

; 304 bytes, but it stops us doing SIO everytime enter the devices module screen
.segment "BUFFER"
fn_io_deviceslots:      .res 8 * .sizeof(DeviceSlot)

