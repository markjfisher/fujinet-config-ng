#include <conio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "fn_data.h"

#include "edit_string.h"
#include "display_string_in_viewport.h"

extern char kb_get_c(void);

// NEW FUN! Use data structures rather than passing parameters. Less Software stack for only a handful of bytes
EditString es_params;

bool edit_string() {
    // cursor_pos is 0 index based position in the string, same as characters would be.
    char ch;
    es_params.buffer = (char*) malloc(es_params.max_length + 1);
    memcpy(es_params.buffer, es_params.initial_str, strlen(es_params.initial_str) + 1);
    es_params.current_length = strlen(es_params.buffer);
    es_params.cursor_pos = es_params.current_length;
    if (es_params.cursor_pos == es_params.max_length) es_params.cursor_pos--;

    display_string_in_viewport();

    for (;;) {
        ch = kb_get_c();
        if (ch == 0) continue;

        if (ch == FNK_ENTER) {
            strcpy(es_params.initial_str, es_params.buffer);
            free(es_params.buffer);
            return true;
        } else if (ch == FNK_ESC) {
            free(es_params.buffer);
            return false;
        } else if (ch >= FNK_ASCIIL && ch <= FNK_ASCIIH) {
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