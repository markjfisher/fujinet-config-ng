#include <conio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "fn_data.h"

#include "edit_string.h"
#include "display_string_in_viewport.h"

extern char kb_get_c(void);

// extern EditString es_params;

#pragma code-name ("CODE2")

void show_string_c(int len) {
    int i;

    gotoxy(es_params.x_loc, es_params.y_loc);
    for (i = 0; i < es_params.viewport_width; i++) {
        if (i < len) {
            cputc(es_params.initial_str[i]);
        } else {
            cputc(' ');
        }
    }

}

bool edit_string_c() {
    // cursor_pos is 0 index based position in the string, same as characters would be.
    char ch;
    int original_length = strlen(es_params.initial_str);

    es_params.buffer = (char *) malloc(es_params.max_length + 1);
    memcpy(es_params.buffer, es_params.initial_str, original_length + 1);
    es_params.current_length = original_length;
    es_params.cursor_pos = es_params.current_length;
    if (es_params.cursor_pos == es_params.max_length) es_params.cursor_pos--;

    display_string_in_viewport();

    for (;;) {
        ch = kb_get_c();
        if (ch == 0) continue;

        if (ch == FNK_ENTER) {
            strcpy(es_params.initial_str, es_params.buffer);
            es_params.initial_str[es_params.current_length] = 0;
            free(es_params.buffer);
            // clean up any cursor nonsense
            show_string_c(es_params.current_length);
            return true;
        } else if (ch == FNK_ESC) {
            free(es_params.buffer);
            // reshow the original string
            show_string_c(original_length);
            return false;
        } else if (ch >= FNK_ASCIIL && ch <= FNK_ASCIIH) {
            // ignore if it's numeric only and not between 0 and 9, SIMPLE ONLY, no fullstops
            if (es_params.is_number && (ch < '0' || ch > '9')) {
                continue;
            }

            if (es_params.current_length < es_params.max_length) {
                es_params.buffer[es_params.cursor_pos] = ch;
                if (es_params.cursor_pos == es_params.current_length) {
                    es_params.current_length++;
                    es_params.buffer[es_params.current_length] = '\0';
                }
                if (es_params.cursor_pos < (es_params.max_length - 1)) {
                    es_params.cursor_pos++;
                }
            } else if (es_params.current_length == es_params.max_length) {
                es_params.buffer[es_params.cursor_pos] = ch;
                if (es_params.cursor_pos < (es_params.max_length - 1)) {
                    es_params.cursor_pos++;
                }
            }
        } else if (ch == FNK_LEFT) {
            if (es_params.cursor_pos > 0) es_params.cursor_pos--;
        } else if (ch == FNK_RIGHT) {
            if (es_params.cursor_pos < (es_params.current_length - 1) || (es_params.cursor_pos == (es_params.current_length - 1) && es_params.current_length < es_params.max_length)) {
                es_params.cursor_pos++;
            }
        } else if (ch == FNK_DEL) {
            if (es_params.cursor_pos < es_params.current_length) {
                memmove(&es_params.buffer[es_params.cursor_pos], &es_params.buffer[es_params.cursor_pos + 1], es_params.current_length - es_params.cursor_pos);
                es_params.current_length--;
            }
        } else if (ch == FNK_BS) {
            if (es_params.cursor_pos > 0) {
                es_params.cursor_pos--;
                memmove(&es_params.buffer[es_params.cursor_pos], &es_params.buffer[es_params.cursor_pos + 1], es_params.current_length - es_params.cursor_pos);
                es_params.current_length--;
            }
        } else if (ch == FNK_INS) {
            if (es_params.cursor_pos < es_params.current_length && es_params.current_length < es_params.max_length) {
                memmove(&es_params.buffer[es_params.cursor_pos + 1], &es_params.buffer[es_params.cursor_pos], es_params.current_length - es_params.cursor_pos + 1);
                es_params.buffer[es_params.cursor_pos] = ' ';
                es_params.current_length++;
            } else if (es_params.cursor_pos < es_params.current_length) {
                memmove(&es_params.buffer[es_params.cursor_pos + 1], &es_params.buffer[es_params.cursor_pos], es_params.max_length - es_params.cursor_pos - 1);
                es_params.buffer[es_params.cursor_pos] = ' ';
            }
        } else if (ch == FNK_KILL) {
            es_params.buffer[es_params.cursor_pos] = '\0';
            es_params.current_length = es_params.cursor_pos;
        } else if (ch == FNK_HOME) {
            es_params.cursor_pos = 0;
        } else if (ch == FNK_END) {
            es_params.cursor_pos = es_params.current_length;
            if (es_params.cursor_pos == es_params.max_length) es_params.cursor_pos--;
        }

        display_string_in_viewport();
    }
}