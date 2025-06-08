.export test_path1
.export test_path2
.export test_filter1
.export test_filter2
.export page_cache_buf
.export null_filter
.export _set_path_flt_params

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

.bss

; Parameters struct for the function
_set_path_flt_params:
        .tag page_cache_set_path_filter_params 

page_cache_buf:     .res 2048
