;=================================================
; OS and Cartridge Page 0
;=================================================
LINZBS = $00 ; word

CASINI = $02 ; word, Cassette initialization vector (and trap RESET. See $09).
RAMLO =  $04 ; word, power up memory test.  Disk boot address.

CTAFLG = $06 ; nonzero value means Left/A cartridge present
CTBFLG = $07 ; nonzero value means Right/B  cartridge present

WARMST = $08 ; Warmstart flag. 0 = powerup in progress. $FF normal reset occurred.
BOOT =   $09 ; Boot status. 0 = no boot.  
	; 1 = disk boot OK.  do reset via DOSVEC
	; 2 = cassette boot OK. do reset via CASINI
	; 3 = both successful. (trap reset via CASINI).

DOSVEC = $0A ; word. Entry vector for DOS (actually to start DUP.SYS).
DOSINI = $0C ; word. Init address for DOS or Cassette RUN address. (also trap RESET with this).

APPMHI = $0E ; word. Application high memory in use.

; POKMSK = $10 in POKEY.asm

BRKKEY = $11 ; 0 = Break pressed.  

; Real Time Clock incremented during the vertical blank.
; This is three addresses $12, $13, and $14.
; The value of $14 is incremented  every vertical blank.
; When the value of $14 reaches $FF on the next increment it rolls 
; over to $00 and then the value of $13 increments.
; $14 rollover/$13 increment occurs approximately every 4.27 seconds.
; Likewise, when the value if $13 reaches $FF and it rolls 
; over to $00,then the value of $12 increments.
; $13 rollover/$12 increment occurs approximately every 18.2 minutes.
; Jiffy count / 59.92334 for seconds.
RTCLOK =   $12 ; and $13, and $14.  
RTCLOK60 = $14 ; incremented every jiffy/frame.

BUFADR = $15 ; word.  temporary address of disk buffer
ICCOMT = $17 ; CIO command.
DSKFMS = $18 ; word. File Management System vector.
DSKUTL = $1A ; word. Disk Utilities pointer.

PTIMOT = $1C ; printer timeout.  approx 64 second per 60 values.
PBPNT =  $1D ; Printer buffer pointer.  index into buffer.
PBUFSZ = $1E ; Printer buffer size.
PTEMP =  $1F ; Temporary printer value used by print handler.

; Zero Page copy of CIO's IOCB
ICHIDZ = $20 ; Handler Index
ICDNOZ = $21 ; Device or drive number
ICCOMZ = $22 ; Command
ICSTAZ = $23 ; IOCB status result
ICBALZ = $24 ; Buffer address (lo byte)
ICBAHZ = $25 ; Buffer address (hi byte)
ICPTLZ = $26 ; Put Byte rouotine address (lo byte)
ICPTHZ = $27 ; Put Byte rouotine address (hi byte)
ICBLLZ = $28 ; Buffer length (lo byte)
ICBLHZ = $29 ; Buffer length (hi byte)
ICAX1Z = $2A ; Aux byte 1 (open parameters)
ICAX2Z = $2B ; Aux byte 2
ICAX3Z = $2C ; Aux byte 3 (BASIC Note/Point)
ICAX4Z = $2D ; Aux byte 4 (BASIC Note/Point)
ICAX5Z = $2E ; Aux byte 5
ICAX6Z = $2F ; Aux byte 6

STATUS = $30 ; SIO status
CHKSUM = $31 ; SIO data frame checksum.

BUFRLO = $32 ; SIO and DCB address of data to send or receive (lo byte)
BUFRHI = $33 ; SIO and DCB address of data to send or receive (hi byte)
BFENLO = $34 ; SIO and DCB address after BUFRLO/BUFRHI  (lo byte)
BFENHI = $35 ; SIO and DCB address after BUFRLO/BUFRHI  (hi byte)

CRETRY = $36 ; Command frame retries.  Usually $0D.
DRETRY = $37 ; Device retries.  Usually $01.

BUFRFL = $38 ; Flag buffer full. $FF is full.
RECVDN = $39 ; Flag receive done. $FF is done.
XMTDON = $3A ; Flag transmit done. $FF is done.
CHKSNT = $3B ; Flag checksum sent. $FF is sent. $00 is not sent.
NOCKSM = $3C ; Flag $00 = checksum follows data.  not zero = no checksum.

