        .export     _mi_handle_input

        .import     _kb_global
        .import     mi_selected
        .import     pusha
        .import     pushax

        .include    "fc_macros.inc"
        .include    "fc_mods.inc"
        .include    "fc_zp.inc"

.proc _mi_handle_input
        ; handle keyboard
        pusha   #$00            ; no lines
        pusha   #Mod::wifi      ; previous
        pusha   #Mod::hosts     ; next
        pushax  #mi_selected    ; our current selection
        setax   #mi_kbh
        jmp     _kb_global      ; rts from this will drop out of module
.endproc

.proc mi_kbh
        rts
.endproc