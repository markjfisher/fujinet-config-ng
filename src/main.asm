; Load the relocatable main wherever we want 

      ; organise some zp vars
      .zpvar d_src, d_dst .word = $80
      .public d_src, d_dst

      org $3000

      .link 'libs/main_reloc.obx'
      .link 'libs/atari/os.obx'
      .link 'libs/atari/dlists.obx'
      .link 'libs/decompress.obx'

      run start