BPTR =   $3D ; Index to data in cassette buffer. 
FTYPE =  $3E ; Gap between cassette blocks. $01 to $7F = normal. $80 to $00 = short gaps.
FEOF =   $3F ; EOF for cassette. $00 = No EOF.  !$00 = EOF detected.
FREQ =   $40 ; Number of beeps for cassette start.  1 = Play.  2 = Record.
SOUNDR = $41 ; Play I/O sounds to speaker. 0 = silence.  !0 = I/O sound.

; Critical I/O flag.  
; Set to stop some automated timers and updates.
;  $00 = Normal behavior. 
; !$00 = Critical I/O mode.
; When CRITIC is set (non-zero) the following activities change:
; Stage 2/Deferred Vertical Blank Interrupt STOPS.
; (Stage 1/Immediate Vertical Blank Interrupt continues.)
; Software Timers 2, 3, 4, and 5 stop.
; Keyboard repeat disabled.
CRITIC = $42 ;  

FMZSPG = $43 ; 7 bytes up to $49. Disk FMS page 0 temporary registers (below)
ZBUFP =  $43 ; word.  Pointer to filename.
ZDRVA =  $45 ; word. Drive pointer/sector temporary value.
ZSBA =   $47 ; word. temporary sector pointer.
ERRNO =  $49 ; Disk I/O error.  FMS initializes to $9F.

CKEY =   $4A ; Cassette Cold Start to boot cassette.  Set by holding START key.
CASSBT = $4B ; Flag Cassette Boot. 0 = cassette boot unsuccessful.

DSTAT =  $4C ; status from S: handler. 

; Atari's "Attract" mode.
; After no keyboard input for several minutes the Atari OS cycles the 
; colors to prevent CRT image burn-in.  Reset this to 0 periodically
; to prevent the OS engaging the attract mode.
ATRACT = $4D

; Dark attract mask. Set to $FE/254 when attract mode is not active.
; Set to $F6/246 when attract mode is active.  This masks the 
; color lunminance bits to make screen colors stay below 50% 
; brighness. 
DRKMSK = $4E

; Color shift mask When attract mode is on the color registers are
; exclusive-OR's with the values in $4e and $4f  during the OS's 
; stage two vertical blank interrupt.  (see RTCLOK)
; When set to zero and value of DRKMSK is $f6/246, the luminance 
; is reduced 50%. COLRSH contains the value of RTCLOK+1 which is 
; incremented approximately each 4.27 seconds causing the colors
; to cycle at that period of time.       
COLRSH = $4F

TEMP =   $50 ; S: temporary value. (write character to screen)
HOLD1 =  $51 ; S: temporary value. (lines for Display List)

LMARGN = $52 ; E: left margin of GR.0 text mode and text windows
RMARGN = $53 ; E: right margin of GR.0 text mode and text windows
ROWCRS = $54 ; S: current cursor row (Y) 
COLCRS = $55 ; word.  S: current cursor column (X)

DINDEX = $57 ; S: current screen text/graphics mode
SAVMSC = $58 ; word. Address of first byte of screen memory.

OLDROW = $5A ; Previous cursor row from $54. Used for Drawto and Fill
OLDCOL = $5B ; word. Previous cursor column from $55/$56. Used for Drawto and Fill
OLDCHR = $5D ; Prior value of character at cursor
OLDADR = $5E ; word. memory location of cursor.

NEWROW = $60 ; Destination row for Drawto and Fill.
NEWCOL = $62 ; word. Destination column for Drawto and Fill.
LOGCOL = $64 ; Logical line cursor column.
ADRESS = $65 ; word. S: Temp address for Display List, copy of SAVMSC, etc.

MLTTMP = $66 ; word. Temp value for S: and in OPEN
SAVADR = $68 ; word. S: temporary value. 

RAMTOP = $6A ; First page after end of usable memory.

BUFCNT = $6B ; E: temp logical line size.
BUFSTR = $6C ; word. E: temp value

BITMSK = $6E ; S: bit mapping value
SHFAMT = $6F ; S: pixel shift amount per graphics mode
ROWAC =  $70 ; word. S: temporary row value
COLAC =  $72 ; word. S: temporary column value

ENDPT =  $74 ; word.  S: end point for Drawto.  Copy of DELTAR or DELTAC

