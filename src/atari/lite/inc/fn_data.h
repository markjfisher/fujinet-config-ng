#ifndef FN_DATA_H
#define FN_DATA_H

#include <atari.h>

#define FNS_N2C         0x10
#define FNS_C_R         0x32
#define FNS_C_W         0x37

#define DIR_PG_CNT      16
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

#define FNC_DIR_C       0x40
#define FNC_L_END       0x41
#define FNC_R_END       0x42
#define FNC_M_END       0x44

#endif /* FN_DATA_H */