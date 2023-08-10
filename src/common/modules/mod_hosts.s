        .export     mod_hosts, hosts_fetched, host_selected
        .import     _fn_io_get_host_slots, fn_io_hostslots, _dev_highlight_line, mod_current, mod_kb
        .import     pusha, pushax, setax
        .import     _fn_put_digit, _fn_put_s, _fn_clrscr, _fn_put_help, _fn_put_c, _fn_input_ucase
        .include    "zeropage.inc"
        .include    "atari.inc"
        .include    "fn_macros.inc"
        .include    "fn_io.inc"
        .include    "fn_mods.inc"

;  handle HOST LIST
.proc mod_hosts
        jsr     _fn_clrscr
        put_help 0, #s_hosts_h1
        put_help 1, #s_hosts_h2
        put_help 2, #s_hosts_h3

        ; do we have hosts data read?
        lda     hosts_fetched
        bne     :+

        jsr     _fn_io_get_host_slots
        mva     #$01, hosts_fetched

:
        jsr     display_hosts

        ; highlight current host entry
        jsr     _dev_highlight_line

        ; push params
        pusha   #7              ; only 8 entries on screen
        pusha   #Mod::info
        pusha   #Mod::devices
        pushax  #host_selected   ; our current host
        setax   #mod_hosts_kb
        jmp     mod_kb          ; rts from this will drop out of module


display_hosts:
        ; fn_io_hostslots is an array of 8 strings up to 32 bytes each, representing the strings of the hosts to display
        ; ptr1 points to n'th host
        mwa     #fn_io_hostslots, ptr1
        mva     #$00, host_index

        ; A has host_index at this point
l_all:  clc
        adc     #$02
        pha                     ; save current y coord
        tay                     ; y coord

        ldx     #$04            ; x coord
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
        ldx     #$06
        pla                     ; restore current y
        tay
        jsr     _fn_put_s

        ; repeat for all 8 hosts
        adw     ptr1, #.sizeof(HostSlot)
        inc     host_index
        lda     host_index
        cmp     #8
        bne     l_all

        rts

; the local module's keyboard handling routines
mod_hosts_kb:
        rts


.endproc

.rodata

; should display the options, e.g.
; <1-8> Slot, <E>dit, <Return> Browse, <L>obby
;  <C>onfig, <tab> Drive Slots, <option> Boot

s_hosts_h1:     SCREENCODE_INVERT_40_SPACES

                SCREENCODE_INVERT_CHARMAP
s_hosts_h2:     .byte "   ", 94, "INFO, ", 95,"DEVICES ", 92, 93, " HOST, OPT BOOT    "
s_hosts_h3:     .byte "  L Lobby                               "     
                NORMAL_CHARMAP

s_empty:        .byte "<Empty>", 0

.bss
host_index:     .res 1

.data
hosts_fetched:  .byte 0
host_selected: .byte 0