DELTAR = $76 ; S: ABS( NEWROW - ROWCRS )
DELTAC = $77 ; word.  S: ABS( NEWCOL - COLCRS )
ROWINC = $79 ; S: Row +/- (+1 or -1) 0 is down.  $FF is up.
COLINC = $7A ; S: Column +/- (+1 or -1) 0 is right, $FF is left.

SWPFLG = $7B ; S: text window swap control. 0 = graphics. $FF = text window.
HOLDCH = $7C ; S: byte value for shifting.
INSDAT = $7D ; S: temporary character value
COUNTR = $7E ; word. S: Loop control for line drawing. Value of DELTAR or DELTAC.

;=================================================
; Atari BASIC/OSS BASIC XL values Page 0
;=================================================
LOMEM  = $80 ; word. BASIC start of memory.

;=================================================
; OS Page 2 
;=================================================
VDSLST = $0200 ; word. Display List interrupt address.

VPRCED = $0202 ; word. Peripheral proceed line vector.
VINTER = $0204 ; word. Peripheral interrupt vector.
VBREAK = $0206 ; word. BRK instruction vector.

VKEYBD = $0208 ; word. POKEY keyboard interrupt vector.
VSERIN = $020A ; word. POKEY serial I/O receive data ready interrupt vector
VSEROR = $020C ; word. POKEY serial I/O transmit data ready interrupt vector
VSEROC = $020E ; word. POKEY serial bus transmit complete interrupt vector.

; HIGH FREQUENCY POKEY TIMERS: 
; Per Mapping The Atari  
; (Timer 1/Channel 1 as example)
; 
; Store frequency base in AUDCTL/$D208/53768: 
;    $00 = 64 kilohertz, 
;    $01 = 15 kilohertz, 
;    $60 = 1.79 megahertz).
; Next, set the channel control register (AUDC1/$D201/53761). 
; Store address of interrupt routine into VTIMR1 ($210/$211). 
; Store 0 to STIMER/$D209/53769. 
; Enable the interrupt:
;    Store in POKMSK/$10 the value of POKMSK OR the interrupt number:
;       1 = timer 1 interrupt, 
;       2 = timer 2 interrupt, 
;       4 = timer 4 interrupt -- no timer 3!). 
;    Store the same value in IRQEN/$D20E/53774.
;
; An interrupt occurs when the timer counts down to zero. 
; The timer is reloaded with the original value stored there, 
; and the process begins all over again.
;
; The OS pushes the A register onto the stack before jumping 
; through the vector address. 
; X and Y are not saved. Push them on the stack if they will be used. 
; Before RTI/return from the interrupt:
;    PLA the X and Y from the stack if used
;    PLA the Accumulator, and 
;    Clear the interrupt with CLI.
VTIMR1 = $0210 ; word. POKEY timer 1 interrupt vector.
VTIMR2 = $0212 ; word. POKEY timer 2 interrupt vector.
VTIMR4 = $0214 ; word. POKEY timer 4 interrupt vector.

VIMIRQ = $0216 ; word. IRQ immediate vector.


;=================================================
; COUNTDOWN TIMERS
;===============================================================
;  TIMER    | CDTMV1  | CDTMV2  | CDTMV3   | CDTMV4  | CDTMV5  |
;---------------------------------------------------------------
; Decrement | stage 1 | stage 2 | stage 2  | stage 2 | stage 2 |
; in VBI?   |         |         |          |         |         |
;---------------------------------------------------------------
; Interrupt | CDTMA1  | CDTMA2  |          |         |         |
; Vector?   |         |         |          |         |         |
;---------------------------------------------------------------
; Countdown |         |         | CDTMF3   | CDTMF4  | CDTMF5  |
; Flag?     |         |         |          |         |         |
;---------------------------------------------------------------
; OS use?   | I/O     |  no     | cassette |  no     |  no     |
;           | timing  |         | I/O      |         |         |
;===============================================================
CDTMV1 = $0218 ; word. Countdown Timer Value 1.
CDTMV2 = $021A ; word. Countdown Timer Value 2.
CDTMV3 = $021C ; word. Countdown Timer Value 3.
CDTMV4 = $021E ; word. Countdown Timer Value 4.
CDTMV5 = $0220 ; word. Countdown Timer Value 5.

VVBLKI = $0222 ; word. VBLANK immediate interrupt vector. 
VVBLKD = $0224 ; word. VBLANK deferred interrupt vector.

