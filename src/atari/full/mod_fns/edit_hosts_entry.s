        .export     _edit_hosts_entry

        .import     _edit_string
        .import     _es_params
        .import     _fuji_put_host_slots
        .import     fuji_hostslots
        .import     get_scrloc
        .import     get_to_current_hostslot
        .import     mh_host_selected
        .import     pushax
        .import     pushax, pusha
        .import     put_s_p1p4
        .import     s_empty

        .include    "atari.inc"
        .include    "edit_string.inc"
        .include    "fujinet-fuji.inc"
        .include    "fn_data.inc"
        .include    "macros.inc"
        .include    "zp.inc"

; void edit_hosts_entry()
;
; user input in current hosts entry

; ptr1,ptr4
.proc _edit_hosts_entry
        jsr     setup_ptr4
        ; ; get pointer to the string for this host slot into ptr1
        ; jsr     get_to_current_hostslot

        ; pushax  ptr1                    ; hostname string location
        ; pushax  ptr4                    ; scr location
        ; lda     #.sizeof(HostSlot)
        ; jsr     _edit_line

        jsr     get_to_current_hostslot
        lda     ptr1
        sta     _es_params + EditString::initial_str
        lda     ptr1+1
        sta     _es_params + EditString::initial_str + 1
        
        lda     #.sizeof(HostSlot)
        sta     _es_params + EditString::max_length
        sta     _es_params + EditString::viewport_width

        lda     #$00
        sta     _es_params + EditString::max_length + 1
        sta     _es_params + EditString::is_password
        sta     _es_params + EditString::is_number

        lda     #SL_EDIT_X + 1
        sta     _es_params + EditString::x_loc

        lda     mh_host_selected
        clc
        adc     #SL_Y
        sta     _es_params + EditString::y_loc

        jsr     _edit_string
        pha                             ; save the return value for now until we've decided if we need to print empty string

        ; show empty if there is no string
        jsr     get_to_current_hostslot ; reset ptr1 to host slot string
        ldy     #$00
        lda     (ptr1), y
        bne     not_empty                ; it was not empty, so skip printing <Empty>

        ; we can't rely on any of this for the empty any more, use gotoxy() and cputc... for now reset ptr4
        jsr     setup_ptr4
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

setup_ptr4:
        ; get screen location for current edit position
        ldx     #SL_EDIT_X
        lda     mh_host_selected
        clc
        adc     #SL_Y
        tay
        jmp     get_scrloc  ; ptr4 set to screen location - still need this for other screen printing!

.endproc
