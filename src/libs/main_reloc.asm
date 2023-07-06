      .extrn init_dl    .proc

      .public start
      .reloc

start
      init_dl
      jmp *