CDTMA1 = $0226 ; word. System Timer 1 vector address.
CDTMA2 = $0228 ; word. System Timer 2 vector address.
CDTMF3 = $022A ; Set when CDTMV3 counts down to 0.
SRTIMR = $022B ; keyboard software repeat timer.
CDTMF4 = $022C ; Set when CDTMV4 counts down to 0.
INTEMP = $022D ; Temp value used by SETVBL.
CDTMF5 = $022E ; Set when CDTMV5 counts down to 0.

; SDMCTL = $022F in ANTIC.asm
; SDLSTL = $0230 in ANTIC.asm
; SSKCTL = $0232 in POKEY.asm
; LPENH  = $0234 in ANTIC.asm
; LPENV  = $0235 in ANTIC.asm

BRKKY =  $0236 ; Break key interrupt vector

; SIO Command Frame:
CDEVIC = $023A ; SIO Bus ID number
CCOMND = $023B ; SIO Bus command code
CAUX1 =  $023C ; Command auxiliary byte 1
CAUX2 =  $023D ; Command auxiliary byte 2

TMPSIO = $023E ; SIO temporary byte
ERRFLG = $023F ; SIO error flag (except timeout)
DFLAGS = $0240 ; Disk flags from first byte of boot sector.
DBSECT = $0241 ; Number of Boot sectors read.
BOOTAD = $0242 ; word. Address of the boot loader.

COLDST = $0244 ; Coldstart Flag. 0 = reset is warmstart.  1 = reset is coldstart.

DSKTIM = $0246 ; Disk I/O timeout countdown.

LINBUF = $0247 ; 40 characters. temporary buffer for screen data.

CSTAT =  $0288 ; Cassette status register.
WMODE =  $0289 ; Cassette Write mode.  0 = read. $80 = write
BLIM =   $028A ; Cassette Buffer Limit. character count in buffer: 0 to $80.

TXTROW = $0290 ; E: text window cursor row.
TXTCOL = $0291 ; word. E: text window cursor column.
TINDEX = $0293 ; Split-screen text window graphics mode.  
TXTMSC = $0294 ; word. Address of first byte of text window when split screen is active.
TXTOLD = $0296 ; 6 bytes -- split screen versions of OLDROW, OLDCOL (word), OLDCHR, OLDADR (word) 
TMPX1 =  $029C ; 4 bytes -- Temp values for disply handler.
DMASK =  $02A0 ; Pixel Mask per current graphics mode. 1s set for bits that correspond to pixels.

	; 11111111 -- OS Modes 0, 1, 2, 12, 13 - 1 pixel is 1 byte
	; 11110000 -- OS Modes 9, 10, 11 for GTIA - 2 pixels each byte
	; 00001111
	; 11000000 -- OS Modes 3, 5, 7, 15 - 4 pixels each byte
	; 00110000 
	; 00001100
	; 00000011
	; 10000000 -- OS modes 4, 6, 8, 14 - 8 pixels each byte
	; 01000000
	; ... up to 
	; 00000001

TMPLBT = $02A1 ; Temporary value for bit mask.
ESCFLG = $02A2 ; Set to $80 when ESC key pressed. Reset to 0 for other characters.
TABMAP = $02A3 ; 15 bytes (120 bits) One bit for each character in a logical line.  1 = tab set. 0 = no tab.
LOGMAP = $02B2 ; 4 bytes. Bits of the first 3 bytes indicate the correspoding line on screen begins a logical line. 1 = start of logical line.
INVFLG = $02B6 ; When set to $80, input from E: occurs in inverse video.
FILFLG = $02B7 ; If operation is Draw this is 0. If operation is Fill, this is !0.
TMPROW = $02B8 ; Temporary row from ROWCRS
TMPCOL = $02B9 ; word. Temporary column from COLCRS
SCRFLG = $02BB ; Count number of physical lines in a logical line removed from screen.
SHFLOK = $02BE ; $0 for lowercase. $40 for uppercase (shift). $80 for control (ctrl) 
BOTSCR = $02BF ; Number of rows available for printing. 24 for OS Mode 0.  4 for text windows.

NOCLIK = $02DB ;  keyboard click disable register; POKE with any non-zero number to disable. POKE again with 0 to enable the sound

RUNAD =   $02E0
INITAD =  $02E2

