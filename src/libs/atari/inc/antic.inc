;;; antic codes and addresses for display list handling

VDSLST  = $0200
SDLSTL  = $0230

dmactl	= $d400
chactl	= $d401
dlistl	= $d402
dlisth	= $d403
hscrol	= $d404
vscrol	= $d405
pmbase	= $d407
chbase	= $d409
wsync	= $d40a
vcount	= $d40b
penh	= $d40c
penv	= $d40d
nmien	= $d40e
nmist	= $d40f
nmires	= $d40f

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