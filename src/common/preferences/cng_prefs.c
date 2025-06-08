#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "fujinet-fuji.h"
#include "cng_prefs.h"

#define FNC_CREATOR_ID 0xfe0c
#define FNC_APP_ID     0x01
#define FNC_KEY_ID     0x01

void write_defaults() {
	// memset(&cng_prefs, 0, sizeof(CNG_PREFS_DATA));

	// set the latest version here
	cng_prefs.version = 2;
	cng_prefs.colour = 0;
	cng_prefs.brightness = 0xd;
	cng_prefs.shade = 0;
	cng_prefs.bar_conn = 0xb4;
	cng_prefs.bar_disconn = 0x33;
	cng_prefs.bar_copy = 0x66;
	cng_prefs.anim_delay = 0x04;
	cng_prefs.date_format = 0x00;
	write_prefs();
}

void upgrade(uint8_t from) {
	switch(from) {
	case 0:
		// v0 only had 1 value stored, that was unused anyway, so just write defaults out
		write_defaults();
		break;

	case 1:
		// v1 had everything before anim_delay, write same values we have from loaded data but with anim_delay set to default 4

		// copy v1 data into structure, it will be short by 1 byte
		// NOTE: if we update even further, we will need to add the new fields here for v3 extras etc.
		memcpy(&cng_prefs, keys_buffer, 7);
		// do updates
		cng_prefs.version = 2; 			// set new version (UPDATE THIS TO LATEST VERSION)
		cng_prefs.anim_delay = 0x04;	// v2 additional data
		cng_prefs.date_format = 0;      // v2 additional data, dd/mm/yyyy format
		// v3 extra here, etc...

		// finally write the keys
		write_prefs();
		break;

	// case 2:
	//  these will have to copy old data correctly from old key structure to the new one...

	default:
		break;
	}
}

void set_appkey_details(void) {
	fuji_set_appkey_details(FNC_CREATOR_ID, FNC_APP_ID, DEFAULT);
}

bool read_appkeys(uint16_t *count) {
	set_appkey_details();
	return fuji_read_appkey(FNC_KEY_ID, count, keys_buffer);
}

void write_prefs(void) {
	set_appkey_details();
	fuji_write_appkey(FNC_KEY_ID, sizeof(cng_prefs), &cng_prefs);
}

void read_prefs(void) {
	bool r;
	uint16_t read_count = 0;

	memset(keys_buffer, 0, 66);
	r = read_appkeys(&read_count);
	if (!r) {
		// couldn't find a key, so set and write defaults
		write_defaults();
		return;
	}

	// the first byte is the version of the config being loaded, so we can future proof our appkeys
	cng_prefs.version = keys_buffer[0];

	switch(cng_prefs.version) {
	case 0:
		upgrade(0);
		break;
	case 1:
		upgrade(1);
		break;
	case 2:
		// values can be copied directly from buffer to the config object
		memcpy(&cng_prefs, keys_buffer, sizeof(CNG_PREFS_DATA));
		break;
	default:
		write_defaults();
		break;
	}

}