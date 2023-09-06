        .export     mod_done, is_booting
        .import     pusha, pushax
        .import     mod_current, _fn_io_set_boot_config, _kb_global, _clr_scr_all, kb_current_line, _scr_highlight_line, _mount_and_boot
        .import     _put_help
        .import     _put_status
        .import     _scr_clr_highlight
        .import     _put_s
        .import     mx_h1, mx_s1, mx_s3, mx_m1, mx_m2

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

; This is the last module that shows anything.
; A chance to exit, boot etc without always pressing OPTION
.proc mod_done
        jsr     _clr_scr_all
        jsr     _scr_clr_highlight

        lda     is_booting
        beq     not_booting

        ; booting chosen, go to mount/boot - device specific
        jsr     _mount_and_boot
        ; if there was an error, it will come back here, else it would have cold start
        ; we rts out which will cause the mod screen to be reload, but first need to turn off booting, else the above will loop.
        mva     #$00, is_booting
        rts

not_booting:
        ; module shown, let user choose what they want to do
        put_status #0, #mx_s1
        put_status #1, #mx_s3
        put_help   #0, #mx_h1

        put_s      #7, #3, #mx_m1
        put_s      #13, #4, #mx_m2

        ; highlight current option
        ; mva     done_selected, kb_current_line
        ; jsr     _scr_highlight_line

        ; handle keyboard
        pusha   #$00            ; no lines (set to $f for all lines) - stops the highlight from moving
        pusha   #Mod::wifi      ; previous
        pusha   #Mod::hosts     ; next
        pushax  #done_selected  ; our current selection
        setax   #mod_done_kb
        jmp     _kb_global          ; rts from this will drop out of module

mod_done_kb:
        rts
.endproc

.bss
is_booting:        .res 1

.data
done_selected:          .byte 0
