    .public io_init
    .reloc

; Yet to decide if a struct is better than just constants
__os  .struct
    _f1 :559 .byte          ; skip $0000-$022e
    
    sdmctl .byte            ; $022f
    
    _f2 :20 .byte           ; skip $0230-$0243
    
    coldst .byte            ; $0244
    
    _f3 :121 .byte          ; skip $0245-$02bd
    
    shflok .byte            ; $02be
    
    _f4 :5 .byte            ; skip $02bf-$02c3
    
    color0 .byte            ; $02c4
    color1 .byte            ; $02c5
    color2 .byte            ; $02c6
    color3 .byte            ; $02c7
    color4 .byte            ; $02c8

    _f5 :18 .byte           ; skip $02c9-$02da

    noclik .byte            ; $02db
.ends

io_init     .proc
    mva #$ff __os.noclik
    mva #$00 __os.shflok
    mva #$9f __os.color0
    mva #$0f __os.color1
    mva #$90 __os.color2
    mva #$90 __os.color4
    ; mva #$01 __os.coldst
    ; mva #$00 __os.sdmctl
    rts
.endp

	blk update address
	blk update public
