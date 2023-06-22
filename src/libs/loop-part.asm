        .public doloop
        .reloc

doloop  .proc

loop  lda $d40b ; Load VCOUNT
      clc
      adc 20    ; Add counter
      sta $d40a
      sta $d01a ; Change background color
      jmp loop

      .endp
