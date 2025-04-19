        .export     fuji_hostslots

        .include    "fujinet-fuji.inc"

.segment "BANK"
fuji_hostslots:      .res 8 * .sizeof(HostSlot)
