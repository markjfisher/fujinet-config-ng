#ifndef FN_IO_H
#define FN_IO_H

#include <stdint.h>
#include <stdbool.h>

#define FILE_MAXLEN 36
#define SSID_MAXLEN 33 /* 32 + NULL */

enum DiskSize {
    size90      = 0,
    size130     = 2,
    size180     = 4,
    size360     = 6,
    size720     = 8,
    size1440    = 10,
    sizeCustom  = 12
};

enum WifiStatus {
    no_ssid_available   = 1,
    connected           = 3,
    connect_failed      = 4,
    connection_lost     = 5
};

typedef struct {
  char ssid[SSID_MAXLEN];
  signed char rssi;
} SSIDInfo;

typedef struct
{
  char ssid[SSID_MAXLEN];
  char password[64];
} NetConfig;

typedef struct
{
  char ssid[SSID_MAXLEN];
  char hostname[64];
  uint8_t localIP[4];
  uint8_t gateway[4];
  uint8_t netmask[4];
  uint8_t dnsIP[4];
  uint8_t macAddress[6];
  uint8_t bssid[6];
  char fn_version[15];
} AdapterConfig;

typedef uint8_t HostSlot[32];

typedef struct {
  uint8_t hostSlot;
  uint8_t mode;
  uint8_t file[FILE_MAXLEN];
} DeviceSlot;

typedef struct
{
  uint16_t numSectors;
  uint16_t sectorSize;
  uint8_t hostSlot;
  uint8_t deviceSlot;
  char filename[224];
} NewDisk;

void fn_io_close_directory(void);
void fn_io_copy_file(uint8_t src_slot, uint8_t dst_slot, char *copy_spec);
void fn_io_create_new(uint8_t selected_host_slot, uint8_t selected_device_slot, uint16_t selected_size, NewDisk *new_disk, char *dir_path);
void fn_io_disable_device(uint8_t d);
void fn_io_enable_device(uint8_t d);
void fn_io_get_adapter_config(AdapterConfig *ac);
bool fn_io_get_device_enabled_status(uint8_t d);
void fn_io_get_device_filename(uint8_t ds, char *buffer);
void fn_io_get_device_slots(DeviceSlot *d);
void fn_io_get_host_slots(HostSlot *h);
void fn_io_get_scan_result(uint8_t n, SSIDInfo *ssid_info);
void fn_io_get_ssid(NetConfig *net_config);
bool fn_io_get_wifi_enabled(void);
uint8_t fn_io_get_wifi_status(void);
uint8_t fn_io_mount_all(void);
void fn_io_mount_disk_image(uint8_t ds, uint8_t mode);
void fn_io_mount_host_slot(uint8_t hs);
void fn_io_open_directory(uint8_t hs, char *path_filter);
void fn_io_put_device_slots(DeviceSlot *d);
void fn_io_put_host_slots(HostSlot *h);
char *fn_io_read_directory(uint8_t maxlen, uint8_t aux2, char *buffer);
void fn_io_reset(void);
uint8_t fn_io_scan_for_networks(void);
void fn_io_set_boot_config(uint8_t toggle);
void fn_io_set_boot_mode(uint8_t mode);
void fn_io_set_device_filename(uint8_t mode, uint8_t host_slot, uint8_t device_slot, void *buffer);
void fn_io_set_directory_position(uint16_t pos);
void fn_io_set_ssid(NetConfig *nc);
void fn_io_unmount_disk_image(uint8_t ds);

#endif /* FN_IO_H */
