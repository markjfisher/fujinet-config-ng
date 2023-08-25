        .export     mod_files

        .import     _fn_clrscr, _fn_clr_highlight
        .import     _fn_put_help, _fn_put_status
        .import     files_simple
        .import     pusha
        .import     mf_s1, mf_h1, mf_h3

        .include    "fn_macros.inc"

.proc mod_files
        jsr     _fn_clrscr
        put_status #0, #mf_s1
        put_help   #1, #mf_h1
        put_help   #3, #mf_h3

        jsr     _fn_clr_highlight
        jmp     files_simple
.endproc
