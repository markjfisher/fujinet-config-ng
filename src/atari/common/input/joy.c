// the main joystick handling to convert raw inputs to triggers/flags

#include <stdbool.h>
#include <atari.h>
#include "joy.h"

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
static bool is_joy_button = false;

// Previous state tracking for edge detection
static bool button_was_pressed = false;

// Combination state tracking
static bool button_combo_active = false;
static bool direction_after_button = false;

// Public state flags that other code can check
bool joy_left = false;
bool joy_right = false;
bool joy_up = false;
bool joy_down = false;
bool joy_button_click = false;
bool joy_top = false;
bool joy_bottom = false;
bool joy_home = false;
bool joy_end = false;

void joy_clear_flags(void)
{
    joy_left = false;
    joy_right = false;
    joy_up = false;
    joy_down = false;
    joy_button_click = false;
    joy_top = false;
    joy_bottom = false;
    joy_home = false;
    joy_end = false;
}

bool joy_process(void)
{
    unsigned char stick_state;
    unsigned char trig_state;
    bool button_pressed;
    bool current_left;
    bool current_right;
    bool current_up;
    bool current_down;
    bool any_event = false;
    
    // Read hardware directly
    stick_state = *STICK0;
    trig_state = *STRIG0;
    
    // Clear all event flags at start of processing
    joy_clear_flags();
    
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
            joy_button_click = true;
            any_event = true;
        }
        
        // Check for combos on button release
        if (button_combo_active)
        {
            if (is_joy_up) { joy_top = true; any_event = true; }
            if (is_joy_down) { joy_bottom = true; any_event = true; }
            if (is_joy_left) { joy_home = true; any_event = true; }
            if (is_joy_right) { joy_end = true; any_event = true; }
        }
        
        button_combo_active = false;
    }
    button_was_pressed = button_pressed;
    
    // Track directional state changes (bits are 1 when NOT pressed)
    current_left = !(stick_state & JOY_LEFT_BIT);
    current_right = !(stick_state & JOY_RIGHT_BIT);
    current_up = !(stick_state & JOY_UP_BIT);
    current_down = !(stick_state & JOY_DOWN_BIT);
    
    // Handle direction release events
    if (!current_left && is_joy_left) { joy_left = true; any_event = true; }
    if (!current_right && is_joy_right) { joy_right = true; any_event = true; }
    if (!current_up && is_joy_up) { joy_up = true; any_event = true; }
    if (!current_down && is_joy_down) { joy_down = true; any_event = true; }
    
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

    return any_event;
}
