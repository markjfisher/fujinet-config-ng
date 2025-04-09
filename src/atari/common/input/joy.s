        .export     joy_process
        .export     reset_joy_state

        .include    "fn_data.inc"
        .include    "macros.inc"
        .include    "zp.inc"

; Bit masks for STICK0
JOY_UP_BIT    = $01
JOY_DOWN_BIT  = $02
JOY_LEFT_BIT  = $04
JOY_RIGHT_BIT = $08

; Hardware memory locations
STICK0  = $0278
STRIG0  = $0284

.proc reset_joy_state
        lda     #$00
        sta     is_joy_left
        sta     is_joy_right
        sta     is_joy_up
        sta     is_joy_down
        sta     button_was_pressed
        sta     used_left
        sta     used_right
        sta     used_up
        sta     used_down
        rts
.endproc

.proc joy_process
        lda     #$00                ; default = not pushed
        sta     tmp1                ; UP state (1 = pushed)
        sta     tmp2                ; DOWN raw
        sta     tmp3                ; LEFT raw
        sta     tmp4                ; RIGHT raw
        sta     ptr1                ; BUTTON raw

        ; Read joystick/trigger state
        lda     STICK0
        ldy     STRIG0

        tax
        ; rotate A into C 4 times, to get UP, DOWN, LEFT, RIGHT bits

        lsr     a
        bcs     :+
        inc     tmp1                ; UP pushed
:       lsr     a
        bcs     :+
        inc     tmp2                ; DOWN pushed
:       lsr     a
        bcs     :+
        inc     tmp3                ; LEFT pushed
:       lsr     a
        bcs     :+
        inc     tmp4                ; RIGHT pushed

:       lda     STRIG0
        beq     :+
        inc     ptr1                ; BUTTON pushed
:

        ; c1
        ; if (button_pressed != button_was_pressed)

        lda     button_was_pressed
        cmp     button_pressed
        beq     check_2

        ; if (button_pressed) {
        lda     button_pressed
        beq     c1p2        

        ; // button just pressed, remember if any direction is active
        ; used_dir = current_left || current_right || current_up || current_down;
        lda     tmp1                ; check if any dir was pushed
        bne     :+
        ora     tmp2
        bne     :+
        ora     tmp3
        bne     :+
        ora     tmp4
        beq     @o1                 ; if 0, non pushed

:       lda     #$01                ; yes, one pushed
@o1:    sta     used_dir

        jmp     check_button

c1p2:
        ; } else {
        ; button just released
        lda     #$00
        sta     button_was_pressed

        ; if (!used_direction) {
        lda     used_dir
        beq     c_cl
        ; // simple button click with no direction
        lda     #FNK_ENTER
        rts

c_cl:
        ; } else if (current_left) {
        lda     tmp3                ; LEFT pressed?
        beq     c_cr

        ; button + LEFT
        lda     #FNK_PARENT
        rts

c_cr:
        ; } else if (current_right) {
        lda     tmp4
        beq     c_cu

        ; button + RIGHT
        lda     #FNK_EDIT
        rts

c_cu:
        ; } else if (current_up) {
        lda     tmp1                ; UP pressed?
        beq     @o1

        ; button + UP
        lda     #FNK_ESC
        rts

@o1:
        sta     used_dir            ; a is still 0



.endproc

.data
; Current state flags
is_joy_up:          .byte 0
is_joy_down:        .byte 0
is_joy_left:        .byte 0
is_joy_right:       .byte 0

; Previous state tracking
button_was_pressed: .byte 0

; Direction used during button press
used_dir:           .byte 0
