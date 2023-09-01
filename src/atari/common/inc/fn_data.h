#ifndef FN_DATA_H
#define FN_DATA_H

#include <atari.h>

#define SL_EDIT_X       5
#define SL_Y            2
#define SL_COUNT        8

#define MF_YOFF         4

#define FNS_N2C         0x10
#define FNS_C_R         0x32
#define FNS_C_W         0x37

#define DIR_CHAR        0x00
#define DIR_PG_CNT      0x10
#define DIR_MAX_LEN     36

#define FNK_ESC         ATESC
#define FNK_ENTER       ATEOL
#define FNK_TAB         ATTAB
#define FNK_BS          ATRUB
#define FNK_DEL         ATDEL
#define FNK_INS         ATINS
#define FNK_LEFT        ATLRW
#define FNK_LEFT2       0x2B
#define FNK_RIGHT       ATRRW
#define FNK_RIGHT2      0x2A
#define FNK_UP          ATURW
#define FNK_UP2         0x2D
#define FNK_DOWN        ATDRW
#define FNK_DOWN2       0x3D
#define FNK_ASCIIL      0x20
#define FNK_ASCIIH      0x7D
#define FNK_HOME        0x01
#define FNK_END         0x05
#define FNK_KILL        0x0B
#define FNK_PARENT      0x3C
#define FNK_FILTER      0x46
#define FNK_FILTER2     0x66

#define FNC_TLW         0x4A
#define FNC_TRW         0x4B
#define FNC_BLW         0x4C
#define FNC_BRW         0x4F
#define FNC_TL          0x46
#define FNC_TR          0x47
#define FNC_BL          0x48
#define FNC_BR          0x49
#define FNC_TL_I        0xC6
#define FNC_TR_I        0xC7
#define FNC_BL_I        0xC8
#define FNC_BR_I        0xC9
#define FNC_DN_BLK      0x55
#define FNC_UP_BLK      0xD5
#define FNC_LT_BLK      0x59
#define FNC_RT_BLK      0xD9
#define FNC_BLANK       0x00
#define FNC_FULL        0x80
#define FNC_L_END       0x41
#define FNC_R_END       0x42
#define FNC_M_END       0x44
#define FNC_L_HL        0x50
#define FNC_R_HL        0x54

#endif /* FN_DATA_H */