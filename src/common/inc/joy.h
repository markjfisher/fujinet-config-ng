#ifndef _JOY_H
#define _JOY_H

#include <stdbool.h>

// Hardware memory locations
#define STICK0 ((volatile unsigned char*)0x0278)
#define STRIG0 ((volatile unsigned char*)0x0284)

extern bool joy_left;
extern bool joy_right;
extern bool joy_up;
extern bool joy_down;
extern bool joy_button_click;
extern bool joy_top;
extern bool joy_bottom;
extern bool joy_home;
extern bool joy_end;

bool joy_process(void);

#endif
