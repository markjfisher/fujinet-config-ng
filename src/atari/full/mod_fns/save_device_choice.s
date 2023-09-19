        .export     save_device_choice

        .import     _fn_io_close_directory
        .import     _fn_io_get_device_slots
        .import     _fn_io_put_device_slots
        .import     _fn_io_set_device_filename
        .import     fn_io_buffer
        .import     fn_io_deviceslots
        .import     mh_host_selected
        .import     popa
        .import     pusha

        .include    "fc_zp.inc"
        .include    "fc_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"

; void save_device_choice(uint8_t mode, uint8_t device_slot)
;
; the filename must be set into fn_io_buffer before coming into here
.proc save_device_choice
        sta     tmp1                    ; device slot, 0 based
        jsr     popa                    ; mode, currently 0 based, but need it 1 based
        clc
        adc     #$01
        sta     tmp2                    ; mode 1 based

        ; set the device filename
        jsr     pusha                   ; save mode read/write mode
        pusha   mh_host_selected        ; host_slot
        pusha   tmp1                    ; device slot
        setax   #fn_io_buffer
        jsr     _fn_io_set_device_filename

        ; write it to the deviceslots memory
        mwa     #fn_io_deviceslots, ptr1
        ldx     tmp1
        beq     no_dev_add
:       adw     ptr1, #.sizeof(DeviceSlot)
        dex
        bne     :-

no_dev_add:
        ; write the host slot
        lda     mh_host_selected
        ldy     #DeviceSlot::hostSlot
        sta     (ptr1), y

        ; write the mode
        lda     tmp2
        ldy     #DeviceSlot::mode
        sta     (ptr1), y

        ; Save everything
        setax   #fn_io_deviceslots
        jsr     _fn_io_put_device_slots

        ; read the device slots back so screen repopulates
        setax   #fn_io_deviceslots
        jsr     _fn_io_get_device_slots

        jmp     _fn_io_close_directory
        ; implicit rts

.endproc
