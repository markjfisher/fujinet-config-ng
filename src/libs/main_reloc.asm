        .reloc
        .public start

start lda #0    ; Disable screen DMA
      sta 559

loop  lda $d40b ; Load VCOUNT
      clc
      adc 20    ; Add counter
      sta $d40a
      sta $d01a ; Change background color
      jmp loop

      blk update address
      blk update public
