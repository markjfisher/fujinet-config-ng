        .export     mod_done, done_is_booting
        .import     pusha, pushax
        .import     mod_current, _fn_io_set_boot_config, kb_global, _fn_clrscr, current_line, _fn_highlight_line, _fn_mount_and_boot
        .import     _fn_put_status
        .import     _fn_clr_highlight
        .import     _fn_put_s
        .import     _fn_put_help

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

; This is the last module that shows anything.
; A chance to exit, boot etc without always pressing OPTION
.proc mod_done
        jsr     _fn_clrscr
        jsr     _fn_clr_highlight

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
        put_status #0, #mx_s1
        put_status #2, #mx_s3
        put_help #2, #mx_h1

        put_s   #7, #3, #mx_m1
        put_s   #13, #4, #mx_m2

        ; highlight current option
        ; mva     done_selected, current_line
        ; jsr     _fn_highlight_line

        ; handle keyboard
        pusha   #$00            ; no lines (set to $f for all lines) - stops the highlight from moving
        pusha   #Mod::devices   ; previous
        pusha   #Mod::hosts     ; next
        pushax  #done_selected  ; our current selection
        setax   #mod_done_kb
        jmp     kb_global          ; rts from this will drop out of module

mod_done_kb:
        rts
.endproc

.bss
done_is_booting:        .res 1

.data
done_selected:          .byte 0

.segment "SCREEN"
mx_s1:
                INVERT_ATASCII
                .byte "INFO / EXIT", 0

mx_s3:
                NORMAL_CHARMAP
                .byte $81, $1e, $82
                INVERT_ATASCII
                .byte "Drive Slots            Host List"
                NORMAL_CHARMAP
                .byte $81, $1f, $82, 0

mx_h1:          
                NORMAL_CHARMAP
                .byte $81, "OPTION", $82
                INVERT_ATASCII
                .byte "Mount Disks and Boot!", 0

                NORMAL_CHARMAP
mx_m1:          .byte "Config-NG by Fenrock", 0
mx_m2:          .byte "Version: 0.8.0", 0
