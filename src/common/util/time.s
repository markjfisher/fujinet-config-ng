        .export     ts_to_datestr
        .export     ts_output

        .import     itoa_args
        .import     itoa_2digits

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "itoa.inc"

; converts the 4 bytes from the pagegroup packed timestamp data
; to a date/time string
; input is A/X point to 4 byte location, Y = format (0=dd/mm/yyyy, 1=mm/dd/yyyy, 2=yyyy/mm/dd)

; Format:
;  - Byte 0: Years since 1970 (0-255)
;  - Byte 1: FFFF MMMM (Flags: bit 7=directory, bits 6-4=reserved, 4 bits month 1-12)
;  - Byte 2: DDDDD HHH (5 bits day 1-31, 3 high bits of hour)
;  - Byte 3: HH mmmmmm (2 low bits hour 0-23, 6 bits minute 0-59)

; uses ptr3, tmp1, tmp2
ts_to_datestr:
    axinto  ptr3
    sty     tmp2        ; Store format parameter (0=dd/mm/yyyy, 1=mm/dd/yyyy, 2=yyyy/mm/dd)

    ; print leading 0s for all routines
    mva     #$01, itoa_args+ITOA_PARAMS::itoa_show0

    ; Check format and branch to appropriate handler
    lda     tmp2
    cmp     #2
    beq     format_yyyy
    cmp     #1  
    beq     format_mmdd
    jmp     format_ddmm

format_yyyy:
    ; YYYY/MM/DD format
    jsr     build_year
    ; Copy all 4 year characters
    lda     itoa_args+ITOA_PARAMS::itoa_buf
    sta     ts_output+0
    lda     itoa_args+ITOA_PARAMS::itoa_buf+1
    sta     ts_output+1
    lda     itoa_args+ITOA_PARAMS::itoa_buf+2
    sta     ts_output+2
    lda     itoa_args+ITOA_PARAMS::itoa_buf+3
    sta     ts_output+3
    
    jsr     build_month
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+5    ; month at 5-6
    
    jsr     build_day
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+8    ; day at 8-9
    
    ; Add slashes and space
    lda     #'/'
    sta     ts_output+4
    sta     ts_output+7
    lda     #' '
    sta     ts_output+10
    jmp     do_time

format_mmdd:
    ; MM/DD/YYYY format  
    jsr     build_month
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+0    ; month at 0-1
    
    jsr     build_day
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+3    ; day at 3-4
    
    jsr     build_year
    ; Copy all 4 year characters
    lda     itoa_args+ITOA_PARAMS::itoa_buf
    sta     ts_output+6
    lda     itoa_args+ITOA_PARAMS::itoa_buf+1
    sta     ts_output+7
    lda     itoa_args+ITOA_PARAMS::itoa_buf+2
    sta     ts_output+8
    lda     itoa_args+ITOA_PARAMS::itoa_buf+3
    sta     ts_output+9
    
    ; Add slashes and space
    lda     #'/'
    sta     ts_output+2
    sta     ts_output+5
    lda     #' '
    sta     ts_output+10
    jmp     do_time

format_ddmm:
    ; DD/MM/YYYY format (default)
    jsr     build_day
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+0    ; day at 0-1
    
    jsr     build_month
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+3    ; month at 3-4
    
    jsr     build_year
    ; Copy all 4 year characters
    lda     itoa_args+ITOA_PARAMS::itoa_buf
    sta     ts_output+6
    lda     itoa_args+ITOA_PARAMS::itoa_buf+1
    sta     ts_output+7
    lda     itoa_args+ITOA_PARAMS::itoa_buf+2
    sta     ts_output+8
    lda     itoa_args+ITOA_PARAMS::itoa_buf+3
    sta     ts_output+9
    
    ; Add slashes and space
    lda     #'/'
    sta     ts_output+2
    sta     ts_output+5
    lda     #' '
    sta     ts_output+10

