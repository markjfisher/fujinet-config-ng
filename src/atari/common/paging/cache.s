.export _cache

.include "page_cache.inc"

.segment "BANK"

; Main cache structure, separated from rest of data types for testing
_cache:                 .tag    page_cache
