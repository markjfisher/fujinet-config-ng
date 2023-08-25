/*
This is to allow interop between C and ASM in project
*/

#ifndef FN_IO_H
#define FN_IO_H

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
  unsigned char localIP[4];
  unsigned char gateway[4];
  unsigned char netmask[4];
  unsigned char dnsIP[4];
  unsigned char macAddress[6];
  unsigned char bssid[6];
  char fn_version[15];
} AdapterConfig;

typedef unsigned char HostSlot[32];

typedef struct {
  unsigned char hostSlot;
  unsigned char mode;
  unsigned char file[FILE_MAXLEN];
} DeviceSlot;

typedef struct
{
  unsigned short numSectors;
  unsigned short sectorSize;
  unsigned char hostSlot;
  unsigned char deviceSlot;
  char filename[224];
} NewDisk;

#endif /* FN_IO_H */