RAMSIZ = $02E4 ; Highest usable Page number (high byte)
MEMTOP = $02E5 ; word. Pointer to last byte usable by application. OS display data follows.
MEMLO =  $02E7 ; word. Pointer to start of free mememory. ($0700 default, $1CFc with DOS 2, $23DC with 850 driver)

DVSTAT = $02EA ; 4 bytes. Status registers for serial device status. Different for Disk vs 850.

CBAUDL = $02EE ; low byte cassette bps rate.
CBAUDH = $02EF ; high byte cassette bps rate.

CRSINH = $02F0 ; Cursor Inhibit.  0 = cursor on.  1 = cursor off.
KEYDEL = $02F1 ; Key delay counter. Starts at 3, decremented each frame until 0.
CH1 =    $02F2 ; Keyboard character code previously in CH/$02FC.

ATACHR = $02FA ; Last value read or written at graphics cursor.  Atascii in text modes. color number in others.  
; CH   = $$02FC ; in POKEY.asm == KBCODE - Internal keyboard code of last key pressed.  $FF is no key pressesd.
FILDAT = $02FD ; Color for the fill region.
DSPFLG = $02FE ; E: config for cursor control characters. 0 = normal operation. !0 = Display cursor controls instead of acting on them.
SSFLAG = $02FF ; Scrolling stop/start control. 0 = normal scrolling.  $FF = stop scrolling.

;; These are OS.dcb.XXX

; struct __dcb {
;     unsigned char ddevic;           /* device id */
;     unsigned char dunit;            /* unit number */
;     unsigned char dcomnd;           /* command */
;     unsigned char dstats;           /* command type / status return */
;     void          *dbuf;            /* pointer to buffer */
;     unsigned char dtimlo;           /* device timeout in seconds */
;     unsigned char dunuse;           /* - unused - */
;     unsigned int  dbyt;             /* # of bytes to transfer */
;     union {
;         struct {
;             unsigned char daux1;    /* 1st command auxiliary byte */
;             unsigned char daux2;    /* 2nd command auxiliary byte */
;         };
;         unsigned int daux;          /* auxiliary as word */
;     };
; };

DDEVIC = $0300 ; Serial bus device ID. Set by Handler.
DUNIT =  $0301 ; Device unit number. Set by user program.
DCOMND = $0302 ; Device command set by handler or the user program.
DSTATS = $0303 ; Status code for user program. Handler's data frame direction for SIO. 
DBUFLO = $0304 ; word. Data buffer address.
DBUFHI = $0305 
DTIMLO = $0306 ; Handler timeout in (approx) seconds.
DBYTLO = $0308 ; word. Number of bytes transferred to/from buffer.
DBYTHI = $0309
DAUX   = $030A ; expected to be set as a WORD to cover lo/hi
DAUX1 =  $030A ; Information specific to device.  (sector number) 
DAUX2 =  $030B ; Information specific to device.  (sector number) 

TIMER1 = $030C ; Timer for BPS rate 
ADDCOR = $030E ; Math correction for calculating bps rate 
CASFLG = $030F ; SIO Cassette mode or not. 0 = standard SIO. !0 = cassette.
TIMER2 = $0310 ; word. End timer for bps rate.
TEMP1 =  $0312 ; word. Temporary value for SIO bps calculations.
TEMP2 =  $0314 ; Temporary value
TEMP3 =  $0315 ; Temporary value
SAVIO =  $0316 ; SIO flag for bit arrival.
TIMFLG = $0317 ; Timeout for bps rate correction.
STACKP = $0318 ; SIO stack pointer.
TSTAT =  $0319 ; Temporary status.

HATABS = $031A ; 36 bytes of handler entries, 3 bytes each.

; CIO Block.  ** denotes commonly used fields **
IOCB =  $0340   ; Base IO Control Block
ICHID = IOCB+$00 ; Handler ID
ICDNO = IOCB+$01 ; Device number
ICCMD = IOCB+$02 ; ** CIO Command **
ICSTA = IOCB+$03 ; CIO Status
ICBAL = IOCB+$04 ; ** Buffer address (low) **
ICBAH = IOCB+$05 ; ** Buffer address (high) **
ICPTL = IOCB+$06 ; Put char routine (low)
ICPTH = IOCB+$07 ; Put char routine (high)
ICBLL = IOCB+$08 ; ** Buffer length (low) **
ICBLH = IOCB+$09 ; ** Buffer length (high) **
ICAX1 = IOCB+$0A ; ** Aux Byte 1 **
ICAX2 = IOCB+$0B ; ** Aux Byte 2 **
ICAX3 = IOCB+$0C ; Aux Byte 3
ICAX4 = IOCB+$0D ; Aux Byte 4
ICAX5 = IOCB+$0E ; Aux Byte 5
ICAX6 = IOCB+$0F ; Aux Byte 6

