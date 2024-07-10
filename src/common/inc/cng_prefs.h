#ifndef CNG_PREFS_H
#define CNG_PREFS_H

#include <stdint.h>

typedef struct
{
    uint8_t version;
    uint8_t colour;
    uint8_t shade;
    uint8_t bar_conn;
    uint8_t bar_disconn;
    uint8_t bar_copy;
} CNG_PREFS_DATA;


extern CNG_PREFS_DATA cng_prefs;

#endif // CNG_PREFS_H