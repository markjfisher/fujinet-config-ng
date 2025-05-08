        .export     ts_to_datestr
        .export     ts_output

        .import     itoa_args
        .import     itoa_2digits

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "itoa.inc"

; converts the 4 bytes from the pagegroup packed timestamp data
; to a date/time string
; input is A/X point to 4 byte location

; Format:
;  - Byte 0: Years since 1970 (0-255)
;  - Byte 1: FFFF MMMM (4 bits flags, 4 bits month 1-12)
;           Flags: ignored for time
;  - Byte 2: DDDDD HHH (5 bits day 1-31, 3 high bits of hour)
;  - Byte 3: HH mmmmmm (2 low bits hour 0-23, 6 bits minute 0-59)

; uses ptr3, tmp1
ts_to_datestr:
    axinto  ptr3

    ; print leading 0s for all routines
    mva     #$01, itoa_args+ITOA_PARAMS::itoa_show0

    ; -----------------------------------
    ; DAY
    ; -----------------------------------
    ldy     #$02
    lda     (ptr3), y
    ; upper 5 bits of byte 2 = day of month (1-31)
    lsr     a
    lsr     a
    lsr     a
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits        ; goes into itoa_buf

    ; TODO: replace with preference for date format DD/MM or crazy MM/DD
    ldx     #$00        ; default to dd/mm obviously
    bne     day_format_mmdd

day_format_ddmm:
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+0    ; chars 0/1 for dd/mm
    bne     do_month

day_format_mmdd:
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+3    ; chars 3/4 for mm/dd

do_month:
    ; -----------------------------------
    ; MONTH
    ; -----------------------------------
    ldy     #$01
    lda     (ptr3), y
    and     #$0f        ; lower 4 bits of byte 1 = month, already 1 based
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits        ; goes into itoa_buf

    ; TODO: replace with preference for date format DD/MM or crazy MM/DD
    ldx     #$00        ; default to dd/mm obviously
    bne     mon_format_mmdd

mon_format_ddmm:
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+3    ; chars 3/4 for dd/mm
    bne     do_year

mon_format_mmdd:
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+0    ; chars 0/1 for mm/dd

do_year:
    ; -----------------------------------
    ; YEAR
    ; -----------------------------------
    ldy     #$00
    lda     (ptr3), y
    ; if year is below 30, we will print "19", else we will print "20" for year
    ; ask me in 2100 if I care
    cmp     #30
    bcc     is_19xx

    ; adjust A to be the 20YY part
    sec
    sbc     #70

    ldx     #'2'
    stx     ts_output+6
    ldx     #'0'
    stx     ts_output+7
    bne     over_19

is_19xx:
    ; adjust A to be the 19YY part
    clc
    adc     #70

    ldx     #'1'
    stx     ts_output+6
    ldx     #'9'
    stx     ts_output+7

over_19:
    ; a contains the last 2 YY part
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits        ; goes into itoa_buf
    
    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+8    ; char 8/9 for last 2 YY year digits

    ; insert the slashes
    lda     #'/'
    sta     ts_output+2
    sta     ts_output+5

    lda     #' '
    sta     ts_output+10

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

    lda     #':'
    mva     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+13

    ; -----------------------------------
    ; MM (mins)
    ; -----------------------------------

    ; lowest 6 bits of byte 3
    ldy     #$02
    lda     (ptr3), y
    and     #$3F
    sta     itoa_args+ITOA_PARAMS::itoa_input
    jsr     itoa_2digits        ; goes into itoa_buf

    mwa     itoa_args+ITOA_PARAMS::itoa_buf, ts_output+14    ; char 14/15 for MINUTES
    
    ; add string terminator
    mva     #$00, ts_output+16

    rts

.bss
ts_output:      .res 17     ; "dd/mm/yyyy hh:mm" with nul at end