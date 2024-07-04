#ifndef EDIT_STRING_H
#define EDIT_STRING_H

#include <stdbool.h>
#include <stdint.h>

bool edit_string();

typedef struct {
    char    *initial_str;
    int     max_length;
    uint8_t x_loc;
    uint8_t y_loc;
    uint8_t viewport_width;
    bool    is_password;
    bool    is_number;

	// values for display_string part
	char    *buffer;
    int     current_length;
    int     cursor_pos;
} EditString;

extern EditString es_params;

#endif // EDIT_STRING_H
