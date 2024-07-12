        .export     _set_highlight_colour

        .import     _bar_setcolor
        .import     _cng_prefs
        .import     fc_connected
        .import     mf_copying

        .include    "cng_prefs.inc"


.proc _set_highlight_colour
        jsr     which_colour
        jmp     _bar_setcolor

which_colour:
        ; are we mid-copy?
        lda     mf_copying
        beq     :+

        ; yes, use copy colour
        lda     _cng_prefs + CNG_PREFS_DATA::bar_copy
        rts

        ; are we connected?
:       lda     fc_connected
        beq     :+

        ; yes
        lda     _cng_prefs + CNG_PREFS_DATA::bar_conn
        rts

        ; no
:       lda     _cng_prefs + CNG_PREFS_DATA::bar_disconn
        rts

.endproc