IOCB0 = IOCB  ; IOCB for channel 0
IOCB1 = $0350 ; IOCB for channel 1
IOCB2 = $0360 ; IOCB for channel 2
IOCB3 = $0370 ; IOCB for channel 3
IOCB4 = $0380 ; IOCB for channel 4
IOCB5 = $0390 ; IOCB for channel 5
IOCB6 = $03A0 ; IOCB for channel 6
IOCB7 = $03B0 ; IOCB for channel 7

; CIO block fields in other channels
ICHID1 = IOCB1+$00 ; Handler ID
ICDNO1 = IOCB1+$01 ; Device number
ICCMD1 = IOCB1+$02 ; ** CIO Command **
ICSTA1 = IOCB1+$03 ; CIO Status
ICBAL1 = IOCB1+$04 ; ** Buffer address (low) **
ICBAH1 = IOCB1+$05 ; ** Buffer address (high) **
ICPTL1 = IOCB1+$06 ; Put char routine (low)
ICPTH1 = IOCB1+$07 ; Put char routine (high)
ICBLL1 = IOCB1+$08 ; ** Buffer length (low) **
ICBLH1 = IOCB1+$09 ; ** Buffer length (high) **
ICAX11 = IOCB1+$0A ; ** Aux Byte 1 **
ICAX21 = IOCB1+$0B ; ** Aux Byte 2 **
ICAX31 = IOCB1+$0C ; Aux Byte 3
ICAX41 = IOCB1+$0D ; Aux Byte 4
ICAX51 = IOCB1+$0E ; Aux Byte 5
ICAX61 = IOCB1+$0F ; Aux Byte 6

ICHID2 = IOCB2+$00 ; Handler ID
ICDNO2 = IOCB2+$01 ; Device number
ICCMD2 = IOCB2+$02 ; ** CIO Command **
ICSTA2 = IOCB2+$03 ; CIO Status
ICBAL2 = IOCB2+$04 ; ** Buffer address (low) **
ICBAH2 = IOCB2+$05 ; ** Buffer address (high) **
ICPTL2 = IOCB2+$06 ; Put char routine (low)
ICPTH2 = IOCB2+$07 ; Put char routine (high)
ICBLL2 = IOCB2+$08 ; ** Buffer length (low) **
ICBLH2 = IOCB2+$09 ; ** Buffer length (high) **
ICAX12 = IOCB2+$0A ; ** Aux Byte 1 **
ICAX22 = IOCB2+$0B ; ** Aux Byte 2 **
ICAX32 = IOCB2+$0C ; Aux Byte 3
ICAX42 = IOCB2+$0D ; Aux Byte 4
ICAX52 = IOCB2+$0E ; Aux Byte 5
ICAX62 = IOCB2+$0F ; Aux Byte 6

ICHID3 = IOCB3+$00 ; Handler ID
ICDNO3 = IOCB3+$01 ; Device number
ICCMD3 = IOCB3+$02 ; ** CIO Command **
ICSTA3 = IOCB3+$03 ; CIO Status
ICBAL3 = IOCB3+$04 ; ** Buffer address (low) **
ICBAH3 = IOCB3+$05 ; ** Buffer address (high) **
ICPTL3 = IOCB3+$06 ; Put char routine (low)
ICPTH3 = IOCB3+$07 ; Put char routine (high)
ICBLL3 = IOCB3+$08 ; ** Buffer length (low) **
ICBLH3 = IOCB3+$09 ; ** Buffer length (high) **
ICAX13 = IOCB3+$0A ; ** Aux Byte 1 **
ICAX23 = IOCB3+$0B ; ** Aux Byte 2 **
ICAX33 = IOCB3+$0C ; Aux Byte 3
ICAX43 = IOCB3+$0D ; Aux Byte 4
ICAX53 = IOCB3+$0E ; Aux Byte 5
ICAX63 = IOCB3+$0F ; Aux Byte 6

