#include <string.h>
#include <stdint.h>

// Convert 2-digit number to string, with leading zero if needed
static void uint8_to_str(char* dest, uint8_t num) {
    dest[0] = '0' + (num / 10);
    dest[1] = '0' + (num % 10);
    dest[2] = '\0';
}

// Convert packed timestamp to formatted date string
// timestamp: 4 bytes containing packed date/time data
// output: buffer to store the resulting string (should be at least 11 bytes)
// mfp_date_format: 0 for dd/mm/yyyy, 1 for mm/dd/yyyy, 2 for yyyy/mm/dd
void timestamp_to_datestr(const uint8_t* timestamp, char* output, uint8_t mfp_date_format) {
    char temp[5];  // Temporary buffer for number conversion

    // Extract date components
    uint16_t year = 1970 + timestamp[0];
    uint8_t month = timestamp[1] & 0x0F;        // Lower 4 bits only
    uint8_t day = (timestamp[2] >> 3) & 0x1F;   // Upper 5 bits

    // Clear the output buffer
    output[0] = '\0';

    if (mfp_date_format == 0) {
        // dd/mm/yyyy format
        uint8_to_str(temp, day);
        strcpy(output, temp);
        strcat(output, "/");
        uint8_to_str(temp, month);
        strcat(output, temp);
        strcat(output, "/");
        // Add year
        temp[0] = '0' + (year / 1000);
        temp[1] = '0' + ((year / 100) % 10);
        temp[2] = '0' + ((year / 10) % 10);
        temp[3] = '0' + (year % 10);
        temp[4] = '\0';
        strcat(output, temp);
    } else if (mfp_date_format == 1) {
        // mm/dd/yyyy format
        uint8_to_str(temp, month);
        strcpy(output, temp);
        strcat(output, "/");
        uint8_to_str(temp, day);
        strcat(output, temp);
        strcat(output, "/");
        // Add year
        temp[0] = '0' + (year / 1000);
        temp[1] = '0' + ((year / 100) % 10);
        temp[2] = '0' + ((year / 10) % 10);
        temp[3] = '0' + (year % 10);
        temp[4] = '\0';
        strcat(output, temp);
    } else {
        // yyyy/mm/dd format (mfp_date_format == 2)
        // Add year first
        temp[0] = '0' + (year / 1000);
        temp[1] = '0' + ((year / 100) % 10);
        temp[2] = '0' + ((year / 10) % 10);
        temp[3] = '0' + (year % 10);
        temp[4] = '\0';
        strcpy(output, temp);
        strcat(output, "/");
        uint8_to_str(temp, month);
        strcat(output, temp);
        strcat(output, "/");
        uint8_to_str(temp, day);
        strcat(output, temp);
    }
}

// Convert packed timestamp to time string in HH:MM format
// timestamp: 4 bytes containing packed date/time data
// output: buffer to store the resulting string (should be at least 6 bytes)
void timestamp_to_timestr(const uint8_t* timestamp, char* output) {
    char temp[3];

    // Extract time components
    uint8_t hour = ((timestamp[2] & 0x07) << 2) | ((timestamp[3] >> 6) & 0x03);
    uint8_t minute = timestamp[3] & 0x3F;

    // Convert hour
    uint8_to_str(temp, hour);
    strcpy(output, temp);

    // Add separator and minutes
    strcat(output, ":");
    uint8_to_str(temp, minute);
    strcat(output, temp);
}
