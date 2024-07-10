        .export     _md_handle_input

        .import     _fuji_get_device_slots
        .import     _fuji_set_device_filename
        .import     kb_global
        .import     _scr_highlight_line
        .import     fuji_deviceslots
        
        .import     kb_current_line
        .import     kb_max_entries
        .import     kb_prev_mod
        .import     kb_next_mod
        .import     kb_mod_current_line_p
        .import     kb_mod_proc

        .import     md_device_selected
        .import     mh_host_selected
        .import     pusha
        .import     pushax

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fn_data.inc"
        .include    "fujinet-fuji.inc"
        .include    "modules.inc"

.proc _md_handle_input
        mva     md_device_selected, kb_current_line

        mva     #$07, kb_max_entries
        mva     #Mod::hosts, kb_prev_mod
        mva     #Mod::wifi, kb_next_mod
        mwa     #md_device_selected, kb_mod_current_line_p
        mwa     #md_kb_handler, kb_mod_proc

        jmp     kb_global          ; rts from this will drop out of module

.endproc


.proc md_kb_handler
; -------------------------------------------------
; E - Eject Device Slot

        cmp     #'E'
        bne     not_eject

        ; eject highlighted entry by saving device file name with no value
        pusha   #$00
        pusha   mh_host_selected
        pusha   md_device_selected
        setax   #empty_string
        jsr     _fuji_set_device_filename

        ; read the device slots back so screen repopulates
        pushax  #fuji_deviceslots
        ; setax    #$08 ; not required on atari
        jsr     _fuji_get_device_slots

        ldx     #KBH::EXIT
        rts

empty_string:
        .byte   $00

not_eject:

; -------------------------------------------------
; 1-8
        cmp     #'1'
        bcs     one_or_over
        bcc     not_1_max

one_or_over:
        cmp     #('1' + MAX_DEVICES)
        bcs     not_1_max

        ; in range 1-8
        sec
        sbc     #'1' ; convert to 0 based index
        sta     md_device_selected
        sta     kb_current_line         ; tell global kb handler the latest value too
        ; jsr     _scr_highlight_line
        ldx     #KBH::RELOOP
        rts

not_1_max:
        ldx     #KBH::NOT_HANDLED
        rts

.endproc