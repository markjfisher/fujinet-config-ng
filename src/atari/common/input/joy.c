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

// Previous state tracking for edge detection
static bool button_was_pressed = false;

// Combination state tracking
static bool button_combo_active = false;
static bool direction_after_button = false;

unsigned char joy_process(void)
{
    unsigned char stick_state;
    unsigned char trig_state;
    bool button_pressed;
    bool current_left;
    bool current_right;
    bool current_up;
    bool current_down;
    
    // Read hardware directly
    stick_state = *STICK0;
    trig_state = *STRIG0;
    
    // Check button state (STRIG0 is 0 when pressed, 1 when not pressed)
    button_pressed = (trig_state == 0);
    
    if (button_pressed && !button_was_pressed)
    {
        // Button just pressed - start potential combo
        button_combo_active = true;
        direction_after_button = false;
    }
    else if (!button_pressed && button_was_pressed)
    {
        // Button released
        if (!direction_after_button)
        {
            // Simple button click (no direction was used)
            button_was_pressed = false;
            button_combo_active = false;
            return FNK_ENTER;
        }
        
        // Check for combos on button release
        if (button_combo_active)
        {
            button_combo_active = false;
            if (is_joy_left) return FNK_PARENT;
            // if (is_joy_right) return FNK_END;
        }
    }
    button_was_pressed = button_pressed;
    
    // Track directional state changes (bits are 1 when NOT pressed)
    current_left = !(stick_state & JOY_LEFT_BIT);
    current_right = !(stick_state & JOY_RIGHT_BIT);
    current_up = !(stick_state & JOY_UP_BIT);
    current_down = !(stick_state & JOY_DOWN_BIT);
    
    // Handle direction release events
    if (!current_left && is_joy_left) 
    {
        is_joy_left = false;
        return FNK_LEFT;
    }
    if (!current_right && is_joy_right)
    {
        is_joy_right = false;
        return FNK_RIGHT;
    }
    if (!current_up && is_joy_up)
    {
        is_joy_up = false;
        return FNK_UP;
    }
    if (!current_down && is_joy_down)
    {
        is_joy_down = false;
        return FNK_DOWN;
    }
    
    // Update current state
    is_joy_left = current_left;
    is_joy_right = current_right;
    is_joy_up = current_up;
    is_joy_down = current_down;
    
    // Track if any direction was used during button press
    if (button_combo_active && (current_left || current_right || current_up || current_down))
    {
        direction_after_button = true;
    }

    return 0;  // No key event
}
