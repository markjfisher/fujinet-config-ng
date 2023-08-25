        .export     mod_devices_show_list_num

        .import     sl_list_num
        .import     fn_io_deviceslots
        .import     debug

        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_data.inc"

.proc mod_devices_show_list_num
        ; print a string like "2 1R ", to represent host_slot, index, R or W
        sta     tmp1            ; keep the index (0 based)
        tax

        mwa     #fn_io_deviceslots, ptr2
        ; move to x'th DeviceSlot
        cpx     #$00
        beq     ds_0
:       adw1    ptr2, #.sizeof(DeviceSlot)
        dex
        bne     :-
ds_0:
        ; get first 3 bytes of the DeviceSlot
        ldy     #$00
        mva     {(ptr2), y}, tmp2       ; host slot
        iny
        mva     {(ptr2), y}, tmp3       ; mode
        iny
        mva     {(ptr2), y}, tmp4       ; first byte 

        ; put the list number onto screen
        lda     tmp1
        clc
        adc     #FNS_N2C+1              ; use constant to make this device independent
        ldy     #$02                    ; digit for list number
        sta     (ptr4), y

        ; we can skip setting values if the drive slot is empty
        lda     tmp4
        beq     out

        ; not empty, so put the hostslot+1 and mode into chars 0,3
        lda     tmp2
        adc     #FNS_N2C+1      ; screen code of host slot+1
        ldy     #$00            ; first char
        sta     (ptr4), y

        dec     tmp3            ; reduce from 1,2 to 0,1
        lda     tmp3
        ; 1 for R, 2 for W. Convert to chars R/W
        beq     m_r
        lda     #FNS_C_W        ; 'W' internal code
        bne     :+
m_r:    lda     #FNS_C_R        ; 'R' internal code

:       ldy     #$03
        sta     (ptr4), y

out:
        rts
.endproc