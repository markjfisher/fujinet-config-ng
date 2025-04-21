        .export     print_dir_info

        .import    _put_s
        .import    ellipsize
        .import    fn_dir_filter
        .import    fn_dir_path
        .import    get_to_current_hostslot
        .import    mf_ellipsize
        .import    mf_filter
        .import    mf_host
        .import    mf_path
        .import    pusha
        .import    pushax

        .include    "zp.inc"
        .include    "macros.inc"

.segment "CODE2"

print_dir_info:
        ; use 3 lines at the top of screen to display the Host/Filter/Path
        ; titles
        put_s   #0, #0, #mf_host
        put_s   #0, #1, #mf_filter
        put_s   #0, #2, #mf_path

        ; print values
        ; host
        jsr     get_to_current_hostslot         ; sets ptr1 to correct hostslot
        put_s   #5, #0, ptr1

        ; Filter
        lda     fn_dir_filter
        beq     :+
        put_s   #5, #1, #fn_dir_filter

:
        setax   #32             ; max length, including the 0 terminator
        jsr     pusha           ; save as parameter for ellipsize
        pushax  #mf_ellipsize   ; dst
        setax   #fn_dir_path    ; src

        jsr     ellipsize

        ; print the ellipsized string
        put_s   #5, #2, #mf_ellipsize

        rts
