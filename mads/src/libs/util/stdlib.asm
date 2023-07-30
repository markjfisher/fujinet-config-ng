; a place for common standard functions from string, stdlib etc.

        opt r+
        .extrn t1, t2 .byte
        .public _fn_strncpy, _fn_strncat, _fn_strncpy.n, _fn_strncat.n
        .reloc

; ########################################################################
; _fn_strncpy
; Copies the first n characters of source to destination. If the end of the
; source C string (which is signaled by a null-character) is found before num
; characters have been copied, destination is padded with zeros until a total
; of n characters have been written to it.

; No null-character is implicitly appended at the end of destination if source
; is longer than n. Thus, in this case, destination shall not be considered a
; null terminated C string (reading it as such would overflow).
;
; Example:
;    _fn_strncpy #src #dst #10
; src :32 .byte
; dst :32 .byte

.proc _fn_strncpy ( .word t1, t2 .byte n ) .var
        .var n .byte    ; count of chars to copy

start
        ldy #0
@       mva (t2),y (t1),y
        beq fill_zeroes     ; hit a nul char
        iny
        cpy n
        bne @-
        beq out
fill_zeroes
        ; carry on up to n with 0s
        ; again, opt r+ not doing much here, split the lda/sta manually
        lda #$00
@       iny
        cpy n
        beq out
        sta (t1),y
        bne @-              ; always branch
out
        rts
        .endp

; ########################################################################
; _fn_strncat
; The _fn_strncat function appends not more than n characters of the string
; pointed to by t2 to the end of the string pointed to by t1. The terminating
; null character at the end of s1 is overwritten. A terminating null character
; is appended to the result, even if not all of s2 is appended to s1.
;
; returns a = 0 if no error, 1 otherwise (didn't find nul in dst) 
;
; Example:
;    _fn_strncat #src #dst #10
; src :32  .byte
; dst :256 .byte

.proc _fn_strncat ( .word t1, t2 .byte n ) .var
        .var n .byte

        ; find first nul char in dst (t1)
        ldy #$00
@       lda (t1), y
        beq found
        iny
        ; rolled around to 0 and didn't find anything
        beq error
        bne @-

found   tya
        clc
        adc t1
        sta t1
        scc:inc t1+1

        ; copy the string to location found
        ; can only copy n chars max, including a nul
        ; subtract 1 from n, as we will only copy 1 less chars if possible
        dec n
        ldy #0
@       mva (t2),y (t1),y
        beq out             ; we copied a nul before n reached, we can end now
        iny
        cpy n
        bne @-              ; haven't reached n yet

        ; add the nul, as we didn't encounter one, but reached max
        mva #$00 (t1),y
out
        lda #$00
        rts

error   lda #$01
        rts
        .endp
