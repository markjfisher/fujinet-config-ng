        .export     mf_copy_end

        .import     _clr_status
        .import     _fc_strlcpy
        .import     _fc_strlen
        .import     _fn_io_copy_file
        .import     _free
        .import     _put_s
        .import     _scr_clr_highlight
        .import     fn_dir_path
        .import     mf_copy_info
        .import     mf_copying
        .import     mf_error_too_long
        .import     mh_host_selected
        .import     popa
        .import     popax
        .import     pusha
        .import     pushax
        .import     show_box
        .import     debug

        .include    "macros.inc"
        .include    "modules.inc"
        .include    "zp.inc"

.proc mf_copy_end
        ; whatever directory we're in is the target.
        ; the copy_file function allows us to JUST specify the target dir in the copy spec. Just need to check src path+file + target path + "|" all come under 256 bytes

        ; jsr     debug
        ; --------------------------------------------------
        ; PULL copySpec MEMORY LOCATION
        popax   ptr1            ; pull the memory location of the copy string
        jsr     _fc_strlen      ; how long is it?
        sta     tmp1            ; save length

        ; --------------------------------------------------
        ; PULL SELECTED HOST
        popa    tmp3            ; pull the src host slot

        ; get the current path's length
        setax   #fn_dir_path
        jsr     _fc_strlen      ; target path
        sta     tmp2            ; save length for later
        inc     tmp2            ; but increment it for nul requred by strlcpy

        clc
        adc     tmp1
        bcs     too_long
        cmp     #$fe            ; need room for "|" and nul
        bcs     too_long

        ; ok, we will be able to fit it into the allocated buffer, so let's copy bits onto it
        ; put the | at end of ptr1
        ldy     tmp1
        lda     #'|'
        sta     (ptr1), y
        inc     tmp1            ; add one for the new '/' char

        ; now copy fn_dir_path onto that
        mwa     ptr1, ptr2      ; copy ptr1 to ptr2, so we keep the memory location for _free
        adw1    ptr2, tmp1      ; move ptr2 onto end of string, including '/'
        pushax  ptr2            ; dst
        pushax  #fn_dir_path    ; src
        lda     tmp2            ; its length
        jsr     _fc_strlcpy     ; minimal copy and guarantee a 0 at the end

        ; clear the highlight
        jsr     _scr_clr_highlight
        ; show "copying" info - this is not a popup
        jsr     show_box
        put_s   #10, #6, #mf_copy_info

        ; ptr1 now points to our full copySpec string
        pusha   tmp3            ; the src host (destination)
        pusha   mh_host_selected   ; current host (target)
        setax   ptr1            ; spec
        jsr     _fn_io_copy_file

        ; now free up the location we allocated
        setax   ptr1
        jsr     _free

        ; and we are no longer copying, this will turn highlight to normal colour
        mva     #$00, mf_copying

        ; clear the status line 1
        jsr     _clr_status

        ldx     #KBH::APP_1
        rts

too_long:
        jsr     mf_error_too_long

        ldx     #KBH::APP_1
        rts

.endproc