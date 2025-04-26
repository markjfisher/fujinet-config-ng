        .export     _cache

        .export     _find_params
        .export     _insert_params
        .export     _remove_group_params
        .export     _remove_path_params
        .export     _find_bank_params
        .export     _get_pagegroup_params
        .export     _set_path_flt_params

        .include     "page_cache.inc"

.segment "BANK"
_cache:                 .tag page_cache

; params blocks
_find_params:           .tag page_cache_find_params
_insert_params:         .tag page_cache_insert_params
_remove_group_params:   .tag page_cache_remove_group_params
_remove_path_params:    .tag page_cache_remove_path_params
_find_bank_params:      .tag page_cache_find_bank_params
_get_pagegroup_params:  .tag page_cache_get_pagegroup_params
_set_path_flt_params:   .tag page_cache_set_path_filter_params
