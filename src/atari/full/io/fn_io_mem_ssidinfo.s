        .export     fuji_ssidinfo

        .include    "fujinet-fuji.inc"

.segment "BUFFER"
fuji_ssidinfo:      .res .sizeof(SSIDInfo)
