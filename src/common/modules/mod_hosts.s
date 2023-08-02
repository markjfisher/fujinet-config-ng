        .export     mod_hosts
        .import     _fn_io_get_host_slots, fn_io_hostslots, pusha, pushax, put_digit
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"

;  handle HOST LIST
.proc mod_hosts

        ; do we have hosts data read?
        lda     hosts_fetched
        bne     over

        jsr     _fn_io_get_host_slots
        mva     #$01, hosts_fetched

over:
        jsr     display_hosts
        rts

display_hosts:
        ; fn_io_hostslots is an array of 8 strings up to 32 bytes each, representing the strings of the hosts to display
        ; ptr1 points to n'th host
        mwa     #fn_io_hostslots, ptr1
        ; tmp1 is current host index
        mva     #$00, tmp1

        ; put_digit 2, 2+x, "x"
        ; --------- print digit
:       lda     #$02
        jsr     pusha

        lda     tmp1
        clc
        adc     #$02
        pha                     ; save index+2
        jsr     pusha

        lda     tmp1
        jsr     put_digit

        ; put_s 6, 2+x, "x"
        ; --------- print host string
        ; lda     #$06
        ; jsr     pusha

        ; pla                     ; restore index + 2
        ; jsr     pusha

        ; pushax  ptr1
        ; jsr     put_s

        ; repeat for all 8 hosts
        adw     ptr1, #.sizeof(HostSlot)
        inc     tmp1
        lda     tmp1
        cmp     #8
        bne     :-

        rts
.endproc

.data
hosts_fetched:  .byte 0
