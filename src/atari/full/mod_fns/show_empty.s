        .export     _show_empty

        .import     cng_gotoxy
        .import     cng_cputs
        .import     _gotoxy
        .import     _cputs
        .import     pusha
        .import     _es_params
        .import     _s_empty

        .include    "edit_string.inc"
        .include    "macros.inc"


.segment "CODE2"

; void show_empty()
_show_empty:
        ; gotoxy(es_params.x_loc, es_params.y_loc)
        pusha   _es_params+edit_string_params::x_loc
        lda     _es_params+edit_string_params::y_loc
        jsr     cng_gotoxy

        ; cputs(s_empty)
        setax   #_s_empty
        jmp     cng_cputs
