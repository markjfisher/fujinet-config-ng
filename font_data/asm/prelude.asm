	; Prelude font from https://damieng.com/zx-origins
	.byte 0,0,0,0,0,0,0,0 ;
	.byte 4,8,8,16,16,0,32,0 ; !
	.byte 36,36,72,144,0,0,0,0 ; "
	.byte 0,18,127,36,36,254,72,0 ; #
	.byte 0,8,28,34,24,68,56,16 ; $
	.byte 96,164,200,16,38,74,12,0 ; %
	.byte 24,36,72,58,68,136,118,0 ; &
	.byte 8,8,16,32,0,0,0,0 ; '
	.byte 12,16,32,64,64,64,48,0 ; (
	.byte 8,4,4,4,8,16,96,0 ; )
	.byte 0,20,24,124,48,80,0,0 ; *
	.byte 0,8,8,126,16,16,0,0 ; +
	.byte 0,0,0,0,0,8,8,16 ; ,
	.byte 0,0,0,126,0,0,0,0 ; -
	.byte 0,0,0,0,0,16,16,0 ; .
	.byte 2,4,8,16,32,64,128,0 ; /
	.byte 28,38,74,146,164,200,112,0 ; 0
	.byte 4,12,24,8,16,16,32,0 ; 1
	.byte 28,34,4,24,32,64,124,0 ; 2
	.byte 60,66,4,56,4,136,112,0 ; 3
	.byte 8,16,34,68,126,8,16,0 ; 4
	.byte 30,32,64,56,4,136,112,0 ; 5
	.byte 16,32,64,120,132,136,112,0 ; 6
	.byte 126,2,4,8,16,32,64,0 ; 7
	.byte 28,34,68,56,68,136,112,0 ; 8
	.byte 28,34,66,60,4,8,8,0 ; 9
	.byte 0,0,8,8,0,16,16,0 ; :
	.byte 0,0,8,8,0,16,16,32 ; ;
	.byte 4,8,16,32,16,16,8,0 ; <
	.byte 0,0,62,0,124,0,0,0 ; =
	.byte 16,8,8,4,8,16,32,0 ; >
	.byte 56,68,8,16,32,0,64,0 ; ?
	.byte 28,34,90,166,188,128,120,0 ; @
	.byte 12,18,34,34,60,68,68,0 ; A
	.byte 60,34,68,120,132,136,240,0 ; B
	.byte 28,34,64,128,128,136,112,0 ; C
	.byte 60,34,66,66,132,136,240,0 ; D
	.byte 62,32,64,120,128,128,248,0 ; E
	.byte 31,16,32,60,64,64,128,0 ; F
	.byte 28,34,64,156,132,136,112,0 ; G
	.byte 34,34,68,124,136,136,136,0 ; H
	.byte 28,8,16,16,32,32,112,0 ; I
	.byte 2,2,4,4,136,136,112,0 ; J
	.byte 34,36,72,112,144,136,132,0 ; K
	.byte 8,16,16,32,32,64,126,0 ; L
	.byte 51,45,41,74,82,132,132,0 ; M
	.byte 17,50,50,76,76,136,136,0 ; N
	.byte 28,34,66,130,132,136,112,0 ; O
	.byte 60,34,34,68,120,128,128,0 ; P
	.byte 28,34,66,130,148,136,118,0 ; Q
	.byte 60,34,34,76,112,136,132,0 ; R
	.byte 28,34,64,56,4,136,112,0 ; S
	.byte 62,8,8,16,16,32,32,0 ; T
	.byte 66,66,132,132,136,144,96,0 ; U
	.byte 66,66,68,72,80,96,64,0 ; V
	.byte 33,33,66,82,148,180,72,0 ; W
	.byte 66,36,40,16,40,72,132,0 ; X
	.byte 66,36,40,16,32,64,128,0 ; Y
	.byte 62,4,8,16,32,64,252,0 ; Z
	.byte 28,16,32,32,64,64,112,0 ; [
	.byte 32,32,16,16,8,8,4,0 ; \
	.byte 28,4,4,8,8,16,112,0 ; ]
	.byte 8,20,36,66,0,0,0,0 ; ^
	.byte 0,0,0,0,0,0,0,255 ; _
	.byte 12,18,32,240,64,64,252,0 ; £
	.byte 0,0,30,34,66,68,58,0 ; a
	.byte 16,32,44,82,98,196,184,0 ; b
	.byte 0,0,28,34,64,64,60,0 ; c
	.byte 1,2,50,76,132,152,104,0 ; d
	.byte 0,0,28,34,92,64,60,0 ; e
	.byte 12,18,16,120,32,64,64,0 ; f
	.byte 0,0,60,66,66,60,132,120 ; g
	.byte 32,32,92,98,66,132,132,0 ; h
	.byte 8,0,16,16,16,32,32,0 ; i
	.byte 4,0,8,8,8,16,144,96 ; j
	.byte 16,16,36,40,112,72,68,0 ; k
	.byte 8,8,16,16,32,32,24,0 ; l
	.byte 0,0,182,73,73,146,146,0 ; m
	.byte 0,0,44,50,34,68,68,0 ; n
	.byte 0,0,28,34,66,68,56,0 ; o
	.byte 0,0,44,50,66,100,152,128 ; p
	.byte 0,0,58,70,140,148,104,8 ; q
	.byte 0,0,44,50,32,64,64,0 ; r
	.byte 0,0,28,34,24,68,56,0 ; s
	.byte 16,16,124,32,64,68,56,0 ; t
	.byte 0,0,34,34,68,76,52,0 ; u
	.byte 0,0,66,68,72,80,96,0 ; v
	.byte 0,0,73,73,146,146,108,0 ; w
	.byte 0,0,34,20,24,40,68,0 ; x
	.byte 0,0,34,34,20,8,16,32 ; y
	.byte 0,0,62,4,24,32,124,0 ; z
	.byte 6,8,16,224,32,32,24,0 ; {
	.byte 4,4,8,8,16,16,32,0 ; |
	.byte 24,4,4,7,8,16,96,0 ; }
	.byte 0,0,50,76,0,0,0,0 ; ~
	.byte 30,33,93,161,186,132,120,0 ; ©
