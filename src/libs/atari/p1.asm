    .public p1
    .reloc

p1 .proc
    lda #1
    p2
    rts
.endp

p2 .proc
    lda #2
    rts
.endp

	blk update address
	blk update public
