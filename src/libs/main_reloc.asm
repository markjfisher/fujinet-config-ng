      .extrn p3, io_init .proc

      .public start
      .reloc

start
      io_init
      p3
      rts
