        .export         _main, fn_get_scrloc
        .export         t_loc, t_x, t_y, t_c, t_save_x, t_save_y
        .import         fn_put_c

        .include        "fn_macros.inc"
        .include        "fn_io.inc"
        .include        "zeropage.inc"

.proc _main
        ; call the function under test
        ldx     t_x
        ldy     t_y
        lda     t_c
        jmp     fn_put_c
.endproc

; -----------------------------------------
; mock the external functions
.proc fn_get_scrloc
        ; capture x/y to ensure we called with correct values
        stx     t_save_x
        sty     t_save_y
        ; set the location for the given x/y coordinate to be our t_loc
        mwa     #t_loc, ptr4
        rts
.endproc

.bss
t_loc:      .res 1
t_x:        .res 1 ; location for test to set x
t_y:        .res 1 ; location for test to set y
t_c:        .res 1 ; location for test to set c
t_save_x:   .res 1 ; value to prove we called with correct x
t_save_y:   .res 1 ; value to prove we called with correct y