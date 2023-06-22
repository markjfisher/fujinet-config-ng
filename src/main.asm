; WUDSN IDE Atari Rainbow Example - MADS syntax

      org $4000 ; Start of code

start lda #0    ; Disable screen DMA
      sta 559

      doloop

      .link 'libs/loop-part.obx'

      run start ; Define run address