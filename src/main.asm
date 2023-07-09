; Load the relocatable main wherever we want 

      ; organise some zp vars
      .zpvar d_src, d_dst .word = $80
      ; 2 general words for indirect usage
      .zpvar t1, t2 .word
      .public d_src, d_dst

      org $3000

      ; main routine
      .link 'libs/main_reloc.obx'

      ; modules
      .link 'libs/modules.obx'
      .link 'libs/modules/hosts.obx'

      ; states
      .link 'libs/states/check_wifi.obx'
      .link 'libs/states/connect_wifi.obx'
      .link 'libs/states/set_wifi.obx'
      .link 'libs/states/hosts_and_devices.obx'
      .link 'libs/states/select_file.obx'
      .link 'libs/states/select_slot.obx'
      .link 'libs/states/destination_host_slot.obx'
      .link 'libs/states/perform_copy.obx'
      .link 'libs/states/show_info.obx'
      .link 'libs/states/show_devices.obx'
      .link 'libs/states/done.obx'

      ; utils
      ; .link 'libs/decompress.obx'
      .link 'libs/run_module.obx'

      ; atari screen
      .link 'libs/atari/os.obx'
      .link 'libs/atari/dlists.obx'

      run start