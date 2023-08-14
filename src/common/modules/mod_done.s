        .export     mod_done, done_is_booting
        .import     pusha, pushax
        .import     mod_current, _fn_io_set_boot_config, kb_global, _fn_clrscr, current_line, _fn_highlight_line, _fn_mount_and_boot
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

; This is the last module that shows anything.
; A chance to exit, boot etc without the 
.proc mod_done
        jsr     _fn_clrscr
        jsr     display_done

        lda     done_is_booting
        beq     not_booting

        ; booting chosen, go to mount/boot - device specific
        jsr     _fn_mount_and_boot
        ; if there was an error, it will come back here, else it would have cold start
        ; we rts out which will cause the mod screen to be reload, but first need to turn off booting, else the above will loop.
        mva     #$00, done_is_booting
        rts

not_booting:
        ; module shown, let user choose what they want to do

        ; highlight current option
        mva     done_selected, current_line
        jsr     _fn_highlight_line

        ; handle keyboard
        pusha   #$f             ; all the lines!
        pusha   #Mod::devices   ; previous
        pusha   #Mod::hosts     ; next
        pushax  #done_selected  ; our current selection
        setax   #mod_done_kb
        jmp     kb_global          ; rts from this will drop out of module

display_done:
        ; need some screen stuff here, display 
        rts

mod_done_kb:
        rts

.endproc

.bss
done_is_booting:        .res 1

.data
done_selected:          .byte 0