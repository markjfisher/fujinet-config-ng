        .export     joy_process
        .export     reset_joy_state

        .include    "fn_data.inc"       ; loads "atari.inc"
        .include    "macros.inc"
        .include    "zp.inc"


; Bit masks for STICK0
JOY_UP_BIT    = $01
JOY_DOWN_BIT  = $02
JOY_LEFT_BIT  = $04
JOY_RIGHT_BIT = $08

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

; returns (in A) the equivalent key press from interacting with the joystick, or 0 if no button and/or movement.
; see end of file for original C implementation
; the direct asm saves 121 bytes.

.proc joy_process
        lda     #$00                ; default = not pushed
        sta     tmp1                ; UP state (1 = pushed)
        sta     tmp2                ; DOWN state
        sta     tmp3                ; LEFT state
        sta     tmp4                ; RIGHT state
        sta     ptr1                ; BUTTON state

        ; Read joystick/trigger state
        lda     STICK0

        ; rotate A into C 4 times, to get UP, DOWN, LEFT, RIGHT bits which get shifted into Carry
        ; 1 (i.e. C set) indicates no movement.
        ; we only allow cardinal movement with preference order UP/DOWN/LEFT/RIGHT

        lsr     a
        bcs     :+
        inc     tmp1                ; UP pushed
        bcc     check_button
:       lsr     a
        bcs     :+
        inc     tmp2                ; DOWN pushed
        bcc     check_button
:       lsr     a
        bcs     :+
        inc     tmp3                ; LEFT pushed
        bcc     check_button
:       lsr     a
        bcs     check_button
        inc     tmp4                ; RIGHT pushed

check_button:
        lda     STRIG0
        bne     :+
        inc     ptr1                ; BUTTON pushed
:

        ;  if (!button_pressed && button_was_pressed) {

        lda     ptr1
        bne     else1a

        lda     button_was_pressed
        beq     else1b                  ; we can skip part of next else if we got here

        ; passed both tests
        dec     button_was_pressed      ; set to 0
        
        lda     used_up
        beq     :+
        lda     #FNK_ESC
        bne     ret_key

:       lda     used_left
        beq     :+
        lda     #FNK_PARENT
        bne     ret_key

:       lda     used_right
        beq     :+
        lda     #FNK_EDIT
        bne     ret_key

        ; no joystick direction pushed, so standard click
:       lda     #FNK_ENTER

ret_key:
        ldx     #$00
        stx     used_up
        stx     used_down
        stx     used_left
        stx     used_right

        ; A holds return value
        rts

else1a:
        ; else if (button_pressed && !button_was_pressed) {
        lda     button_was_pressed
        bne     else2

else1b: lda     ptr1
        beq     else3

        inc     button_was_pressed      ; set to 1
        lda     tmp1
        sta     used_up
        lda     tmp2
        sta     used_down
        lda     tmp3
        sta     used_left
        lda     tmp4
        sta     used_right
        clc
        bcc     set_is_joy

else2:
        ; else if (button_pressed) {
        lda     ptr1
        beq     else3

        ; used_up |= current_up;
        ; used_down |= current_down;
        ; used_left |= current_left;
        ; used_right |= current_right;

        lda     tmp1
        beq     :+
        sta     used_up

:       lda     tmp2
        beq     :+
        sta     used_down

:       lda     tmp3
        beq     :+
        sta     used_left

:       lda     tmp4
        beq     :+
        sta     used_right

:       clc
        bcc     set_is_joy

else3:
        ; // Button is not pressed (and wasn't just released)

        ; if (!current_up && is_joy_up) {
        lda     tmp1
        bne     :+
        lda     is_joy_up
        beq     :+
        dec     is_joy_up
        lda     #FNK_UP
        bne     set_is_joy

        ; if (!current_down && is_joy_down) {
:       lda     tmp2
        bne     :+
        lda     is_joy_down
        beq     :+
        dec     is_joy_down
        lda     #FNK_DOWN
        bne     set_is_joy

        ; if (!current_left && is_joy_left) {
:       lda     tmp3
        bne     :+
        lda     is_joy_left
        beq     :+
        dec     is_joy_left
        lda     #FNK_LEFT
        bne     set_is_joy

        ; if (!current_right && is_joy_right) {
:       lda     tmp4
        bne     :+
        lda     is_joy_right
        beq     :+
        dec     is_joy_right
        lda     #FNK_RIGHT
        bne     set_is_joy

        ; no event
:       lda     #$00

set_is_joy:
        ; // Update state
        ldx     tmp1
        stx     is_joy_up
        ldx     tmp2
        stx     is_joy_down
        ldx     tmp3
        stx     is_joy_left
        ldx     tmp4
        stx     is_joy_right

        rts

.endproc

.data
; Current state flags
is_joy_up:          .byte 0
is_joy_down:        .byte 0
is_joy_left:        .byte 0
is_joy_right:       .byte 0

; Previous state tracking
button_was_pressed: .byte 0

; Directions used during button press
used_up:            .byte 0
used_down:          .byte 0
used_left:          .byte 0
used_right:         .byte 0

; // translated from:

; unsigned char joy_process(void)
; {
;     bool button_pressed;
;     unsigned char return_key = 0;
;     unsigned char stick_state = *STICK0;
;     unsigned char trig_state = *STRIG0;
    
;     // Check current joystick state (0 means pressed)
;     bool current_left = !(stick_state & JOY_LEFT_BIT);
;     bool current_right = !(stick_state & JOY_RIGHT_BIT);
;     bool current_up = !(stick_state & JOY_UP_BIT);
;     bool current_down = !(stick_state & JOY_DOWN_BIT);
;     button_pressed = (trig_state == 0);
    
;     // Button was just released
;     if (!button_pressed && button_was_pressed) {
;         button_was_pressed = false;
        
;         // Check if any direction was used during button press
;         if (used_left) {
;             return_key = FNK_PARENT;
;         }
;         else if (used_right) {
;             return_key = FNK_EDIT;
;         }
;         else if (used_up) {
;             return_key = FNK_ESC;
;         }
;         else {
;             // No direction was used - simple button click
;             return_key = FNK_ENTER;
;         }
        
;         // Reset all direction tracking
;         used_left = false;
;         used_right = false;
;         used_up = false;
;         used_down = false;
        
;         return return_key;
;     }
;     // Button was just pressed
;     else if (button_pressed && !button_was_pressed) {
;         button_was_pressed = true;
        
;         // Initialize direction tracking
;         used_left = current_left;
;         used_right = current_right;
;         used_up = current_up;
;         used_down = current_down;
;     }
;     // Button is being held (but not first frame)
;     else if (button_pressed) {
;         // Track any directions used while button is held
;         used_left |= current_left;
;         used_right |= current_right;
;         used_up |= current_up;
;         used_down |= current_down;
;     }
;     // Button is not pressed (and wasn't just released)
;     else {
;         // Handle simple direction releases
;         if (!current_left && is_joy_left) {
;             is_joy_left = false;
;             return FNK_LEFT;
;         }
;         if (!current_right && is_joy_right) {
;             is_joy_right = false;
;             return FNK_RIGHT;
;         }
;         if (!current_up && is_joy_up) {
;             is_joy_up = false;
;             return FNK_UP;
;         }
;         if (!current_down && is_joy_down) {
;             is_joy_down = false;
;             return FNK_DOWN;
;         }
;     }
    
;     // Update state
;     is_joy_left = current_left;
;     is_joy_right = current_right;
;     is_joy_up = current_up;
;     is_joy_down = current_down;
    
;     return 0;  // No event
; }

