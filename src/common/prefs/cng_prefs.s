        .export     _cng_prefs
        .export     _keys_buffer

        .include    "cng_prefs.inc"

.segment "BANK"
_cng_prefs:   .tag CNG_PREFS_DATA
_keys_buffer: .res 66
