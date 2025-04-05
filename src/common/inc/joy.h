#ifndef _JOY_H
#define _JOY_H

// Hardware memory locations
#define STICK0 ((volatile unsigned char*)0x0278)
#define STRIG0 ((volatile unsigned char*)0x0284)

unsigned char joy_process(void);

#endif
