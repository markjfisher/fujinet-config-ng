        .export _mx_init_screen

        .import     _clr_scr_all
        .import     _scr_clr_highlight

.proc _mx_init_screen
        jsr     _clr_scr_all
        jmp     _scr_clr_highlight
.endproc