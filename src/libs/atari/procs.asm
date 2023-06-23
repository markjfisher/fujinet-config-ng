    .extrn p1 .proc

    .public p3
    .reloc

p3 .proc
    lda #3
    p1
    rts
.endp

	blk update address
	blk update external
	blk update public
