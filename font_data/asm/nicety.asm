	; Nicety font from https://damieng.com/zx-origins
	.byte 0,0,0,0,0,0,0,0 ;
	.byte 16,16,16,16,16,0,16,0 ; !
	.byte 36,36,72,0,0,0,0,0 ; "
	.byte 40,40,124,40,124,40,40,0 ; #
	.byte 16,124,64,124,4,124,16,0 ; $
	.byte 100,104,8,16,16,38,38,0 ; %
	.byte 48,64,72,60,72,72,56,0 ; &
	.byte 16,16,32,0,0,0,0,0 ; '
	.byte 8,16,32,32,32,16,8,0 ; (
	.byte 32,16,8,8,8,16,32,0 ; )
	.byte 0,16,84,56,84,16,0,0 ; *
	.byte 0,16,16,124,16,16,0,0 ; +
	.byte 0,0,0,0,0,16,16,32 ; ,
	.byte 0,0,0,124,0,0,0,0 ; -
	.byte 0,0,0,0,0,16,16,0 ; .
	.byte 4,8,8,16,16,32,32,0 ; /
	.byte 16,40,68,68,68,40,16,0 ; 0
	.byte 16,48,16,16,16,16,16,0 ; 1
	.byte 56,68,4,8,16,32,124,0 ; 2
	.byte 124,8,16,8,4,68,56,0 ; 3
	.byte 8,24,40,72,124,8,8,0 ; 4
	.byte 124,64,120,4,4,68,56,0 ; 5
	.byte 24,32,64,120,68,68,56,0 ; 6
	.byte 124,4,8,8,16,16,16,0 ; 7
	.byte 56,68,68,56,68,68,56,0 ; 8
	.byte 56,68,68,60,4,8,48,0 ; 9
	.byte 0,0,16,16,0,16,16,0 ; :
	.byte 0,0,16,16,0,16,16,32 ; ;
	.byte 0,8,16,32,16,8,0,0 ; <
	.byte 0,0,124,0,124,0,0,0 ; =
	.byte 0,32,16,8,16,32,0,0 ; >
	.byte 56,68,4,8,0,16,16,0 ; ?
	.byte 56,68,76,84,76,64,60,0 ; @
	.byte 16,16,40,40,124,68,68,0 ; A
	.byte 120,68,68,120,68,68,120,0 ; B
	.byte 56,68,64,64,64,68,56,0 ; C
	.byte 112,72,68,68,68,72,112,0 ; D
	.byte 124,64,64,120,64,64,124,0 ; E
	.byte 124,64,64,120,64,64,64,0 ; F
	.byte 56,68,64,76,68,68,56,0 ; G
	.byte 68,68,68,124,68,68,68,0 ; H
	.byte 16,16,16,16,16,16,16,0 ; I
	.byte 4,4,4,4,68,68,56,0 ; J
	.byte 68,72,80,96,80,72,68,0 ; K
	.byte 64,64,64,64,64,64,124,0 ; L
	.byte 68,108,84,84,68,68,68,0 ; M
	.byte 68,68,100,84,76,68,68,0 ; N
	.byte 56,68,68,68,68,68,56,0 ; O
	.byte 120,68,68,120,64,64,64,0 ; P
	.byte 56,68,68,68,68,84,56,8 ; Q
	.byte 120,68,68,120,80,72,68,0 ; R
	.byte 56,68,64,56,4,68,56,0 ; S
	.byte 124,16,16,16,16,16,16,0 ; T
	.byte 68,68,68,68,68,68,56,0 ; U
	.byte 68,68,68,40,40,16,16,0 ; V
	.byte 68,68,68,84,84,108,68,0 ; W
	.byte 68,68,40,16,40,68,68,0 ; X
	.byte 68,68,40,16,16,16,16,0 ; Y
	.byte 124,4,8,16,32,64,124,0 ; Z
	.byte 56,32,32,32,32,32,56,0 ; [
	.byte 32,16,16,8,8,4,4,0 ; \
	.byte 56,8,8,8,8,8,56,0 ; ]
	.byte 16,56,84,16,16,16,16,0 ; ^
	.byte 0,0,0,0,0,0,0,255 ; _
	.byte 24,36,32,112,32,32,124,0 ; £
	.byte 0,0,48,8,56,72,56,0 ; a
	.byte 64,64,112,72,72,72,112,0 ; b
	.byte 0,0,48,72,64,72,48,0 ; c
	.byte 8,8,56,72,72,72,56,0 ; d
	.byte 0,0,48,72,120,64,56,0 ; e
	.byte 24,32,112,32,32,32,32,0 ; f
	.byte 0,0,56,72,72,56,8,48 ; g
	.byte 64,64,112,72,72,72,72,0 ; h
	.byte 16,0,48,16,16,16,16,0 ; i
	.byte 8,0,24,8,8,8,8,48 ; j
	.byte 64,64,72,80,96,80,72,0 ; k
	.byte 48,16,16,16,16,16,16,0 ; l
	.byte 0,0,104,84,84,84,84,0 ; m
	.byte 0,0,112,72,72,72,72,0 ; n
	.byte 0,0,48,72,72,72,48,0 ; o
	.byte 0,0,112,72,72,72,112,64 ; p
	.byte 0,0,56,72,72,72,56,8 ; q
	.byte 0,0,88,96,64,64,64,0 ; r
	.byte 0,0,56,64,48,8,112,0 ; s
	.byte 32,32,112,32,32,32,24,0 ; t
	.byte 0,0,72,72,72,72,56,0 ; u
	.byte 0,0,68,40,40,16,16,0 ; v
	.byte 0,0,68,68,84,84,40,0 ; w
	.byte 0,0,68,40,16,40,68,0 ; x
	.byte 0,0,72,72,72,56,8,48 ; y
	.byte 0,0,120,8,48,64,120,0 ; z
	.byte 12,16,16,96,16,16,12,0 ; {
	.byte 16,16,16,16,16,16,16,0 ; |
	.byte 96,16,16,12,16,16,96,0 ; }
	.byte 0,52,88,0,0,0,0,0 ; ~
	.byte 56,68,146,170,162,154,68,56 ; ©
