#include <conio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "fn_data.h"

#include "edit_string.h"
#include "display_string_in_viewport.h"

extern char kb_get_c(void);

bool edit_string(char* initial_str, int max_length, uint8_t x, uint8_t y, uint8_t viewport_width, bool is_password) {
    // cursor_pos is 0 index based position in the string, same as characters would be.
    int cursor_pos, current_length;
    char ch;
    char* buffer = (char*)malloc(max_length + 1);
    memcpy(buffer, initial_str, strlen(initial_str) + 1);
    current_length = strlen(buffer);
    cursor_pos = current_length;
    if (cursor_pos == max_length) cursor_pos--;

    display_string_in_viewport(x, y, buffer, current_length, viewport_width, cursor_pos, is_password);

    for (;;) {
        ch = kb_get_c();
        if (ch == 0) continue;

        if (ch == FNK_ENTER) {
            strcpy(initial_str, buffer);
            free(buffer);
            return true;
        } else if (ch == FNK_ESC) {
            free(buffer);
            return false;
        } else if (ch >= FNK_ASCIIL && ch <= FNK_ASCIIH) {
            if (current_length < max_length) {
                buffer[cursor_pos] = ch;
                if (cursor_pos == current_length) {
                    current_length++;
                    buffer[current_length] = '\0';
                }
                if (cursor_pos < (max_length - 1)) {
                    cursor_pos++;
                }
            } else if (current_length == max_length) {
                buffer[cursor_pos] = ch;
                if (cursor_pos < (max_length - 1)) {
                    cursor_pos++;
                }
            }
        } else if (ch == FNK_LEFT) {
            if (cursor_pos > 0) cursor_pos--;
        } else if (ch == FNK_RIGHT) {
            if (cursor_pos < (current_length - 1) || (cursor_pos == (current_length - 1) && current_length < max_length)) {
                cursor_pos++;
            }
        } else if (ch == FNK_DEL) {
            if (cursor_pos < current_length) {
                memmove(&buffer[cursor_pos], &buffer[cursor_pos + 1], current_length - cursor_pos);
                current_length--;
            }
        } else if (ch == FNK_BS) {
            if (cursor_pos > 0) {
                cursor_pos--;
                memmove(&buffer[cursor_pos], &buffer[cursor_pos + 1], current_length - cursor_pos);
                current_length--;
            }
        } else if (ch == FNK_INS) {
            if (cursor_pos < current_length && current_length < max_length) {
                memmove(&buffer[cursor_pos + 1], &buffer[cursor_pos], current_length - cursor_pos + 1);
                buffer[cursor_pos] = ' ';
                current_length++;
            } else if (cursor_pos < current_length) {
                memmove(&buffer[cursor_pos + 1], &buffer[cursor_pos], max_length - cursor_pos - 1);
                buffer[cursor_pos] = ' ';
            }
        } else if (ch == FNK_KILL) {
            buffer[cursor_pos] = '\0';
            current_length = cursor_pos;
        } else if (ch == FNK_HOME) {
            cursor_pos = 0;
        } else if (ch == FNK_END) {
            cursor_pos = current_length;
            if (cursor_pos == max_length) cursor_pos--;
        }

        display_string_in_viewport(x, y, buffer, current_length, viewport_width, cursor_pos, is_password);
    }
}