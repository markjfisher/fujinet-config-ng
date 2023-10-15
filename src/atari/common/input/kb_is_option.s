        .export     _kb_is_option

        .include    "macros.inc"
        .include    "atari.inc"

; CONSOL codes:
;      |Key        Value    0    1    2    3    4    5    6    7    |
;      +------------------------------------------------------------+
;      |OPTION              X    X    X    X                        |
;      |SELECT              X    X              X    X              |
;      |START               X         X         X         X         |


; bool kb_is_option()
;
; Check if OPTION key is being pressed.
; Returns: 1 if true, 0 if false
.proc _kb_is_option
        ldx     #$00
        lda     CONSOL
        cmp     #$03    ; option on its own
        beq     yes
        lda     #$00
        .byte   $2c     ; BIT, causes next 2 bytes to be ignored
yes:    lda     #$01
        rts
.endproc