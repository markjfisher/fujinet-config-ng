        .export     mf_copy_start

        .import     _fc_strncpy
        .import     combine_path_with_selection
        .import     fuji_buffer
        .import     mf_copy_buf
        .import     mf_copying
        .import     mf_error_too_long
        .import     mh_host_selected
        .import     pusha
        .import     pushax
        .import     debug

        .include    "macros.inc"
        .include    "modules.inc"
        .include    "zp.inc"

.proc mf_copy_start
        ; jsr     debug
        ; is the path too long? interesting dilemma. the copy spec eventually sent to FN has to be under 256 bytes. we'll check that at the end
        lda     #$fc                ; the copy spec will have minimally an extra "|/" 2 chars (pipe, root dir), so reduce $ff by that and nul char
        jsr     combine_path_with_selection
        bne     @too_long_error

        pusha   mh_host_selected    ; Saved so we can navigate to different host, and pulled back in mf_copy_end

        pushax  #mf_copy_buf        ; dst
        pushax  #fuji_buffer        ; src: path/file
        lda     #$00                ; this is a 256 byte copy (0-ff) filling up to the end with 0's
        jsr     _fc_strncpy         ; copy into memory allocated

        ; save the fact we are copying so that highlights etc change for us
        mva     #$01, mf_copying
        rts

@too_long_error:
        jmp     mf_error_too_long

.endproc
