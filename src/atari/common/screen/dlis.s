        .export     dli
        .export     enable_dli
        .export     restore_system_dli

        .import     kb_idle_counter

        .include    "atari.inc"
        .include    "macros.inc"

; simply increment the kb idle counter so we can animate selections
; the kb scanning routine will reset values
dli:
        inc     kb_idle_counter
        rti


enable_dli:
        mva     #$40, NMIEN     ; disable dli while we install ours
        mwa     VDSLST, dli_old_vector
        mwa     #dli, VDSLST
        mva     #$c0, NMIEN     ; turn it on again with our routine enabled
        rts


restore_system_dli:
        mva     #$40, NMIEN                 ; disable dli
        mwa     dli_old_vector, VDSLST      ; restore old vector
        rts

.segment "BANK"
dli_old_vector:     .res 2
