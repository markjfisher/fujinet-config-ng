.export     _main
.export     t1
.export     t1_end
.export     t2
.export     t2_end
.export     t3
.export     t3_end

.export     _cache        ; Export our test cache data

.import     _page_cache_init

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"

.segment "BANK"
_cache:         .tag    page_cache

.code
_main:

t1:     ; Test 1: Initialize with 1 bank
        ; Should set max_banks=1, entry_count=0, and bank_free_space[0,1]=0x4000
        lda     #$01
        jsr     _page_cache_init
t1_end:

t2:     ; Test 2: Initialize with max banks (64)
        ; Should set max_banks=64, entry_count=0, and all bank_free_space entries=0x4000
        lda     #64
        jsr     _page_cache_init
t2_end:

t3:     ; Test 3: Initialize with 0 banks (invalid)
        ; Should do nothing, leaving previous values unchanged
        lda     #$00
        jsr     _page_cache_init
t3_end:

        rts 