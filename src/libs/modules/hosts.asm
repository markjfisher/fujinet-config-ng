; module: hosts
; lists hosts

        .public mod_hosts
        .extrn mod_d .word
        .reloc

mod_hosts
        mwa #hosts_data mod_d
        rts



hosts_data
    dta d'         hosts information          '
    dta d'123456789012345678901234567890123456'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'1                                  6'
    dta d'123456789012345678901234567890123456'
