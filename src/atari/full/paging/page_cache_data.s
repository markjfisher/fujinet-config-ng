        .export     _cache

        .export     _find_params
        .export     _insert_params
        .export     _remove_group_params
        .export     _remove_path_params
        .export     _find_bank_params

        .include     "page_cache_asm.inc"

.segment "BANK"
_cache:                 .tag page_cache

; params blocks
_find_params:           .tag page_cache_find_params
_insert_params:         .tag page_cache_insert_params
_remove_group_params:   .tag page_cache_remove_group_params
_remove_path_params:    .tag page_cache_remove_path_params
_find_bank_params:      .tag page_cache_find_bank_params
