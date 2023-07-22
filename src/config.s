; config.s
;

    .export     start
    .import     setup_screen

.proc start
    jsr setup_screen

l:  jmp l
    rts
.endproc
