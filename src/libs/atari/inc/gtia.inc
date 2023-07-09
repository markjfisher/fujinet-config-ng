HPOSP0 = $D000 ; Player 0 Horizontal Position
HPOSP1 = $D001 ; Player 1 Horizontal Position
HPOSP2 = $D002 ; Player 2 Horizontal Position
HPOSP3 = $D003 ; Player 3 Horizontal Position
;
HPOSM0 = $D004 ; Missile 0 Horizontal Position
HPOSM1 = $D005 ; Missile 1 Horizontal Position
HPOSM2 = $D006 ; Missile 2 Horizontal Position
HPOSM3 = $D007 ; Missile 3 Horizontal Position
;
SIZEP0 = $D008 ; Player 0 Size
SIZEP1 = $D009 ; Player 1 Size
SIZEP2 = $D00A ; Player 2 Size
SIZEP3 = $D00B ; Player 3 Size
SIZEM =  $D00C ; Missiles Sizes (2 bits per missile)
;
GRAFP0 = $D00D ; Player 0 Graphics Pattern
GRAFP1 = $D00E ; Player 1 Graphics Pattern
GRAFP2 = $D00F ; Player 2 Graphics Pattern
GRAFP3 = $D010 ; Player 3 Graphics Pattern
GRAFM =  $D011 ; Missile Graphics Pattern (2 bits per missile)
;
M0PF = $D000 ; (Read) Missile 0 to Playfield collisions
M1PF = $D001 ; (Read) Missile 1 to Playfield collisions
M2PF = $D002 ; (Read) Missile 2 to Playfield collisions
M3PF = $D003 ; (Read) Missile 3 to Playfield collisions
;
P0PF = $D004 ; (Read) Player 0 to Playfield collisions
P1PF = $D005 ; (Read) Player 1 to Playfield collisions
P2PF = $D006 ; (Read) Player 2 to Playfield collisions
P3PF = $D007 ; (Read) Player 3 to Playfield collisions
;
M0PL = $D008 ; (Read) Missile 0 to Player collisions
M1PL = $D009 ; (Read) Missile 1 to Player collisions
M2PL = $D00A ; (Read) Missile 2 to Player collisions
M3PL = $D00B ; (Read) Missile 3 to Player collisions
;
P0PL = $D00C ; (Read) Player 0 to Player collisions
P1PL = $D00D ; (Read) Player 1 to Player collisions
P2PL = $D00E ; (Read) Player 2 to Player collisions
P3PL = $D00F ; (Read) Player 3 to Player collisions
;
COLPM0 = $D012 ; Player/Missile 0 color, GTIA 9-color playfield color 0 for Background
COLPM1 = $D013 ; Player/Missile 1 color, GTIA 9-color playfield color 1
COLPM2 = $D014 ; Player/Missile 2 color, GTIA 9-color playfield color 2
COLPM3 = $D015 ; Player/Missile 3 color, GTIA 9-color playfield color 3
;
COLPF0 = $D016 ; Playfield 0 color
COLPF1 = $D017 ; Playfield 1 color
COLPF2 = $D018 ; Playfield 2 color
COLPF3 = $D019 ; Playfield 3 color (and fifth Player color)
COLBK =  $D01A ; Playfield Background color
;
TRIG0 =  $D010 ; (Read) Joystick 0 trigger  (0 is pressed. 1 is not pressed)
TRIG1 =  $D011 ; (Read) Joystick 1 trigger
TRIG2 =  $D012 ; (Read) Joystick 2 trigger
TRIG3 =  $D013 ; (Read) Joystick 3 trigger
;
PAL =    $D014 ; (Read) PAL Flag - Bit 1-3:  Clear (xxxx000x) = PAL/SECAM, Set (xxxx111x) = NTSC
PRIOR =  $D01B ; Control Priority, Fifth Player and GTIA modes
VDELAY = $D01C ; Player Missile Vertical Delay
GRACTL = $D01D ; Graphics Control, P/M DMA and joystick trigger latches
HITCLR = $D01E ; Clear Player/Missile Collisions
;
CONSOL = $D01F ; (Read) Start, Select, Option console keys.
CONSPK = $D01F ; Console speaker.
;=================================================
; OS Shadow Registers for Hardware Registers
;
STRIG0 = $0284 ; (Read) TRIG0 - Joystick 0 trigger (0 is pressed. 1 is not pressed)
STRIG1 = $0285 ; (Read) TRIG1 - Joystick 1 trigger
STRIG2 = $0286 ; (Read) TRIG2 - Joystick 2 trigger
STRIG3 = $0287 ; (Read) TRIG3 - Joystick 3 trigger
;
PCOLOR0 = $02C0 ; COLPM0 - Player/Missile 0 color, GTIA 9-color playfield color 0 for Background
PCOLOR1 = $02C1 ; COLPM1 - Player/Missile 1 color, GTIA 9-color playfield color 1
PCOLOR2 = $02C2 ; COLPM2 - Player/Missile 2 color, GTIA 9-color playfield color 2
PCOLOR3 = $02C3 ; COLPM3 - Player/Missile 3 color, GTIA 9-color playfield color 3
;
COLOR0 =  $02C4 ; COLPF0 - Playfield 0 color
COLOR1 =  $02C5 ; COLPF1 - Playfield 1 color
COLOR2 =  $02C6 ; COLPF2 - Playfield 2 color (Background for ANTIC modes 2, 3, and F)
COLOR3 =  $02C7 ; COLPF3 - Playfield 3 color (and fifth Player color)
COLOR4 =  $02C8 ; COLBK  - Playfield Background color (Border for modes 2, 3, and F)
;
GPRIOR = $026F ; PRIOR - Control Priority, Fifth Player and GTIA modes
