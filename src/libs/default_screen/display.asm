    .reloc
    .public setup_screen, copy_to_screen

setup_screen    .proc
    ;; TODO: generic display setup - what can we do here?
    rts
    .endp

copy_to_screen  .proc
    ; we could just print the current module's data to screen
    rts
    .endp