// the main joystick handling to convert raw inputs to triggers/flags

#include <stdbool.h>
#include <atari.h>
#include "joy.h"
#include "fn_data.h"

// Bit masks for STICK0
#define JOY_UP_BIT    0x01
#define JOY_DOWN_BIT  0x02
#define JOY_LEFT_BIT  0x04
#define JOY_RIGHT_BIT 0x08

// Current state flags
static bool is_joy_left = false;
static bool is_joy_right = false;
static bool is_joy_up = false;
static bool is_joy_down = false;
static bool button_was_pressed = false;
static bool used_direction = false;

void reset_joy_state(void)
{
    is_joy_left = false;
    is_joy_right = false;
    is_joy_up = false;
    is_joy_down = false;
    button_was_pressed = false;
    used_direction = false;
}

unsigned char joy_process(void)
{
    unsigned char stick_state = *STICK0;
    unsigned char trig_state = *STRIG0;
    
    // Check current joystick state (0 means pressed)
    bool button_pressed = (trig_state == 0);
    bool current_left = !(stick_state & JOY_LEFT_BIT);
    bool current_right = !(stick_state & JOY_RIGHT_BIT);
    bool current_up = !(stick_state & JOY_UP_BIT);
    bool current_down = !(stick_state & JOY_DOWN_BIT);
    
    // Handle button events
    if (button_pressed != button_was_pressed) {
        if (button_pressed) {
            // Button just pressed - remember if any direction is active
            used_direction = current_left || current_right || current_up || current_down;
        } else {
            // Button just released
            button_was_pressed = false;
            
            if (!used_direction) {
                // Simple button click with no direction
                return FNK_ENTER;
            } else if (current_left) {
                return FNK_PARENT;
            } else if (current_right) {
                return FNK_EDIT;
            } else if (current_up) {
                return FNK_ESC;
            }
            
            used_direction = false;
        }
    } else if (button_pressed) {
        // Update if directions are used during button press
        used_direction |= current_left || current_right || current_up || current_down;
    }
    
    // Handle simple direction releases (when button is not pressed)
    if (!button_pressed) {
        if (!current_left && is_joy_left) {
            is_joy_left = false;
            return FNK_LEFT;
        }
        if (!current_right && is_joy_right) {
            is_joy_right = false;
            return FNK_RIGHT;
        }
        if (!current_up && is_joy_up) {
            is_joy_up = false;
            return FNK_UP;
        }
        if (!current_down && is_joy_down) {
            is_joy_down = false;
            return FNK_DOWN;
        }
    }
    
    // Update state
    is_joy_left = current_left;
    is_joy_right = current_right;
    is_joy_up = current_up;
    is_joy_down = current_down;
    button_was_pressed = button_pressed;
    
    return 0;  // No event
}
