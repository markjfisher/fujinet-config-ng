        .export fuji_deviceslots
        .include    "fujinet-fuji.inc"

; 304 bytes, but it stops us doing SIO everytime enter the devices module screen
.segment "BUFFER"
fuji_deviceslots:      .res 8 * .sizeof(DeviceSlot)

