        .export     _dev_highlight_host
        .import     _host_selected, _bar_show

.proc _dev_highlight_host
        lda     _host_selected
        jsr     _bar_show
        rts
.endproc