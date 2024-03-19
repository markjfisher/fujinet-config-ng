        .export     fuji_hostslots

        .include    "fujinet-fuji.inc"

.segment "BUFFER"
fuji_hostslots:      .res 8 * .sizeof(HostSlot)
