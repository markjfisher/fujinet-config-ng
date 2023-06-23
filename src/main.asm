; Load the relocatable main wherever we want 

      org $3000

      .link 'libs/main_reloc.obx'
      .link 'libs/atari/os.obx'
      .link 'libs/atari/procs.obx'
      .link 'libs/atari/p1.obx'

      run start