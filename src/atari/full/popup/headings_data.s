        .export     sds_msg

        .include    "fn_macros.inc"

; ------------------------------------------------------------------
; Select Device Slot data
; ------------------------------------------------------------------

.segment "SCREEN"

        INVERT_ATASCII
sds_msg:
        .byte "   Select Device Slot   "
        NORMAL_CHARMAP
