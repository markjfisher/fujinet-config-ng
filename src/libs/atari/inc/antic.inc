;;; antic codes and addresses for display list handling

DMACTL = $D400 ; DMA control for display and Player/Missile graphics
CHACTL = $D401 ; Character display control
DLISTL = $D402 ; Display List Pointer (low)
DLISTH = $D403 ; Display List Pointer (high)
HSCROL = $D404 ; Horizontal Fine Scroll 0 to 16 color clocks.
VSCROL = $D405 ; Vertical Fine Scroll 0 to 16 scanlines.
PMBASE = $D407 ; Player/Missile Base Address (high) 
CHBASE = $D409 ; Character Set Base Address (high)
WSYNC =  $D40A ; Wait for Horizontal Sync
VCOUNT = $D40B ; (Read) Vertical Scan Line Counter
PENH =   $D40C ; (Read) Light Pen Horizontal Position
PENV =   $D40D ; (Read) Light Pen Vertical Position
NMIEN =  $D40E ; Non-Maskable Interupt (NMI) Enable
NMIRES = $D40F ; Non-Maskable Interrupt (NMI) Reset
NMIST =  $D40F ; (Read) Non-Maskable Interrupt Status

SDMCTL = $022F ; DMACTL
SDLSTL = $0230 ; DLISTL
SDLSTH = $0231 ; DLISTH
;
CHBAS = $02F4 ; CHBASE
CHART = $02F3 ; CHACTL
;
LPENH = $0234 ; (Read) PENH
LPENV = $0235 ; (Read) PENV

PIA   	=	$D300
PORTA 	=	PIA+0
PORTB 	=	PIA+1
PACTL 	=	PIA+2
PBCTL 	=	PIA+3

; absolute instructions (non mode lines)

DL_JMP  = $01
DL_JVB  = $41

; DL_BLKn display n empty lines (just background)

DL_BLK1  = 0
DL_BLK2  = $10
DL_BLK3  = $20
DL_BLK4  = $30
DL_BLK5  = $40
DL_BLK6  = $50
DL_BLK7  = $60
DL_BLK8  = $70

; absolute instructions (mode lines)

DL_CHR40x8x1  = $02               ; monochrome, 40 character & 8 scanlines per mode line (GR. 0)
DL_CHR40x10x1 = $03               ; monochrome, 40 character & 10 scanlines per mode line
DL_CHR40x8x4  = $04               ; colour, 40 character & 8 scanlines per mode line (GR. 12)
DL_CHR40x16x4 = $05               ; colour, 40 character & 16 scanlines per mode line (GR. 13)
DL_CHR20x8x2  = $06               ; colour (duochrome per character), 20 character & 8 scanlines per mode line (GR. 1)
DL_CHR20x16x2 = $07               ; colour (duochrome per character), 20 character & 16 scanlines per mode line (GR. 2)

DL_MAP40x8x4  = $08               ; colour, 40 pixel & 8 scanlines per mode line (GR. 3)
DL_MAP80x4x2  = $09               ; 'duochrome', 80 pixel & 4 scanlines per mode line (GR.4)
DL_MAP80x4x4  = $0A               ; colour, 80 pixel & 4 scanlines per mode line (GR.5)
DL_MAP160x2x2 = $0B               ; 'duochrome', 160 pixel & 2 scanlines per mode line (GR.6)
DL_MAP160x1x2 = $0C               ; 'duochrome', 160 pixel & 1 scanline per mode line (GR.14)
DL_MAP160x2x4 = $0D               ; 4 colours, 160 pixel & 2 scanlines per mode line (GR.7)
DL_MAP160x1x4 = $0E               ; 4 colours, 160 pixel & 1 scanline per mode line (GR.15)
DL_MAP320x1x1 = $0F               ; monochrome, 320 pixel & 1 scanline per mode line (GR.8)

; Simplified copies of the above
DL_MODE2      = $02
DL_MODE3      = $03
DL_MODE4      = $04
DL_MODE5      = $05
DL_MODE6      = $06
DL_MODE7      = $07
DL_MODE8      = $08
DL_MODE9      = $09
DL_MODEA      = $0A
DL_MODEB      = $0B
DL_MODEC      = $0C
DL_MODED      = $0D
DL_MODEE      = $0E
DL_MODEF      = $0F

; modifiers on mode lines...

DL_HSCROL = $10
DL_VSCROL = $20
DL_LMS    = $40

; general modifier...
DL_DLI    = $80

; USA ROM Character Set
INTERNAL_BLANKSPACE     = $00
INTERNAL_EXCLAMATION    = $01
INTERNAL_DOUBLEQUOTE    = $02
INTERNAL_HASHPOUND      = $03
INTERNAL_DOLLAR         = $04
INTERNAL_PERCENT        = $05
INTERNAL_AMPERSAND      = $06
INTERNAL_SINGLEQUOTE    = $07
INTERNAL_LEFTPAREN      = $08
INTERNAL_RIGHTPAREN     = $09
INTERNAL_ASTERIX        = $0a
INTERNAL_PLUS           = $0b
INTERNAL_COMMA          = $0c
INTERNAL_MINUS          = $0d
INTERNAL_PERIOD         = $0e
INTERNAL_BACKSLASH      = $0f

