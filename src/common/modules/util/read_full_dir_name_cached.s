        .export     read_full_dir_name_cached

        .import     _fc_strlen
        .import     _fc_strlcpy
        .import     _fc_strlcpy_params
        .import     read_full_dir_name
        .import     mf_selected
        .import     mf_fname_buf
        .import     mfp_filename_cache
        .import     mf_dir_or_file

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "fc_strlcpy.inc"

.segment "CODE2"

; Enhanced version of read_full_dir_name that uses cached filenames when possible
; Returns: AX = pointer to filename buffer
.proc read_full_dir_name_cached
        ; Check if we have cached filename data for paging version
        ; mfp_filename_cache stores pointers to filenames for current page
        ; Each entry is 2 bytes (pointer), so offset = mf_selected * 2
        
        lda     mf_selected
        asl     a               ; * 2 for 16-bit pointers
        tay
        
        ; Get the cached filename pointer
        lda     mfp_filename_cache, y
        sta     ptr1
        lda     mfp_filename_cache+1, y  
        sta     ptr1+1
        
        ; Check if pointer is valid (non-zero)
        ora     ptr1
        beq     use_fujinet     ; Null pointer means no cached data
        
        ; Copy filename from cache to mf_fname_buf
        mwa     #mf_fname_buf, _fc_strlcpy_params+fc_strlcpy_params::dst
        mwa     ptr1, _fc_strlcpy_params+fc_strlcpy_params::src
        mva     #$ff, _fc_strlcpy_params+fc_strlcpy_params::size  ; Max filename length
        jsr     _fc_strlcpy
        
        ; Check if this is a directory and add trailing slash if needed
        ldx     mf_selected
        lda     mf_dir_or_file,x
        beq     return_filename     ; 0 = file, don't add slash
        
        ; It's a directory - add trailing slash
        ; Find end of string in mf_fname_buf
        setax   #mf_fname_buf
        jsr     _fc_strlen
        tay                     ; Y = string length
        lda     #'/'
        sta     mf_fname_buf,y  ; Add slash at end
        iny
        lda     #$00
        sta     mf_fname_buf,y  ; Add null terminator
        
return_filename:
        ; Return pointer to filename buffer
        setax   #mf_fname_buf
        rts

use_fujinet:
        ; No cached data available - fall back to original FujiNet method
        jmp     read_full_dir_name
.endproc 