ICHID4 = IOCB4+$00 ; Handler ID
ICDNO4 = IOCB4+$01 ; Device number
ICCMD4 = IOCB4+$02 ; ** CIO Command **
ICSTA4 = IOCB4+$03 ; CIO Status
ICBAL4 = IOCB4+$04 ; ** Buffer address (low) **
ICBAH4 = IOCB4+$05 ; ** Buffer address (high) **
ICPTL4 = IOCB4+$06 ; Put char routine (low)
ICPTH4 = IOCB4+$07 ; Put char routine (high)
ICBLL4 = IOCB4+$08 ; ** Buffer length (low) **
ICBLH4 = IOCB4+$09 ; ** Buffer length (high) **
ICAX14 = IOCB4+$0A ; ** Aux Byte 1 **
ICAX24 = IOCB4+$0B ; ** Aux Byte 2 **
ICAX34 = IOCB4+$0C ; Aux Byte 3
ICAX44 = IOCB4+$0D ; Aux Byte 4
ICAX54 = IOCB4+$0E ; Aux Byte 5
ICAX64 = IOCB4+$0F ; Aux Byte 6

ICHID5 = IOCB5+$00 ; Handler ID
ICDNO5 = IOCB5+$01 ; Device number
ICCMD5 = IOCB5+$02 ; ** CIO Command **
ICSTA5 = IOCB5+$03 ; CIO Status
ICBAL5 = IOCB5+$04 ; ** Buffer address (low) **
ICBAH5 = IOCB5+$05 ; ** Buffer address (high) **
ICPTL5 = IOCB5+$06 ; Put char routine (low)
ICPTH5 = IOCB5+$07 ; Put char routine (high)
ICBLL5 = IOCB5+$08 ; ** Buffer length (low) **
ICBLH5 = IOCB5+$09 ; ** Buffer length (high) **
ICAX15 = IOCB5+$0A ; ** Aux Byte 1 **
ICAX25 = IOCB5+$0B ; ** Aux Byte 2 **
ICAX35 = IOCB5+$0C ; Aux Byte 3
ICAX45 = IOCB5+$0D ; Aux Byte 4
ICAX55 = IOCB5+$0E ; Aux Byte 5
ICAX65 = IOCB5+$0F ; Aux Byte 6

ICHID6 = IOCB6+$00 ; Handler ID
ICDNO6 = IOCB6+$01 ; Device number
ICCMD6 = IOCB6+$02 ; ** CIO Command **
ICSTA6 = IOCB6+$03 ; CIO Status
ICBAL6 = IOCB6+$04 ; ** Buffer address (low) **
ICBAH6 = IOCB6+$05 ; ** Buffer address (high) **
ICPTL6 = IOCB6+$06 ; Put char routine (low)
ICPTH6 = IOCB6+$07 ; Put char routine (high)
ICBLL6 = IOCB6+$08 ; ** Buffer length (low) **
ICBLH6 = IOCB6+$09 ; ** Buffer length (high) **
ICAX16 = IOCB6+$0A ; ** Aux Byte 1 **
ICAX26 = IOCB6+$0B ; ** Aux Byte 2 **
ICAX36 = IOCB6+$0C ; Aux Byte 3
ICAX46 = IOCB6+$0D ; Aux Byte 4
ICAX56 = IOCB6+$0E ; Aux Byte 5
ICAX66 = IOCB6+$0F ; Aux Byte 6

ICHID7 = IOCB7+$00 ; Handler ID
ICDNO7 = IOCB7+$01 ; Device number
ICCMD7 = IOCB7+$02 ; ** CIO Command **
ICSTA7 = IOCB7+$03 ; CIO Status
ICBAL7 = IOCB7+$04 ; ** Buffer address (low) **
ICBAH7 = IOCB7+$05 ; ** Buffer address (high) **
ICPTL7 = IOCB7+$06 ; Put char routine (low)
ICPTH7 = IOCB7+$07 ; Put char routine (high)
ICBLL7 = IOCB7+$08 ; ** Buffer length (low) **
ICBLH7 = IOCB7+$09 ; ** Buffer length (high) **
ICAX17 = IOCB7+$0A ; ** Aux Byte 1 **
ICAX27 = IOCB7+$0B ; ** Aux Byte 2 **
ICAX37 = IOCB7+$0C ; Aux Byte 3
ICAX47 = IOCB7+$0D ; Aux Byte 4
ICAX57 = IOCB7+$0E ; Aux Byte 5
ICAX67 = IOCB7+$0F ; Aux Byte 6

