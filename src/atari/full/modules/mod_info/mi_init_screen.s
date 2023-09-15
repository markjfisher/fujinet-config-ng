        .export _mi_init_screen

        .import     _clr_help
        .import     _clr_src_with_separator
        .import     _clr_status
        .import     _put_help
        .import     _put_s
        .import     _put_status
        .import     _scr_clr_highlight
        .import     mx_h1
        .import     mx_m1
        .import     mx_m2
        .import     mx_s1
        .import     mx_s2
        .import     pusha

        .include    "fc_macros.inc"
        .include    "fc_zp.inc"

.proc _mi_init_screen
        jsr     _scr_clr_highlight
        jsr     _clr_help
        jsr     _clr_status
        lda     #9                     ; print a separator at this line
        jsr     _clr_src_with_separator

        put_status #0, #mx_s1
        put_status #1, #mx_s2
        put_help   #0, #mx_h1

        put_s      #7, #3, #mx_m1
        put_s      #13, #4, #mx_m2
        rts
.endproc