.export     _main
.export     t1
.export     t1_end
.export     t2
.export     t2_end
.export     t3
.export     t3_end
.export     t4
.export     t4_end

.import     mul8

.include    "zp.inc"
.include    "macros.inc"

.code
_main:

t1:     ; Test 1: multiply 1 by 8 = 8 ($08)
        lda     #$01
        jsr     mul8
t1_end:

t2:     ; Test 2: multiply 32 by 8 = 256 ($0100)
        lda     #$20
        jsr     mul8
t2_end:

t3:     ; Test 3: multiply 255 by 8 = 2040 ($07F8)
        lda     #$FF
        jsr     mul8
t3_end:

t4:     ; Test 4: multiply 0 by 8 = 0 ($0000)
        lda     #$00
        jsr     mul8
t4_end:

        rts 