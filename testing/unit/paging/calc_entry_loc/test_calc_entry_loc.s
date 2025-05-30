.export     _main
.export     t1
.export     t1_end
.export     t2
.export     t2_end
.export     t3
.export     t3_end

.export     _cache        ; Export our test cache data
.export     entry_loc    ; Export our entry_loc variable

.import     calc_entry_loc
.import     mul8         ; Required by calc_entry_loc

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "BSS"
entry_loc:      .res    2       ; Location of current entry

.segment "BANK"
_cache:         .tag    page_cache

.code
_main:

t1:     ; Test 1: Calculate entry location for index 0
        ; Expected: _cache+page_cache::entries + (0 * 8)
        lda     #$00
        jsr     calc_entry_loc
t1_end:

t2:     ; Test 2: Calculate entry location for index 1
        ; Expected: _cache+page_cache::entries + (1 * 8)
        lda     #$01
        jsr     calc_entry_loc
t2_end:

t3:     ; Test 3: Calculate entry location for index 31 (max entries - 1)
        ; Expected: _cache+page_cache::entries + (31 * 8)
        lda     #31
        jsr     calc_entry_loc
t3_end:

        rts 