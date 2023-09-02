        .export     _fn_edit_hosts_entry

        .import     pushax, pusha
        .import     _fn_edit
        .import     fn_io_hostslots
        .import     host_selected
        .import     _fn_io_put_host_slots
        .import     fn_get_scrloc
        .import     get_to_current_hostslot

        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"

; void dev_edit_hosts_entry()
;
; user input in current hosts entry
.proc _fn_edit_hosts_entry
        ; get screen location for current edit position
        ldx     #SL_EDIT_X
        lda     host_selected
        clc
        adc     #SL_Y
        tay
        jsr     fn_get_scrloc  ; ptr4 set to screen location

        ; get pointer to the string for this host slot into ptr1
        jsr     get_to_current_hostslot

        pushax  ptr1    ; hostname string location
        pushax  ptr4    ; scr location
        pusha   #.sizeof(HostSlot)
        lda     #$01    ; show empty on pressing ESC for empty string
        jsr     _fn_edit

        ; if A is 0, don't save
        beq     no_save
        setax   #fn_io_hostslots
        jmp     _fn_io_put_host_slots

no_save:
        rts
.endproc
