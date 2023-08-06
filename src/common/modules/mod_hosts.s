        .export     mod_hosts, hosts_fetched
        .import     _fn_io_get_host_slots, fn_io_hostslots
        .import     pusha, pushax, _fn_put_digit, _fn_put_s, _fn_clrscr, _fn_put_help, _cgetc, _fn_put_c
        .include    "zeropage.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"

;  handle HOST LIST
.proc mod_hosts

        jsr     _fn_clrscr
        put_help 0, #s_hosts_h1
        put_help 1, #s_hosts_h2

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

        ; A has host_index at this point
:       clc
        adc     #$01
        pha                     ; save current y coord
        tay                     ; y coord

        ldx     #$01            ; x coord
        lda     host_index      ; digit
        adc     #$01            ; index is 0 based, need to increment for screen. C is clear already
        jsr     _fn_put_digit

        ; --------- print host string
        ldy     #0
        lda     (ptr1), y
        beq     display_empty   ; if the host string is null, display <Empty> instead

        pushax  ptr1
        jmp     j1

display_empty:
        pushax  #s_empty

j1:
        ldx     #$03
        pla                     ; restore current y
        tay
        jsr     _fn_put_s

        ; repeat for all 8 hosts
        adw     ptr1, #.sizeof(HostSlot)
        inc     host_index
        lda     host_index
        cmp     #8
        bne     :-

        ; we will grab keyboard now...
        ; jsr     _cgetc
        
        ; jsr     _fn_put_c

        ; 1-8        = Set current HOST
        ; Up/Down    = move between host selections (no wrap)
        ; Enter      = Edit current
        ; 
        ; Also global key shortcuts
        ; RIGHT/LEFT = move to Next/Previous Module (Devices/Wifi)
        ; OPTION     = Mount & Boot
        ; Ctrl-L     = Lobby
        ; 

:       jmp :-

        rts
.endproc

.rodata

; should display the options, e.g.
; <1-8> Slot, <E>dit, <Return> Browse, <L>obby
;  <C>onfig, <tab> Drive Slots, <option> Boot

s_hosts_h1:     SCREENCODE_INVERT_40_SPACES

                SCREENCODE_INVERT_CHARMAP
s_hosts_h2:     .byte "        Press keys to do stuff!         "
                NORMAL_CHARMAP

s_empty:        .byte "<Empty>", 0

.bss
host_index:     .res 1

.data
hosts_fetched:  .byte 0
