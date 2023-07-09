; Load the relocatable main wherever we want 

      ; organise some zp vars
      .zpvar d_src, d_dst .word = $80
      ; 2 general words for indirect usage
      .zpvar t1, t2 .word
      .public d_src, d_dst

      org $3000

      ; main routine
      .link 'libs/main_loop.obx'

      ; modules
      .link 'libs/modules/modules.obx'
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

;; SCREEN ROUTINES, platform specific
; A platform needs to have a proc named "setup_screen"

.IF .DEF BUILD_ATARI
      .link 'libs/atari/dlists.obx'
      .link 'libs/atari/copy_to_screen.obx'
; add additional platform specifics here

; add a default for no build.
.ELSE
      .link 'libs/default_screen/display.obx'
.ENDIF

      run start