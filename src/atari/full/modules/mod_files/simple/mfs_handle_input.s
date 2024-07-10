        .export     mfs_handle_input

        .import     kb_global

        .import     kb_max_entries
        .import     kb_prev_mod
        .import     kb_next_mod
        .import     kb_mod_current_line_p
        .import     kb_mod_proc

        .import     mf_selected
        .import     mfs_kbh
        .import     mfs_kbh_running
        .import     pusha
        .import     pushax

        .include    "macros.inc"
        .include    "modules.inc"
        .include    "fn_data.inc"

.proc mfs_handle_input
        lda     mfs_kbh_running
        beq     :+
        
        ; don't redo kb handler if we're drilling down into directories, it just eats stack space, simply return and let the one previously setup to reloop
        ldx     #KBH::RELOOP
        rts

        ; start main keyboard handler, mark it's running so recursing into dirs doesn't cause stack issues by recursing into kb_global 
:       mva     #$01, mfs_kbh_running

        mva     #DIR_PG_CNT-1, kb_max_entries
        mva     #Mod::files, kb_prev_mod
        mva     #Mod::files, kb_next_mod
        mwa     #mf_selected, kb_mod_current_line_p
        mwa     #mfs_kbh, kb_mod_proc

        jmp     kb_global      ; rts from this will drop out of module

        ; exits with X set to kbh return value
.endproc

