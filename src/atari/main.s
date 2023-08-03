        .export         _main, app_state
        .import         _setup_screen, run_module
        .import         check_wifi, connect_wifi, set_wifi, hosts_and_devices, select_file, select_slot, destination_host_slot, perform_copy, show_info, show_devices, done
        .include        "fn_macros.inc"
        .include        "fn_state.inc"

.proc _main
        jsr     _setup_screen

loop:
        lda     app_state
        cmp     #AppState::check_wifi
        beq     do_check_wifi

        cmp     #AppState::connect_wifi
        beq     do_connect_wifi
                ;
        cmp     #AppState::set_wifi
        beq     do_set_wifi

        cmp     #AppState::hosts_and_devices
        beq     do_hosts_and_devices

        cmp     #AppState::select_file
        beq     do_select_file

        cmp     #AppState::select_slot
        beq     do_select_slot

        cmp     #AppState::destination_host_slot
        beq     do_destination_host_slot

        cmp     #AppState::perform_copy
        beq     do_perform_copy

        cmp     #AppState::show_info
        beq     do_show_info

        cmp     #AppState::show_devices
        beq     do_show_devices

        cmp     #AppState::done
        beq     do_done


cont:
        jsr     run_module
        jmp     loop

do_check_wifi:
        jsr     check_wifi
        jmp     cont
do_connect_wifi:
        jsr     connect_wifi
        jmp     cont
do_set_wifi:
        jsr     set_wifi
        jmp     cont
do_hosts_and_devices:
        jsr     hosts_and_devices
        jmp     cont
do_select_file:
        jsr     select_file
        jmp     cont
do_select_slot:
        jsr     select_slot
        jmp     cont
do_destination_host_slot:
        jsr     destination_host_slot
        jmp     cont
do_perform_copy:
        jsr     perform_copy
        jmp     cont
do_show_info:
        jsr     show_info
        jmp     cont
do_show_devices:
        jsr     show_devices
        jmp     cont
do_done:
        jsr     done
        jmp     cont

.endproc

.data
app_state:      .byte AppState::check_wifi