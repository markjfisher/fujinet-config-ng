; config.s
;

    .export     start
    .import     _setup_screen

.proc start
    ; do we need to worry about an init, and setting up the bss data here?
    jsr _setup_screen

l:  jmp l
    rts
.endproc
