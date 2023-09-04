        .export     mod_hosts_show_list_num

        .import     sl_list_num

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"

.proc mod_hosts_show_list_num
        ; A is index, ptr4 is screen location
        ; set sl_list_num to display the current list number.
        ; values all start at 0 (spaces), we only need to set 3rd char to the current index
        adc     #$11                   ; screen code for "1", add the index (0 based) to get digit to display
        ldy     #$02
        sta     (ptr4), y
        rts
.endproc