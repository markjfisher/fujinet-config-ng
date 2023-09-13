        .export     _set_highlight_colour

        .import     _bar_setcolor
        .import     fc_connected

.proc _set_highlight_colour
        ; -----------------------------------
        ; set the color based on connected flag

        ; are we connected?
        lda     fc_connected
        beq     :+

        ; yes
        lda     #$b4
        .byte   $2c         ; bit, mask out next 2 bytes

        ; no
:       lda     #$33
        jmp     _bar_setcolor

.endproc