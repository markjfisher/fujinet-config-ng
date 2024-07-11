#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "fujinet-fuji.h"
#include "cng_prefs.h"

#define FNC_CREATOR_ID 0xfe0c
#define FNC_APP_ID     0x01
#define FNC_KEY_ID     0x01

uint8_t buffer[sizeof(CNG_PREFS_DATA)];

void write_defaults() {
	memset(&cng_prefs, 0, sizeof(CNG_PREFS_DATA));

	// set the latest version here
	cng_prefs.version = 1;
	cng_prefs.colour = 0;
	cng_prefs.shade = 0;
	cng_prefs.bar_conn = 0xb4;
	cng_prefs.bar_disconn = 0x33;
	cng_prefs.bar_copy = 0x66;

	fuji_write_appkey(FNC_KEY_ID, sizeof(cng_prefs), &cng_prefs);
}

void upgrade(uint8_t from) {
	switch(from) {
	case 0:
		// v0 only had 1 value stored, that was unused anyway, so just write defaults out
		write_defaults();
		break;

	// case 1:
	//  these will have to copy old data correctly from old key structure to the new one...

	default:
		break;
	}
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
	cng_prefs.version = buffer[0];

	switch(cng_prefs.version) {
	case 0:
		upgrade(0);
		break;
	case 1:
		// values can be copied directly from buffer to the config object
		memcpy(&cng_prefs, buffer, sizeof(CNG_PREFS_DATA));
		break;
	default:
		write_defaults();
		break;
	}

}