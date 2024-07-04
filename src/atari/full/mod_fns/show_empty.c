#include <conio.h>
#include "../../common/input/edit_string.h"

extern char s_empty[];

void show_empty() {
	gotoxy(es_params.x_loc, es_params.y_loc);
	cputs(s_empty);
}