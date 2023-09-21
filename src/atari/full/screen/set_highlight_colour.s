        .export     _set_highlight_colour

        .import     _bar_setcolor
        .import     fc_connected
        .import     mf_copying

.proc _set_highlight_colour
        ; are we mid-copy?
        lda     mf_copying
        beq     :+

        lda     #$66            ; blue
        bne     @set

        ; -----------------------------------
        ; set the color based on connected flag
:       lda     fc_connected
        beq     :+

        ; yes, we're connected, make a nice green
        lda     #$b4
        .byte   $2c         ; bit, mask out next 2 bytes

        ; no, dirty un-connected machine. make it red
:       lda     #$33

@set:
        jmp     _bar_setcolor

.endproc