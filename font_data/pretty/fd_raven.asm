; FONT: raven
    .byte $00, $00, $00, $00, $00, $00, $00, $00 ; space
    .byte $20, $20, $20, $20, $20, $00, $20, $00 ; !
    .byte $50, $50, $00, $00, $00, $00, $00, $00 ; "
    .byte $48, $78, $48, $48, $78, $48, $00, $00 ; #
    .byte $10, $30, $48, $20, $10, $48, $30, $20 ; $
    .byte $00, $48, $48, $10, $20, $48, $48, $00 ; %
    .byte $18, $20, $50, $38, $50, $50, $38, $00 ; &
    .byte $20, $40, $00, $00, $00, $00, $00, $00 ; '
    .byte $10, $20, $40, $40, $40, $20, $10, $00 ; (
    .byte $40, $20, $10, $10, $10, $20, $40, $00 ; )
    .byte $00, $28, $10, $7C, $10, $28, $00, $00 ; *
    .byte $00, $10, $10, $7C, $10, $10, $00, $00 ; +
    .byte $00, $00, $00, $00, $00, $00, $20, $40 ; comma
    .byte $00, $00, $00, $78, $00, $00, $00, $00 ; -
    .byte $00, $00, $00, $00, $00, $40, $40, $00 ; .
    .byte $08, $10, $10, $20, $20, $40, $40, $00 ; /
    .byte $30, $48, $48, $48, $48, $48, $30, $00 ; 0
    .byte $20, $60, $20, $20, $20, $20, $70, $00 ; 1
    .byte $30, $48, $48, $10, $20, $48, $78, $00 ; 2
    .byte $78, $08, $30, $10, $48, $48, $30, $00 ; 3
    .byte $08, $28, $48, $78, $08, $08, $08, $00 ; 4
    .byte $78, $40, $70, $08, $48, $48, $30, $00 ; 5
    .byte $30, $48, $48, $60, $50, $48, $30, $00 ; 6
    .byte $38, $48, $48, $10, $10, $20, $20, $00 ; 7
    .byte $10, $28, $48, $30, $48, $50, $20, $00 ; 8
    .byte $10, $28, $48, $38, $08, $10, $20, $00 ; 9
    .byte $00, $00, $20, $20, $00, $20, $20, $00 ; :
    .byte $00, $00, $20, $20, $00, $20, $20, $40 ; ;
    .byte $00, $10, $20, $40, $20, $10, $00, $00 ; <
    .byte $00, $00, $78, $00, $78, $00, $00, $00 ; =
    .byte $00, $40, $20, $10, $20, $40, $00, $00 ; >
    .byte $10, $28, $48, $08, $30, $00, $20, $00 ; ?
    .byte $10, $28, $58, $68, $78, $40, $38, $00 ; @
    .byte $10, $28, $48, $58, $68, $48, $48, $00 ; A
    .byte $50, $68, $50, $68, $48, $50, $60, $00 ; B
    .byte $10, $28, $48, $40, $48, $48, $30, $00 ; C
    .byte $50, $68, $48, $48, $48, $50, $60, $00 ; D
    .byte $58, $68, $40, $70, $40, $40, $78, $00 ; E
    .byte $58, $68, $40, $70, $40, $40, $40, $00 ; F
    .byte $10, $28, $40, $58, $48, $58, $28, $00 ; G
    .byte $48, $48, $58, $68, $48, $48, $48, $00 ; H
    .byte $30, $60, $20, $20, $20, $20, $70, $00 ; I
    .byte $18, $08, $08, $48, $48, $50, $20, $00 ; J
    .byte $48, $50, $50, $60, $50, $48, $48, $00 ; K
    .byte $40, $40, $40, $40, $40, $48, $78, $00 ; L
    .byte $58, $74, $54, $54, $54, $54, $54, $00 ; M
    .byte $50, $68, $48, $48, $48, $48, $48, $00 ; N
    .byte $10, $28, $48, $48, $48, $48, $30, $00 ; O
    .byte $50, $68, $48, $50, $60, $40, $40, $00 ; P
    .byte $10, $28, $48, $48, $48, $50, $28, $08 ; Q
    .byte $50, $68, $48, $50, $70, $48, $48, $00 ; R
    .byte $30, $48, $20, $10, $48, $48, $30, $00 ; S
    .byte $7C, $10, $10, $10, $10, $10, $10, $00 ; T
    .byte $48, $48, $48, $48, $48, $58, $28, $00 ; U
    .byte $48, $48, $48, $48, $48, $50, $20, $00 ; V
    .byte $44, $44, $44, $54, $54, $6C, $44, $00 ; W
    .byte $24, $24, $28, $10, $28, $48, $48, $00 ; X
    .byte $48, $48, $48, $28, $10, $10, $50, $20 ; Y
    .byte $78, $08, $10, $20, $40, $48, $78, $00 ; Z
    .byte $70, $40, $40, $40, $40, $40, $70, $00 ; [
    .byte $40, $20, $20, $10, $10, $08, $08, $00 ; \
    .byte $70, $10, $10, $10, $10, $10, $70, $00 ; ]
    .byte $10, $38, $54, $10, $10, $10, $10, $00 ; ^
    .byte $00, $00, $00, $00, $00, $00, $00, $F8 ; _
    .byte $00, $70, $8E, $FE, $FE, $FE, $FE, $00 ; dir
    .byte $03, $07, $07, $07, $07, $07, $07, $03 ; open left
    .byte $C0, $E0, $E0, $E0, $E0, $E0, $E0, $C0 ; open right
    .byte $18, $18, $18, $F8, $F8, $00, $00, $00 ; LR square
    .byte $C3, $E7, $E7, $E7, $E7, $E7, $E7, $C3 ; close-open
    .byte $00, $00, $00, $F8, $F8, $18, $18, $18 ; UR square
    .byte $00, $00, $00, $00, $01, $07, $0F, $0F ; UL corner
    .byte $00, $00, $00, $00, $80, $E0, $F0, $F0 ; UR corner
    .byte $0F, $0F, $07, $01, $00, $00, $00, $00 ; LL corner
    .byte $F0, $F0, $E0, $80, $00, $00, $00, $00 ; LR corner
    .byte $00, $00, $00, $00, $1F, $7F, $FF, $FF ; UL long
    .byte $00, $00, $00, $00, $F8, $FE, $FF, $FF ; UR long
    .byte $FF, $FF, $7F, $1F, $00, $00, $00, $00 ; LL long
    .byte $00, $00, $00, $03, $33, $33, $33, $33 ; wifi 2
    .byte $00, $30, $30, $30, $30, $30, $30, $30 ; wifi 3
    .byte $FF, $FF, $FE, $F8, $00, $00, $00, $00 ; LR long
    .byte $3F, $7B, $F9, $C0, $C0, $F9, $7B, $3F ; select arrow
    .byte $00, $00, $00, $1F, $1F, $18, $18, $18 ; UL square
    .byte $00, $00, $00, $FF, $FF, $00, $00, $00 ; horiz
    .byte $18, $18, $18, $FF, $FF, $18, $18, $18 ; h/v +
    .byte $83, $C7, $E7, $E7, $E7, $E7, $C7, $83 ; close-open ang
    .byte $00, $00, $00, $00, $FF, $FF, $FF, $FF ; half horiz
    .byte $00, $00, $00, $00, $00, $00, $03, $33 ; wifi 1
    .byte $F8, $F8, $FC, $FF, $FF, $FC, $F8, $F8 ; L sep
    .byte $1F, $1F, $3F, $FF, $FF, $3F, $1F, $1F ; R sep
    .byte $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0 ; half vert
    .byte $18, $18, $18, $1F, $1F, $00, $00, $00 ; LR corner
    .byte $78, $60, $78, $60, $7E, $18, $1E, $00 ; Esc
    .byte $00, $18, $3C, $7E, $18, $18, $18, $00 ; Up
    .byte $00, $18, $18, $18, $7E, $3C, $18, $00 ; Down
    .byte $00, $18, $30, $7E, $30, $18, $00, $00 ; Left
    .byte $00, $18, $0C, $7E, $0C, $18, $00, $00 ; Right
    .byte $18, $28, $40, $70, $40, $48, $78, $00 ; ball
    .byte $00, $00, $28, $58, $48, $58, $28, $00 ; a
    .byte $40, $40, $50, $68, $48, $68, $50, $00 ; b
    .byte $00, $00, $18, $28, $40, $40, $38, $00 ; c
    .byte $08, $08, $28, $58, $48, $58, $28, $00 ; d
    .byte $00, $00, $10, $28, $50, $60, $38, $00 ; e
    .byte $10, $28, $20, $70, $20, $20, $20, $20 ; f
    .byte $00, $00, $28, $58, $28, $18, $48, $30 ; g
    .byte $40, $40, $50, $68, $48, $48, $48, $00 ; h
    .byte $10, $00, $30, $10, $10, $10, $10, $00 ; i
    .byte $08, $00, $18, $08, $08, $08, $28, $30 ; j
    .byte $40, $40, $48, $50, $60, $50, $48, $00 ; k
    .byte $30, $10, $10, $10, $10, $10, $10, $00 ; l
    .byte $00, $00, $68, $54, $54, $54, $54, $00 ; m
    .byte $00, $00, $50, $68, $48, $48, $48, $00 ; n
    .byte $00, $00, $10, $28, $48, $48, $30, $00 ; o
    .byte $00, $00, $50, $68, $48, $68, $50, $40 ; p
    .byte $00, $00, $28, $58, $48, $58, $28, $08 ; q
    .byte $00, $00, $50, $68, $48, $40, $40, $00 ; r
    .byte $00, $00, $38, $40, $30, $08, $70, $00 ; s
    .byte $10, $10, $38, $10, $10, $10, $10, $00 ; t
    .byte $00, $00, $48, $48, $48, $58, $28, $00 ; u
    .byte $00, $00, $44, $28, $28, $10, $10, $00 ; v
    .byte $00, $00, $44, $54, $54, $28, $28, $00 ; w
    .byte $00, $00, $24, $28, $10, $28, $48, $00 ; x
    .byte $00, $00, $48, $48, $28, $10, $50, $20 ; y
    .byte $00, $00, $70, $10, $20, $40, $70, $00 ; z
    .byte $00, $0E, $18, $18, $70, $18, $18, $0E ; {
    .byte $18, $18, $18, $18, $18, $18, $18, $18 ; |
    .byte $00, $70, $18, $18, $0E, $18, $18, $70 ; }
    .byte $08, $18, $38, $78, $38, $18, $08, $00 ; L vert triangle
    .byte $10, $18, $1C, $1E, $1C, $18, $10, $00 ; R vert triangle
