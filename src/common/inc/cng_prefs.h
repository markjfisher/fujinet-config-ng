#ifndef CNG_PREFS_H
#define CNG_PREFS_H

#include <stdint.h>

typedef struct
{
    uint8_t version;
    uint8_t colour;
    uint8_t brightness;
    uint8_t shade;
    uint8_t bar_conn;
    uint8_t bar_disconn;
    uint8_t bar_copy;
    uint8_t anim_delay;
    uint8_t date_format;
} CNG_PREFS_DATA;

extern CNG_PREFS_DATA cng_prefs;

// keysize + 2
extern uint8_t keys_buffer[66];


void set_appkey_details(void);
bool read_appkeys(uint16_t *count);
void write_prefs(void);
void read_prefs(void);

#endif // CNG_PREFS_H