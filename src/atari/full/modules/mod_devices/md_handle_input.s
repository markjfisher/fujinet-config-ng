        .export     _md_handle_input

        .import     _fn_io_get_device_slots
        .import     _fn_io_set_device_filename
        .import     _kb_global
        .import     _scr_highlight_line
        .import     fn_io_buffer
        .import     fn_io_deviceslots
        .import     kb_current_line
        .import     md_device_selected
        .import     mh_host_selected
        .import     pusha
        .import     pushax

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_data.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

.proc _md_handle_input
        mva     md_device_selected, kb_current_line

        pusha   #7              ; only 8 entries on screen
        pusha   #Mod::hosts     ; previous
        pusha   #Mod::wifi      ; next
        pushax  #md_device_selected   ; our current device
        setax   #md_kb_handler
        jmp     _kb_global          ; rts from this will drop out of module

.endproc


.proc md_kb_handler
; -------------------------------------------------
; E - Eject Device Slot

        cmp     #'E'
        bne     not_eject

        ; eject highlighted entry, which involves setting device slot to empty string and put/get device slots
        ; new version is just save device file name with no value
        lda     #$00
        sta     fn_io_buffer
        pusha   #$00
        pusha   mh_host_selected
        pusha   md_device_selected
        setax   #fn_io_buffer
        jsr     _fn_io_set_device_filename

        ; read the device slots back so screen repopulates
        setax   #fn_io_deviceslots
        jsr     _fn_io_get_device_slots

        ldx     #KBH::EXIT
        rts

not_eject:

; -------------------------------------------------
; 1-8
        cmp     #'1'
        bcs     one_or_over
        bcc     not_1_8
one_or_over:
        cmp     #'9'
        bcs     not_1_8

        ; in range 1-8
        sec
        sbc     #'1' ; convert from ascii for 1-8 to index 0-7
        sta     md_device_selected
        sta     kb_current_line         ; tell global kb handler the latest value too
        jsr     _scr_highlight_line
        ldx     #KBH::RELOOP
        rts

not_1_8:
        ldx     #KBH::NOT_HANDLED
        rts

.endproc