        .export     _edit_hosts_entry

        .import     pushax, pusha
        .import     _edit_line
        .import     s_empty
        .import     fuji_hostslots
        .import     mh_host_selected
        .import     _fuji_put_host_slots
        .import     get_scrloc
        .import     get_to_current_hostslot
        .import     put_s_p1p4
        .import     pushax

        .include    "zp.inc"
        .include    "atari.inc"
        .include    "macros.inc"
        .include    "fujinet-fuji.inc"
        .include    "fn_data.inc"

; void edit_hosts_entry()
;
; user input in current hosts entry

; ptr1,ptr4
.proc _edit_hosts_entry
        ; get screen location for current edit position
        ldx     #SL_EDIT_X
        lda     mh_host_selected
        clc
        adc     #SL_Y
        tay
        jsr     get_scrloc  ; ptr4 set to screen location

        ; get pointer to the string for this host slot into ptr1
        jsr     get_to_current_hostslot

        pushax  ptr1                    ; hostname string location
        pushax  ptr4                    ; scr location
        lda     #.sizeof(HostSlot)
        jsr     _edit_line
        pha                             ; save the return value for now until we've decided if we need to print empty string

        ; show empty if there is no string
        jsr     get_to_current_hostslot ; reset ptr1 to host slot string
        ldy     #$00
        lda     (ptr1), y
        bne     not_empty                ; it was not empty, so skip printing <Empty>

        mwa     #s_empty, ptr1
        jsr     put_s_p1p4

:not_empty:
        pla                             ; restore return value from edit
        ; if A is 0, don't save
        beq     no_save
        pushax  #fuji_hostslots
        ; setax    #$08 ; not required on atari
        jmp     _fuji_put_host_slots

no_save:
        rts
.endproc
