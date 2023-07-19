AUDF1 = $D200 ; Audio channel 1 Frequency
AUDF2 = $D202 ; Audio channel 2 Frequency
AUDF3 = $D204 ; Audio channel 3 Frequency
AUDF4 = $D206 ; Audio channel 4 Frequency
;
AUDC1 = $D201 ; Audio channel 1 Control
AUDC2 = $D203 ; Audio channel 2 Control
AUDC3 = $D205 ; Audio channel 3 Control
AUDC4 = $D207 ; Audio channel 4 Control
;
AUDCTL = $D208 ; Audio Control
;
POT0 = $D200 ; (Read) Potentiometer (paddle) 0 
POT1 = $D201 ; (Read) Potentiometer (paddle) 1 
POT2 = $D202 ; (Read) Potentiometer (paddle) 2 
POT3 = $D203 ; (Read) Potentiometer (paddle) 3 
POT4 = $D204 ; (Read) Potentiometer (paddle) 4 
POT5 = $D205 ; (Read) Potentiometer (paddle) 5 
POT6 = $D206 ; (Read) Potentiometer (paddle) 6 
POT7 = $D207 ; (Read) Potentiometer (paddle) 7 
;
ALLPOT = $D208 ; (Read) Read 8 line POT port state
POTGO =  $D20B ; Start the POT scan sequence
;
STIMER = $D209 ; Start timers
KBCODE = $D209 ; (Read) Keyboard code
RANDOM = $D20A ; (Read) Random number
;
SKREST = $D20A ; Reset Serial Status (SKSTAT)
SEROUT = $D20D ; Serial port data output
SERIN =  $D20D ; (Read) Serial port data input
SKCTL =  $D20F ; Serial Port Control
SKSTAT = $D20F ; (Read) Serial port status
;
IRQEN = $D20E ; Interrupt Request Enable
IRQST = $D20E ; (Read) IRQ Status
;=================================================
; Shadow Registers for Hardware Registers
;
PADDL0 = $0270 ; POT0
PADDL1 = $0271 ; POT1
PADDL2 = $0272 ; POT2
PADDL3 = $0273 ; POT3
PADDL4 = $0274 ; POT4
PADDL5 = $0275 ; POT5
PADDL6 = $0276 ; POT6
PADDL7 = $0277 ; POT7
;
CH = $02FC ; KBCODE
;
POKMSK = $10 ; IRQEN
;
SSKCTL = $0232 ; SKCTL