; CIO Common Device Commands
CIO_OPEN =       $03
CIO_GET_RECORD = $05
CIO_GET_BYTES =  $07
CIO_PUT_RECORD = $09
CIO_PUT_BYTES =  $0B
CIO_CLOSE =      $0C
CIO_STATUS =     $0D
CIO_SPECIAL =    $0E

; CIO Device Commands for D:
CIO_D_RENAME =      $20 ; Rename a file
CIO_D_DELETE =      $21 ; Delete the named file
CIO_D_LOCK =        $23 ; Lock/protect the file
CIO_D_UNLOCK =      $24 ; unlock/unprotect the file

CIO_D_POINT =       $25 ; Move to sector/byte position
CIO_D_NOTE =        $26 ; Get current sector/byte position

CIO_D_FILELEN =     $27 ; Get file length
CIO_D_CD_MYDOS =    $29 ; MyDos cd (change directory)
CIO_D_MKDIR_MYDOS = $2A ; MyDos (and SpartaDos) mkdir (make directory)
CIO_D_RMDIR_SPDOS = $2B ; SpartaDos rmdir (remove directory)
CIO_D_CD_SPDOS    = $2C ; SpartaDos cd (change directory)
CIO_D_PWD_MYDOS   = $30 ; MyDos (and SpartaDos) print/get working directory 

CIO_D_FORMAT =      $FE ; Format Disk

; CIO Device Commands for S:
CIO_S_DRAWTO = $11
CIO_S_FILL =   $12

; ICAX1 Common Options (OPEN modes).
CIO_ICAX_READ      = $04
CIO_ICAX_WRITE     = $08 ; READ + WRITE starts I/O at first byte.

; ICAX1 Less Common Options (OPEN modes.)
CIO_ICAX_E_FORCED     = $01 ; E: FORCED input. Usually with READ + WRITE.
CIO_ICAX_D_APPEND     = $01 ; D: Write starts at end of file. Usually with READ + WRITE.
CIO_ICAX_D_DIRECTORY  = $02 ; D: DIRECTORY.  Use with READ. 

CIO_ICAX_S_TEXTWINDOW = $10 ; S: Open graphics mode with text window. Ignored for 0, 9, 10, 11.
CIO_ICAX_S_DONOTCLEAR = $20 ; S: Suppress clear screen for graphics mode. 

CASBUF = $03FD ; 128 bytes up to $047F (ends in page 4)
CARTB =  $8000 ; Start of Cart B/Right Cart (8K)
CRBSTA = $9FFA ; word. Cart B/Right Start address.
CRBFLG = $9FFC ; Cart B/right present.  Copied to $7 CTBFLG
CRBBTF = $9FFD ; Cart B/right Boot Option bits. $1 = boot disk. $4 = Boot cart. $80 = diagnostic cart 
CRBINI = $9FFE ; word. Init address for Cart B/Right for cold boot/warm start

CARTA =  $A000 ; Start of Cart A/Left Cart (8K)
CRASTA = $BFFA ; word. Cart A/Left Start address.
CRAFLG = $BFFC ; Cart A/Left present.  Copied to $6 CTAFLG
CRABTF = $BFFD ; Cart A/Left Boot Option bits. $01 = boot disk. $04 = Boot cart. $80 = diagnostic cart 
CRAINI = $BFFE ; word. Init address for Cart A/Left for cold boot/warm start

EDITRV = $E400 ; Screen editor vector table.
SCRENV = $E410 ; Screen editor vector table.
KEYBDV = $E420 ; Screen editor vector table.
PRINTV = $E430 ; Screen editor vector table.
CASETV = $E440 ; Screen editor vector table.
DISKIV = $E450 ; JMP vector for disk handler init
DSKINV = $E453 ; JMP vector for disk handler interface.
CIOV =   $E456 ; JSR vector for CIO. All CIO operations go through this address.
SIOV =   $E459 ; JMP vector for SIO.
SETVBV = $E45C ; JSR Vector to set timers
SYSVBV = $E45F ; JMP to end user Immediate VBI
XITVBV = $E462 ; JMP Vector to end user Deferred VBI

WARMSV = $E474 ; Usr() here will warmstart.
COLDSV = $E477 ; Usr() here to cold boot the system.
