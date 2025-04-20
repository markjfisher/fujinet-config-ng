        .export     _edit_hosts_entry

        .import     _edit_string
        .import     _es_params
        .import     _fuji_put_host_slots
        .import     _show_empty
        .import     fuji_hostslots
        .import     get_to_current_hostslot
        .import     mh_host_selected
        .import     pushax

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
        jsr     get_to_current_hostslot
        mwa     ptr1, {_es_params + edit_string_params::initial_str}
        
        lda     #.sizeof(HostSlot)
        sta     _es_params + edit_string_params::max_length
        sta     _es_params + edit_string_params::viewport_width

        lda     #$00
        sta     _es_params + edit_string_params::max_length + 1
        sta     _es_params + edit_string_params::is_password
        sta     _es_params + edit_string_params::is_number

        lda     #SL_EDIT_X + 1
        sta     _es_params + edit_string_params::x_loc

        lda     mh_host_selected
        clc
        adc     #SL_Y
        sta     _es_params + edit_string_params::y_loc

        jsr     _edit_string
        pha                             ; save the return value for now until we've decided if we need to print empty string

        ; show empty if there is no string
        jsr     get_to_current_hostslot ; reset ptr1 to host slot string
        ldy     #$00
        lda     (ptr1), y
        bne     not_empty                ; it was not empty, so skip printing <Empty>

        jsr     _show_empty

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
