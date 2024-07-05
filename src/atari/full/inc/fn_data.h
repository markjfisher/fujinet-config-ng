#ifndef FN_DATA_H
#define FN_DATA_H

#include <atari.h>
#include <stdint.h>

void put_s(uint8_t x, uint8_t y, char *s);
extern uint8_t bank_count;

#define SCR_WIDTH       40
#define SCR_WID_NB      38
#define SCR_HEIGHT      22
#define SCR_BYTES_W     40
#define SCR_BWX2        80
#define SL_EDIT_X       5
#define SL_Y            2
#define SL_COUNT        8
#define MF_YOFF         4
#define FNS_N2C         0x10
#define FNS_C_R         0x32
#define FNS_C_W         0x37
#define DIR_PG_CNT      18
#define DIR_MAX_LEN     36

#define MAX_NETS        10

#define FNK_ESC         CH_ESC
#define FNK_ENTER       CH_ENTER
#define FNK_TAB         CH_TAB
#define FNK_BS          CH_DEL
#define FNK_DEL         CH_DELCHR
#define FNK_INS         0xFF
#define FNK_LEFT        CH_CURS_LEFT
#define FNK_LEFT2       0x2B
#define FNK_RIGHT       CH_CURS_RIGHT
#define FNK_RIGHT2      0x2A
#define FNK_UP          CH_CURS_UP
#define FNK_UP2         0x2D
#define FNK_DOWN        CH_CURS_DOWN
#define FNK_DOWN2       0x3D
#define FNK_ASCIIL      0x20
#define FNK_ASCIIH      0x7D
#define FNK_HOME        0x01
#define FNK_END         0x05
#define FNK_KILL        0x0B
#define FNK_PARENT      0x3C
#define FNK_EDIT        0x45
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
#define FNC_DIR_C       0x40
#define FNC_L_END       0x41
#define FNC_R_END       0x42
#define FNC_M_END       0x44
#define FNC_L_HL        0x50
#define FNC_LEND_ST     0x54

#define FNC_STAR        0x0A

#endif /* FN_DATA_H */