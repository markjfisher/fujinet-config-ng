.export     _page_cache_set_path_filter

.import     _bzero
.import     _fc_strlcpy
.import     _fc_strlcpy_params
.import     _hash_string
.import     _set_path_flt_params
.import     page_cache_buf
.import     pushax

.include    "page_cache.inc"
.include    "macros.inc"
.include    "zp.inc"
.include    "fc_strlcpy.inc"

.segment "CODE2"

; --------------------------------------------------------------------
; _page_cache_set_path_filter
; calculates a new hash for the given path and filter
; so that it doesn't have to be constantly calculated every page
; but only when it changes
; Parameters:
;   path         - the directory we are browsing
;   filter       - any filter we are using for the results
; --------------------------------------------------------------------
.proc _page_cache_set_path_filter
        ; calculate a hash for the path/filter
        ; use the buffer page_cache_buf for this as it will be overwritten anyway with data if we fetch
        pushax  #page_cache_buf
        setax   #$100
        jsr     _bzero

        ; Setup fc_strlcpy params
        mwa     #page_cache_buf, _fc_strlcpy_params+fc_strlcpy_params::dst
        mwa     _set_path_flt_params+page_cache_set_path_filter_params::path, _fc_strlcpy_params+fc_strlcpy_params::src
        mva     #$e0, _fc_strlcpy_params+fc_strlcpy_params::size
        jsr     _fc_strlcpy
        sta     tmp1                    ; length actually copied

        ; see if we have a filter to copy
        mwa     _set_path_flt_params+page_cache_set_path_filter_params::filter, ptr1
        ldy     #$00
        lda     (ptr1), y
        beq     no_filter

        ; yes, so append a "|" between path and filter so we can easily hash it and the parts are separated in case there are name/filter clashes
        mwa     page_cache_buf, ptr1
        lda     #'|'
        ldy     tmp1
        sta     (ptr1), y               ; add "|" to end of string

        inc     tmp1                    ; increase size as we added an extra char
        adw1    ptr1, tmp1              ; make ptr1 point to first character after "|"

        ; Setup fc_strlcpy params for filter
        mwa     ptr1, _fc_strlcpy_params+fc_strlcpy_params::dst
        mwa     _set_path_flt_params+page_cache_set_path_filter_params::filter, _fc_strlcpy_params+fc_strlcpy_params::src
        mva     #$1f, _fc_strlcpy_params+fc_strlcpy_params::size
        jsr     _fc_strlcpy

no_filter:
        ; hash page_cache_buf
        setax   #page_cache_buf
        jsr     _hash_string

        axinto  _set_path_flt_params+page_cache_set_path_filter_params::path_hash
        rts
.endproc 