#include <conio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "display_string_in_viewport.h"
#include "edit_string.h"

extern EditString es_params;

void display_string_in_viewport() {
    int i, char_index, start_pos, half_viewport;
    start_pos = 0;
    half_viewport = es_params.viewport_width / 2;

    if (es_params.cursor_pos > half_viewport && es_params.current_length >= es_params.viewport_width) {
        start_pos = es_params.cursor_pos - half_viewport;
        if (es_params.cursor_pos >= es_params.current_length) {
            start_pos = es_params.current_length - es_params.viewport_width + 1; // Adjust to show the cursor at the end
        } else if (start_pos + es_params.viewport_width > es_params.current_length) {
            start_pos = es_params.current_length - es_params.viewport_width; // Prevent start_pos from going too far
        }
    }

    // gotoxy(2, 3);
    // cprintf("sp: %d  ", start_pos);
    // gotoxy(10, 3);
    // cprintf("cp: %d  ", es_params.cursor_pos);
    // gotoxy(18, 3);
    // cprintf("es_params.current_length: %d  ", es_params.current_length);

    gotoxy(es_params.x_loc, es_params.y_loc);
    for (i = 0; i < es_params.viewport_width; i++) {
        char_index = i + start_pos;
        if (char_index == es_params.cursor_pos) {
            revers(1); // Invert the character for cursor position
        }

        if (char_index < es_params.current_length) {
            if (!es_params.is_password)
                cputc(es_params.buffer[char_index]);
            else
                cputc('*');
        } else {
            cputc(' ');
        }
        if (char_index == es_params.cursor_pos) {
            revers(0); // Revert to normal video mode after printing the cursor character
        }
    }
}