INTERNAL_0              = $10
INTERNAL_1              = $11
INTERNAL_2              = $12
INTERNAL_3              = $13
INTERNAL_4              = $14
INTERNAL_5              = $15
INTERNAL_6              = $16
INTERNAL_7              = $17
INTERNAL_8              = $18
INTERNAL_9              = $19
INTERNAL_COLON          = $1a
INTERNAL_SEMICOLON      = $1b
INTERNAL_LESSTHAN       = $1c
INTERNAL_EQUAL          = $1d
INTERNAL_GREATERTHAN    = $1e
INTERNAL_QUESTION       = $1f

INTERNAL_AT             = $20
INTERNAL_UPPER_A        = $21
INTERNAL_UPPER_B        = $22
INTERNAL_UPPER_C        = $23
INTERNAL_UPPER_D        = $24
INTERNAL_UPPER_E        = $25
INTERNAL_UPPER_F        = $26
INTERNAL_UPPER_G        = $27
INTERNAL_UPPER_H        = $28
INTERNAL_UPPER_I        = $29
INTERNAL_UPPER_J        = $2a
INTERNAL_UPPER_K        = $2b
INTERNAL_UPPER_L        = $2c
INTERNAL_UPPER_M        = $2d
INTERNAL_UPPER_N        = $2e
INTERNAL_UPPER_O        = $2f

INTERNAL_UPPER_P        = $30
INTERNAL_UPPER_Q        = $31
INTERNAL_UPPER_R        = $32
INTERNAL_UPPER_S        = $33
INTERNAL_UPPER_T        = $34
INTERNAL_UPPER_U        = $35
INTERNAL_UPPER_V        = $36
INTERNAL_UPPER_W        = $37
INTERNAL_UPPER_X        = $38
INTERNAL_UPPER_Y        = $38
INTERNAL_UPPER_Z        = $3a
INTERNAL_LEFTBRACKET    = $3b
INTERNAL_FORWARDSLASH   = $3c
INTERNAL_RIGHTBRACKET   = $3d
INTERNAL_CARAT          = $3e
INTERNAL_UNDERSCORE     = $3f

INTERNAL_CTRL_COMMA     = $40
INTERNAL_CTRL_A         = $41
INTERNAL_CTRL_B         = $42
INTERNAL_CTRL_C         = $43
INTERNAL_CTRL_D         = $44
INTERNAL_CTRL_E         = $45
INTERNAL_CTRL_F         = $46
INTERNAL_CTRL_G         = $47
INTERNAL_CTRL_H         = $48
INTERNAL_CTRL_I         = $49
INTERNAL_CTRL_J         = $4a
INTERNAL_CTRL_K         = $4b
INTERNAL_CTRL_L         = $4c
INTERNAL_CTRL_M         = $4d
INTERNAL_CTRL_N         = $4e
INTERNAL_CTRL_O         = $4f

INTERNAL_CTRL_P         = $50
INTERNAL_CTRL_Q         = $51
INTERNAL_CTRL_R         = $52
INTERNAL_CTRL_S         = $53
INTERNAL_CTRL_T         = $54
INTERNAL_CTRL_U         = $55
INTERNAL_CTRL_V         = $56
INTERNAL_CTRL_W         = $57
INTERNAL_CTRL_X         = $58
INTERNAL_CTRL_Y         = $59
INTERNAL_CTRL_Z         = $5a
INTERNAL_ESCAPE         = $5b
INTERNAL_UPARROW        = $5c
INTERNAL_DOWNARROW      = $5d
INTERNAL_LEFTARROW      = $5e
INTERNAL_RIGHTARROW     = $5f

INTERNAL_CTRL_PERIOD    = $60
INTERNAL_LOWER_A        = $61
INTERNAL_LOWER_B        = $62
INTERNAL_LOWER_C        = $63
INTERNAL_LOWER_D        = $64
INTERNAL_LOWER_E        = $65
INTERNAL_LOWER_F        = $66
INTERNAL_LOWER_G        = $67
INTERNAL_LOWER_H        = $68
INTERNAL_LOWER_I        = $69
INTERNAL_LOWER_J        = $6a
INTERNAL_LOWER_K        = $6b
INTERNAL_LOWER_L        = $6c
INTERNAL_LOWER_M        = $6d
INTERNAL_LOWER_N        = $6e
INTERNAL_LOWER_O        = $6f

INTERNAL_LOWER_P        = $70
INTERNAL_LOWER_Q        = $71
INTERNAL_LOWER_R        = $72
INTERNAL_LOWER_S        = $73
INTERNAL_LOWER_T        = $74
INTERNAL_LOWER_U        = $75
INTERNAL_LOWER_V        = $76
INTERNAL_LOWER_W        = $77
INTERNAL_LOWER_X        = $78
INTERNAL_LOWER_Y        = $79
INTERNAL_LOWER_Z        = $7a
INTERNAL_CTRL_SEMICOLON = $7b
INTERNAL_TILDE          = $7c
INTERNAL_CLEARSCREEN    = $7d
INTERNAL_DELETE         = $7e
INTERNAL_TAB            = $7f

INTERNAL_INVERSE        = $80  ; Add or OR to other internal values.