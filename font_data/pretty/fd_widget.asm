; FONT: widget
    .byte $00, $00, $00, $00, $00, $00, $00, $00 ; space
    .byte $10, $10, $10, $10, $00, $10, $10, $00 ; !
    .byte $24, $24, $24, $00, $00, $00, $00, $00 ; "
    .byte $28, $28, $7C, $28, $7C, $28, $28, $00 ; #
    .byte $08, $3C, $40, $7C, $04, $78, $20, $00 ; $
    .byte $64, $64, $08, $10, $20, $4C, $4C, $00 ; %
    .byte $30, $48, $48, $30, $4C, $48, $34, $00 ; &
    .byte $18, $08, $10, $00, $00, $00, $00, $00 ; '
    .byte $08, $10, $20, $20, $20, $10, $08, $00 ; (
    .byte $20, $10, $08, $08, $08, $10, $20, $00 ; )
    .byte $00, $10, $54, $38, $54, $10, $00, $00 ; *
    .byte $00, $10, $10, $7C, $10, $10, $00, $00 ; +
    .byte $00, $00, $00, $00, $00, $18, $08, $10 ; comma
    .byte $00, $00, $00, $7C, $00, $00, $00, $00 ; -
    .byte $00, $00, $00, $00, $00, $18, $18, $00 ; .
    .byte $04, $04, $08, $10, $10, $20, $40, $40 ; /
    .byte $3C, $44, $4C, $54, $64, $44, $78, $00 ; 0
    .byte $10, $30, $10, $10, $10, $10, $38, $00 ; 1
    .byte $78, $44, $08, $10, $20, $44, $7C, $00 ; 2
    .byte $7C, $44, $04, $18, $04, $44, $78, $00 ; 3
    .byte $08, $18, $28, $48, $7C, $08, $08, $00 ; 4
    .byte $7C, $44, $40, $78, $04, $44, $38, $00 ; 5
    .byte $08, $10, $20, $78, $44, $44, $38, $00 ; 6
    .byte $7C, $44, $04, $08, $10, $10, $10, $00 ; 7
    .byte $38, $44, $44, $38, $44, $44, $38, $00 ; 8
    .byte $38, $44, $44, $3C, $08, $10, $20, $00 ; 9
    .byte $00, $18, $18, $00, $00, $18, $18, $00 ; :
    .byte $00, $18, $18, $00, $00, $18, $08, $10 ; ;
    .byte $00, $08, $10, $20, $10, $08, $00, $00 ; <
    .byte $00, $00, $7C, $00, $7C, $00, $00, $00 ; =
    .byte $00, $20, $10, $08, $10, $20, $00, $00 ; >
    .byte $78, $44, $04, $18, $00, $10, $10, $00 ; ?
    .byte $38, $44, $5C, $54, $5C, $40, $3C, $00 ; @
    .byte $10, $28, $44, $44, $7C, $44, $44, $00 ; A
    .byte $78, $24, $24, $38, $24, $24, $78, $00 ; B
    .byte $3C, $44, $40, $40, $40, $44, $3C, $00 ; C
    .byte $78, $24, $24, $24, $24, $24, $78, $00 ; D
    .byte $7C, $24, $20, $38, $20, $24, $7C, $00 ; E
    .byte $7C, $24, $20, $38, $20, $20, $70, $00 ; F
    .byte $3C, $44, $40, $4C, $44, $4C, $34, $00 ; G
    .byte $44, $44, $44, $7C, $44, $44, $44, $00 ; H
    .byte $7C, $10, $10, $10, $10, $10, $7C, $00 ; I
    .byte $1C, $08, $08, $08, $48, $48, $30, $00 ; J
    .byte $44, $48, $50, $60, $50, $48, $44, $00 ; K
    .byte $70, $20, $20, $20, $20, $24, $7C, $00 ; L
    .byte $44, $6C, $54, $54, $44, $44, $44, $00 ; M
    .byte $44, $64, $64, $54, $4C, $4C, $44, $00 ; N
    .byte $38, $44, $44, $44, $44, $44, $38, $00 ; O
    .byte $78, $24, $24, $38, $20, $20, $70, $00 ; P
    .byte $38, $44, $44, $44, $44, $48, $38, $04 ; Q
    .byte $78, $24, $24, $38, $28, $24, $74, $00 ; R
    .byte $3C, $44, $40, $38, $04, $44, $78, $00 ; S
    .byte $7C, $54, $10, $10, $10, $10, $38, $00 ; T
    .byte $44, $44, $44, $44, $44, $44, $38, $00 ; U
    .byte $44, $44, $44, $28, $28, $10, $10, $00 ; V
    .byte $44, $44, $44, $54, $54, $54, $28, $00 ; W
    .byte $44, $44, $28, $10, $28, $44, $44, $00 ; X
    .byte $44, $44, $44, $28, $10, $10, $10, $00 ; Y
    .byte $7C, $44, $08, $10, $20, $44, $7C, $00 ; Z
    .byte $38, $20, $20, $20, $20, $20, $20, $38 ; [
    .byte $40, $40, $20, $10, $10, $08, $04, $04 ; \
    .byte $38, $08, $08, $08, $08, $08, $08, $38 ; ]
    .byte $10, $38, $54, $10, $10, $10, $10, $00 ; ^
    .byte $00, $00, $00, $00, $00, $00, $00, $FE ; _
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
    .byte $1C, $24, $20, $78, $20, $24, $7C, $00 ; ball
    .byte $00, $00, $38, $04, $3C, $44, $3C, $00 ; a
    .byte $40, $40, $58, $64, $44, $44, $78, $00 ; b
    .byte $00, $00, $38, $44, $40, $44, $38, $00 ; c
    .byte $0C, $04, $34, $4C, $44, $44, $3C, $00 ; d
    .byte $00, $00, $38, $44, $7C, $40, $3C, $00 ; e
    .byte $1C, $24, $20, $78, $20, $20, $20, $00 ; f
    .byte $00, $00, $34, $4C, $44, $3C, $04, $38 ; g
    .byte $40, $40, $58, $64, $44, $44, $44, $00 ; h
    .byte $10, $00, $30, $10, $10, $10, $18, $00 ; i
    .byte $08, $00, $18, $08, $08, $08, $48, $70 ; j
    .byte $40, $40, $44, $48, $70, $48, $44, $00 ; k
    .byte $30, $10, $10, $10, $10, $10, $18, $00 ; l
    .byte $00, $00, $68, $54, $54, $54, $54, $00 ; m
    .byte $00, $00, $58, $64, $44, $44, $44, $00 ; n
    .byte $00, $00, $38, $44, $44, $44, $38, $00 ; o
    .byte $00, $00, $58, $64, $44, $78, $40, $40 ; p
    .byte $00, $00, $34, $4C, $44, $3C, $04, $04 ; q
    .byte $00, $00, $5C, $64, $40, $40, $40, $00 ; r
    .byte $00, $00, $3C, $40, $38, $04, $78, $00 ; s
    .byte $20, $20, $78, $20, $20, $24, $1C, $00 ; t
    .byte $00, $00, $44, $44, $44, $4C, $34, $00 ; u
    .byte $00, $00, $44, $44, $28, $28, $10, $00 ; v
    .byte $00, $00, $44, $44, $54, $54, $28, $00 ; w
    .byte $00, $00, $44, $28, $10, $28, $44, $00 ; x
    .byte $00, $00, $44, $44, $28, $28, $10, $60 ; y
    .byte $00, $00, $3C, $24, $08, $10, $3C, $00 ; z
    .byte $00, $0E, $18, $18, $70, $18, $18, $0E ; {
    .byte $18, $18, $18, $18, $18, $18, $18, $18 ; |
    .byte $00, $70, $18, $18, $0E, $18, $18, $70 ; }
    .byte $08, $18, $38, $78, $38, $18, $08, $00 ; L vert triangle
    .byte $10, $18, $1C, $1E, $1C, $18, $10, $00 ; R vert triangle
