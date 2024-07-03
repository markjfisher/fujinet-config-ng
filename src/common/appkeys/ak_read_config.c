#include <stdbool.h>
#include <stdint.h>

#include "fujinet-fuji.h"

#define FNC_CREATOR_ID 0xfe0c
#define FNC_APP_ID     0x01
#define FNC_KEY_ID     0x01

extern uint8_t ak_version;
extern uint8_t ak_colour_idx;

uint8_t buffer[2];

void write_defaults() {
	ak_version = 0;
	ak_colour_idx = 0;
	buffer[0] = 0;
	buffer[1] = 0;
	fuji_write_appkey(FNC_KEY_ID, 2, buffer);
}

void ak_read_config(void) {
	bool r;
	uint16_t read_count = 0;

	fuji_set_appkey_details(FNC_CREATOR_ID, FNC_APP_ID, DEFAULT);
	r = fuji_read_appkey(FNC_KEY_ID, &read_count, buffer);
	if (!r) {
		// couldn't find a key, so set and write defaults
		write_defaults();
		return;
	}

	// the first byte is the version of the config being loaded, so we can future proof our appkeys
	ak_version = buffer[0];

	switch(ak_version) {
	case 0:
		ak_colour_idx = buffer[1];
		break;
	default:
		write_defaults();
		break;
	}

}