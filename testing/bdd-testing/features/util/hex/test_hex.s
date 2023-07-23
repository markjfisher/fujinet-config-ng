; test the hex library

        .import         hex, hexb, pusha, pushax
        .export         begin_test_word, begin_test_byte, output, t_vw
        .include        "../../../../../src/inc/macros.inc"

.proc begin_test_word
        lda t_vw
        ldx t_vw+1
        jsr pushax
        lda #<output
        ldx #>output
        jsr hex
        rts
.endproc

.proc begin_test_byte
        lda t_vw
        jsr pusha
        lda #<output
        ldx #>output
        jsr hexb
        rts
.endproc

.data
; locations for test to write to
t_vw:   .res 2

output: .res 4
