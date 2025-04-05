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

// Direction used during button press
static bool used_left = false;
static bool used_right = false;
static bool used_up = false;
static bool used_down = false;

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
    
    // Track directional state changes (bits are 1 when NOT pressed)
    current_left = !(stick_state & JOY_LEFT_BIT);
    current_right = !(stick_state & JOY_RIGHT_BIT);
    current_up = !(stick_state & JOY_UP_BIT);
    current_down = !(stick_state & JOY_DOWN_BIT);
    
    // Button just pressed
    if (button_pressed && !button_was_pressed)
    {
        // Reset direction tracking
        used_left = current_left;
        used_right = current_right;
        used_up = current_up;
        used_down = current_down;
    }
    // Button is being held
    else if (button_pressed)
    {
        // Track any directions used while button is held
        used_left |= current_left;
        used_right |= current_right;
        used_up |= current_up;
        used_down |= current_down;
    }
    // Button just released
    else if (!button_pressed && button_was_pressed)
    {
        // Check if any directions were used during button press
        if (used_left) 
        {
            used_left = false;
            button_was_pressed = false;
            return FNK_PARENT;
        }
        if (used_right)
        {
            used_right = false;
            button_was_pressed = false;
            return FNK_EDIT;
        }
        if (used_up)
        {
            used_up = false;
            button_was_pressed = false;
            return FNK_ESC;
        }
        if (!used_left && !used_right && !used_up && !used_down)
        {
            // Simple button click with no direction
            button_was_pressed = false;
            return FNK_ENTER;
        }
        // Reset all direction tracking
        used_left = used_right = used_up = used_down = false;
    }
    
    // If button isn't pressed, check for simple direction releases
    if (!button_pressed)
    {
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
    }
    
    // Update current state
    is_joy_left = current_left;
    is_joy_right = current_right;
    is_joy_up = current_up;
    is_joy_down = current_down;
    button_was_pressed = button_pressed;

    return 0;  // No key event
}
