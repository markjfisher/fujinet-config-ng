        .export     save_device_choice
        .export     sdc_args

        .import     _fuji_close_directory
        .import     _fuji_get_device_slots
        .import     _fuji_put_device_slots
        .import     _fuji_set_device_filename
        .import     fuji_buffer
        .import     fuji_deviceslots
        .import     mh_host_selected
        .import     pusha
        .import     pushax

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fujinet-fuji.inc"
        .include    "fn_data.inc"
        .include    "args.inc"

; void save_device_choice(uint8_t mode, uint8_t device_slot)
;
; the filename must be set into fuji_buffer before coming into here
.proc save_device_choice
        lda     sdc_args+SaveDeviceChoiceArgs::mode
        clc
        adc     #$01
        sta     tmp1                    ; mode 1 based

        ; set the device filename
        jsr     pusha                   ; save mode read/write mode
        pusha   mh_host_selected        ; host_slot
        pusha   sdc_args+SaveDeviceChoiceArgs::device_slot
        setax   #fuji_buffer
        jsr     _fuji_set_device_filename

        ; write it to the deviceslots memory
        mwa     #fuji_deviceslots, ptr1
        ldx     sdc_args+SaveDeviceChoiceArgs::device_slot
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
        lda     tmp1
        ldy     #DeviceSlot::mode
        sta     (ptr1), y

        ; Save everything
        pushax  #fuji_deviceslots
        ; setax    #$08 ; not required on atari
        jsr     _fuji_put_device_slots

        ; read the device slots back so screen repopulates
        pushax  #fuji_deviceslots
        ; setax    #$08 ; not required on atari
        jsr     _fuji_get_device_slots

        jmp     _fuji_close_directory
        ; implicit rts

.endproc

.segment "BANK"
sdc_args:       .tag SaveDeviceChoiceArgs
