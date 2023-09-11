        .export     mw_do_setup

        .import     _put_s
        .import     _scr_highlight_line
        .import     kb_max_entries
        .import     mw_net_count
        .import     mw_nets_msg
        .import     mw_setting_up
        .import     mw_setup_wifi
        .import     pusha

        .include    "fn_macros.inc"
        .include    "fn_mods.inc"

.proc mw_do_setup
        mva     #$01, mw_setting_up     ; mark that we are now setting up wifi - various keys will now react differently

        put_s   #10, #12, #mw_nets_msg  ; print "fetching" message that ill be erased when we start printing results
        jsr     mw_setup_wifi

        ; highlight the first entry
        mva     mw_net_count, kb_max_entries
        jsr     _scr_highlight_line

        ; we're still on this mod, just reloop, the kbh adapts to if we're in setup mode or not
        ldx     #KBH::RELOOP
        rts
.endproc