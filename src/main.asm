; Load the relocatable main wherever we want 

      org $2000
      .link 'libs/main_reloc.obx'

      run start