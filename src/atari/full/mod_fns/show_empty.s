        .export     _show_empty

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
        ldx     #0
        jsr     _gotoxy

        ; cputs(s_empty)
        setax   #_s_empty
        jmp     _cputs
