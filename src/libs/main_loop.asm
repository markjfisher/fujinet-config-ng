      .extrn setup_screen, run_module                              .proc
      .extrn check_wifi, connect_wifi, set_wifi, hosts_and_devices .proc
      .extrn select_file, select_slot, destination_host_slot       .proc
      .extrn perform_copy, show_info, show_devices, done           .proc

      .public start
      .reloc

      icl "states/states.inc"

start
      ; each platform defines its own setup
      setup_screen

loop
      ; not sure if these needs to be called all the time, maybe only on changes?
      run_module

      ; start the main loop.
      lda state

      cmp #states.check_wifi
      beq check_wifi_t
      cmp #states.connect_wifi
      beq connect_wifi_t
      cmp #states.set_wifi
      beq set_wifi_t
      cmp #states.hosts_and_devices
      beq hosts_and_devices_t
      cmp #states.select_file
      beq select_file_t
      cmp #states.select_slot
      beq select_slot_t
      cmp #states.destination_host_slot
      beq destination_host_slot_t
      cmp #states.perform_copy
      beq perform_copy_t
      cmp #states.show_info
      beq show_info_t
      cmp #states.show_devices
      beq show_devices_t
      cmp #states.done
      beq done_t

      jmp loop

check_wifi_t
      check_wifi
      jmp loop
connect_wifi_t
      connect_wifi
      jmp loop
set_wifi_t
      set_wifi
      jmp loop
hosts_and_devices_t
      hosts_and_devices
      jmp loop
select_file_t
      select_file
      jmp loop
select_slot_t
      select_slot
      jmp loop
destination_host_slot_t
      destination_host_slot
      jmp loop
perform_copy_t
      perform_copy
      jmp loop
show_info_t
      show_info
      jmp loop
show_devices_t
      show_devices
      jmp loop
done_t
      done
      jmp loop

state dta states.check_wifi
