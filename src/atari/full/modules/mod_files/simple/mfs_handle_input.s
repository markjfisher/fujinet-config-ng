        .export     mfs_handle_input

        .import     _kb_global
        .import     mf_selected
        .import     mfs_kbh
        .import     mfs_kbh_running
        .import     pusha
        .import     pushax

        .include    "fn_macros.inc"
        .include    "fn_mods.inc"
        .include    "fn_data.inc"

.proc mfs_handle_input
        lda     mfs_kbh_running
        beq     :+
        
        ; don't redo kb handler if we're drilling down into directories, it just eats stack space, simply return and let the one previously setup to reloop
        ldx     #KBH::RELOOP
        rts

        ; start main keyboard handler, mark it's running so recursing into dirs doesn't cause stack issues by recursing into _kb_global 
:       mva     #$01, mfs_kbh_running
        pusha   #DIR_PG_CNT-1   ; we can highlight max of DIR_PG_CNT (i.e. 0 to DIR_PG_CNT - 1)
        pusha   #Mod::files     ; L/R arrow keys will be overridden by local kb handler
        pusha   #Mod::files     ; L/R arrow keys this will be overridden by local kb handler
        pushax  #mf_selected    ; memory address of our current chosen file/dir
        setax   #mfs_kbh        ; this mod's kb handler, the global kb handler will jump into this routine which will handle the interactions
        jmp     _kb_global      ; rts from this will drop out of module

        ; exits with X set to kbh return value
.endproc

