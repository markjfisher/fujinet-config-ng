        .export     mod_done, done_is_booting
        .import     pusha, pushax
        .import     mod_current, _fn_io_set_boot_config, mod_kb, _fn_clrscr, current_line, _dev_highlight_line, _fn_mount_and_boot
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

        ; booting chosen, go to mount/boot
        jsr     _fn_mount_and_boot
        ; if there was an error, it will come back here, else it would have cold start
        ; we rts out which will cause the mod screen to be reload, but first need to turn off booting, else the above will loop.
        mva     #$00, done_is_booting
        rts

not_booting:
        ; module shown, let user choose what they want to do

        ; highlight current option
        mva     done_selected, current_line
        jsr     _dev_highlight_line

        ; handle keyboard
        pusha   #$f             ; all the lines!
        pusha   #Mod::devices   ; previous
        pusha   #Mod::hosts     ; next
        pushax  #done_selected  ; our current selection
        setax   #mod_done_kb
        jmp     mod_kb          ; rts from this will drop out of module

        ;; This was done() from C version. when do we do this?
        ; lda     #$00    ; disable config
        ; jsr     _fn_io_set_boot_config
        ; mva     #Mod::exit, mod_current

display_done:
        ; need some screen stuff here
        rts

mod_done_kb:
        rts

.endproc

.bss
done_is_booting:        .res 1

.data
done_selected:          .byte 0