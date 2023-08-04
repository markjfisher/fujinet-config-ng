        .export     mod_hosts
        .import     _fn_io_get_host_slots, fn_io_hostslots
        .import     pusha, pushax, put_digit, put_s, clrscr, put_help
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"

;  handle HOST LIST
.proc mod_hosts
        jsr     clrscr
        setax   #s_hosts_h1
        ldy     #0
        jsr     put_help

        setax   #s_hosts_h2
        ldy     #1
        jsr     put_help

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
        mva     #$00, host_index

:       lda     host_index
        clc
        adc     #$01
        pha                     ; save current y coord
        tay                     ; y coord

        ldx     #$01            ; x coord
        lda     host_index      ; digit
        adc     #$01            ; index is 0 based, need to increment for screen. C is clear already
        jsr     put_digit

        ; --------- print host string
        pushax  ptr1

        ldx     #$03
        pla                     ; restore current y
        tay
        jsr     put_s

        ; repeat for all 8 hosts
        adw     ptr1, #.sizeof(HostSlot)
        inc     host_index
        lda     host_index
        cmp     #8
        bne     :-

        ; we will grab keyboard now...
:       jmp :-

        rts
.endproc

.rodata
s_hosts_h1:     SCREENCODE_INVERT_40_SPACES

                SCREENCODE_INVERT_CHARMAP
s_hosts_h2:     .byte "        Press keys to do stuff!         "
                NORMAL_CHARMAP

.bss
host_index:     .res 1

.data
hosts_fetched:  .byte 0
