      .extrn io_init    .proc
      .extrn init_dl    .proc

      .public start
      .reloc

start
      io_init
      init_dl

      jmp *

      rts