do_time:
    ; -----------------------------------
    ; HH (hours)
    ; -----------------------------------

    ; extract low 3 bits of byte 2, and high 2 bits of byte 3 for Hours
    ldy     #$02
    lda     (ptr3), y
    and     #$07
    ; move left 2 bits
    asl     a
    asl     a
    sta     tmp1

    iny
    lda     (ptr3), y
    ; move right 6 bits, this is more efficient than moving and catching bits left
    lsr     a
    lsr     a
    lsr     a
    lsr     a
    lsr     a
    lsr     a
    clc
    adc     tmp1        ; add it to the temporary value to get HOURS in A

    ; convert to ascii and insert into output
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits        ; goes into itoa_buf

    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+11    ; char 11/12 for HOUR

    ; -----------------------------------
    ; : separator
    ; -----------------------------------

    mva     #':', ts_output+13

    ; -----------------------------------
    ; MM (mins)
    ; -----------------------------------

    ; lowest 6 bits of byte 3
    ldy     #$03
    lda     (ptr3), y
    and     #$3F
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits        ; goes into itoa_buf

    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+14    ; char 14/15 for MINUTES
    
    ; add string terminator
    mva     #$00, ts_output+16

    rts

; Helper functions for building date components
build_day:
    ldy     #$02
    lda     (ptr3), y
    ; upper 5 bits of byte 2 = day of month (1-31)
    lsr     a
    lsr     a
    lsr     a
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits
    rts

build_month:
    ldy     #$01
    lda     (ptr3), y
    and     #$0f        ; lower 4 bits of byte 1 = month, already 1 based
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits
    rts

build_year:
    ldy     #$00
    lda     (ptr3), y
    ; if year is below 30, we will print "19", else we will print "20" for year
    cmp     #30
    bcc     is_19xx

    ; 20xx year
    sec
    sbc     #30
    ; Now A contains the YY part (0-99)
    
    ; Set century part
    lda     #'2'
    sta     itoa_args+ITOA_PARAMS::itoa_buf
    lda     #'0'
    sta     itoa_args+ITOA_PARAMS::itoa_buf+1
    
    ; Get YY part back and convert to ASCII
    ldy     #$00
    lda     (ptr3), y
    sec
    sbc     #30
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits        ; This puts YY in itoa_buf (overwrites the "20" we just set)
    
    ; Now manually rebuild: move YY to positions 2,3 and restore "20" to positions 0,1
    lda     itoa_args+ITOA_PARAMS::itoa_buf     ; Get first Y digit
    sta     itoa_args+ITOA_PARAMS::itoa_buf+2   ; Move to position 2
    lda     itoa_args+ITOA_PARAMS::itoa_buf+1   ; Get second Y digit  
    sta     itoa_args+ITOA_PARAMS::itoa_buf+3   ; Move to position 3
    lda     #'2'
    sta     itoa_args+ITOA_PARAMS::itoa_buf     ; Restore '2' to position 0
    lda     #'0'
    sta     itoa_args+ITOA_PARAMS::itoa_buf+1   ; Restore '0' to position 1
    rts

is_19xx:
    ; 19xx year
    clc
    adc     #70
    ; Now A contains the YY part (70-99)
    
    ; Set century part  
    lda     #'1'
    sta     itoa_args+ITOA_PARAMS::itoa_buf
    lda     #'9'
    sta     itoa_args+ITOA_PARAMS::itoa_buf+1
    
    ; Get YY part back and convert to ASCII
    ldy     #$00
    lda     (ptr3), y
    clc
    adc     #70
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits        ; This puts YY in itoa_buf (overwrites the "19" we just set)
    
    ; Now manually rebuild: move YY to positions 2,3 and restore "19" to positions 0,1
    lda     itoa_args+ITOA_PARAMS::itoa_buf     ; Get first Y digit
    sta     itoa_args+ITOA_PARAMS::itoa_buf+2   ; Move to position 2
    lda     itoa_args+ITOA_PARAMS::itoa_buf+1   ; Get second Y digit
    sta     itoa_args+ITOA_PARAMS::itoa_buf+3   ; Move to position 3
    lda     #'1'
    sta     itoa_args+ITOA_PARAMS::itoa_buf     ; Restore '1' to position 0
    lda     #'9'
    sta     itoa_args+ITOA_PARAMS::itoa_buf+1   ; Restore '9' to position 1
    rts

.bss
ts_output:      .res 17     ; "dd/mm/yyyy hh:mm" with nul at end