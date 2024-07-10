        .export     mw_do_setup

        .import     _clr_help
        .import     _clr_status
        .import     _put_help
        .import     _put_s
        .import     _put_status
        .import     _scr_highlight_line
        .import     kb_current_line
        .import     kb_max_entries
        .import     mw_help_setup
        .import     mw_net_count
        .import     mw_nets_msg
        .import     mw_s1
        .import     mw_selected
        .import     mw_setting_up
        .import     mw_setup_wifi
        .import     pusha

        .include    "zp.inc"
        .include    "macros.inc"
        .include    "modules.inc"

.proc mw_do_setup
        jsr     _clr_help
        put_help   #0, #mw_help_setup
        jsr     _clr_status
        put_status #0, #mw_s1

        mva     #$01, mw_setting_up     ; mark that we are now setting up wifi - various keys will now react differently

        put_s   #10, #12, #mw_nets_msg  ; print "fetching" message that will be erased when we start printing results
        jsr     mw_setup_wifi

        ; was there an error? (return = 1)
        beq     :+
        ldx     #KBH::EXIT
        rts

        ; highlight the current entry
:       mva     mw_net_count, kb_max_entries
        mva     mw_selected, kb_current_line
        jsr     _scr_highlight_line

        ; we're still on this mod, just reloop, the kbh adapts to if we're in setup mode or not
        ldx     #KBH::RELOOP
        rts
.endproc