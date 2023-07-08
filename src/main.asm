; Load the relocatable main wherever we want 

      ; organise some zp vars
      .zpvar d_src, d_dst .word = $80
      ; 2 general words for indirect usage
      .zpvar t1, t2 .word
      .public d_src, d_dst

      org $3000

      ; main routine
      .link 'libs/main_reloc.obx'

      ; utils
      .link 'libs/decompress.obx'

      ; modules
      .link 'libs/modules.obx'
      .link 'libs/modules/hosts.obx'

      ; atari screen
      .link 'libs/atari/os.obx'
      .link 'libs/atari/dlists.obx'

      run start