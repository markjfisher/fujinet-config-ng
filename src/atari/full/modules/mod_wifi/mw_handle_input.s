        .export     _mw_handle_input

        .import     _kb_global
        .import     _scr_clr_highlight
        .import     kb_current_line
        .import     mh_host_selected
        .import     mw_selected
        .import     pusha
        .import     pushax

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc _mw_handle_input
        jsr     _scr_clr_highlight

        pusha   #0              ; no highlighting just yet
        pusha   #Mod::devices   ; prev
        pusha   #Mod::done      ; next
        pushax  #mw_selected    ; memory address of our current host so it can be updated
        setax   #mw_kb_handler  ; hosts kb handler
        jmp     _kb_global      ; rts from this will drop out of module

.endproc

.proc mw_kb_handler
        rts
.endproc
