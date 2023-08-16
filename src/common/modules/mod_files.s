        .export     mod_files

        .import     _fn_clrscr, _fn_clr_highlight
        .import     files_simple

.proc mod_files
        jsr     _fn_clrscr
        jsr     _fn_clr_highlight

        ; TODO: check which mode we're in, simple or block.
        ; check if we're low memory and force it to simple.
        ; otherwise if we have 4000-7fff free, we can start block reading

        ; WARNING - that's device specific stuff!

        jmp     files_simple

.endproc