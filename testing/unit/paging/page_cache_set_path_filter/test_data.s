.export _set_path_flt_params
.export test_path1
.export test_path2
.export test_filter1
.export test_filter2
.export _hash_string
.export page_cache_buf
.export null_filter

.include "page_cache.inc"
.include "zeropage.inc"

.data

; Test paths
test_path1:      .byte "D1:FOLDER/",0        ; Simple path
test_path2:      .byte "D2:FOLDER/SUBFOLDER/",0  ; Longer path with subfolder

; Test filters
test_filter1:    .byte "*.*",0               ; All files
test_filter2:    .byte "*.ATR",0             ; Only ATR files
null_filter:     .byte 0                     ; Empty filter

.code

; Mock hash_string function that returns predictable values based on path+filter combination:
; test_path1 + test_filter1 = $1234
; test_path1 + test_filter2 = $5678
; test_path1 + null_filter = $ABCD
; test_path2 + any_filter = $9ABC
; Otherwise returns $DEAD
.proc _hash_string
        ; Save input pointer to ptr1
        sta     ptr1
        stx     ptr1+1

        ; First check if this matches test_path1
        ldy     #0
check_path1:
        lda     (ptr1),y        ; Get char from input
        cmp     test_path1,y    ; Compare with test_path1
        bne     try_path2       ; If not equal, try path2
        cmp     #0              ; Check if we hit end
        beq     check_path1_filter ; If yes, check which filter
        iny
        bne     check_path1     ; Keep checking (max 255 chars)

check_path1_filter:
        ; Get filter pointer from params struct
        lda     _set_path_flt_params+page_cache_set_path_filter_params::filter
        sta     ptr1
        lda     _set_path_flt_params+page_cache_set_path_filter_params::filter+1
        sta     ptr1+1

        ; First check if it's a null filter
        ldy     #0
        lda     (ptr1),y
        beq     match_path1_null_filter

        ; Compare with test_filter1
check_filter1:
        lda     (ptr1),y
        cmp     test_filter1,y
        bne     check_filter2
        cmp     #0
        beq     match_path1_filter1
        iny
        bne     check_filter1

match_path1_filter1:
        ldx     #$12
        lda     #$34
        rts

match_path1_null_filter:
        ldx     #$AB
        lda     #$CD
        rts

check_filter2:
        ldy     #0
check_filter2_loop:
        lda     (ptr1),y
        cmp     test_filter2,y
        bne     no_match
        cmp     #0
        beq     match_path1_filter2
        iny
        bne     check_filter2_loop

match_path1_filter2:
        ldx     #$56
        lda     #$78
        rts

try_path2:
        ; Reset ptr1 to original path
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path
        sta     ptr1
        lda     _set_path_flt_params+page_cache_set_path_filter_params::path+1
        sta     ptr1+1

        ldy     #0
check_path2:
        lda     (ptr1),y        ; Get char from input
        cmp     test_path2,y    ; Compare with test_path2
        bne     no_match        ; If not equal, return default
        cmp     #0              ; Check if we hit end
        beq     match_path2     ; If yes, it's a match
        iny
        bne     check_path2     ; Keep checking (max 255 chars)

match_path2:
        ldx     #$9A
        lda     #$BC
        rts

no_match:
        ldx     #$DE
        lda     #$AD
        rts
.endproc

.bss

; Parameters struct for the function
_set_path_flt_params:
        .tag page_cache_set_path_filter_params 

page_cache_buf:     .res 2048
