	; Conapt font from https://damieng.com/zx-origins
	.byte 0,0,0,0,0,0,0,0 ;
	.byte 16,16,16,16,0,16,16,0 ; !
	.byte 36,36,72,0,0,0,0,0 ; "
	.byte 0,40,124,40,124,40,0,0 ; #
	.byte 8,60,64,124,4,120,32,0 ; $
	.byte 48,84,104,16,44,84,24,0 ; %
	.byte 56,72,72,32,76,72,116,0 ; &
	.byte 8,8,16,0,0,0,0,0 ; '
	.byte 8,16,32,32,32,16,8,0 ; (
	.byte 32,16,8,8,8,16,32,0 ; )
	.byte 0,16,84,56,84,16,0,0 ; *
	.byte 0,16,16,124,16,16,0,0 ; +
	.byte 0,0,0,0,0,16,16,32 ; ,
	.byte 0,0,0,126,0,0,0,0 ; -
	.byte 0,0,0,0,0,16,16,0 ; .
	.byte 4,4,8,16,32,64,64,0 ; /
	.byte 60,68,76,68,100,68,120,0 ; 0
	.byte 24,8,8,8,8,8,8,0 ; 1
	.byte 120,4,8,16,32,64,124,0 ; 2
	.byte 124,4,4,56,4,4,120,0 ; 3
	.byte 64,64,72,72,108,8,8,0 ; 4
	.byte 124,64,64,124,4,4,120,0 ; 5
	.byte 24,32,64,88,68,68,120,0 ; 6
	.byte 124,4,4,8,16,16,16,0 ; 7
	.byte 60,68,68,40,68,68,120,0 ; 8
	.byte 60,68,68,52,4,8,48,0 ; 9
	.byte 0,16,16,0,0,16,16,0 ; :
	.byte 0,16,16,0,0,16,16,32 ; ;
	.byte 0,8,16,32,16,8,0,0 ; <
	.byte 0,0,126,0,126,0,0,0 ; =
	.byte 0,32,16,8,16,32,0,0 ; >
	.byte 124,4,4,24,0,16,16,0 ; ?
	.byte 28,36,76,84,88,64,120,0 ; @
	.byte 60,68,68,92,68,68,68,0 ; A
	.byte 124,68,4,120,4,68,120,0 ; B
	.byte 60,68,64,64,64,68,120,0 ; C
	.byte 124,4,68,68,68,68,120,0 ; D
	.byte 124,64,0,120,0,64,124,0 ; E
	.byte 124,64,0,120,64,64,64,0 ; F
	.byte 60,68,64,76,68,68,120,0 ; G
	.byte 68,68,68,116,68,68,68,0 ; H
	.byte 16,16,16,16,16,16,16,0 ; I
	.byte 4,4,4,4,68,68,120,0 ; J
	.byte 68,68,72,80,72,68,68,0 ; K
	.byte 64,64,64,64,64,64,124,0 ; L
	.byte 60,68,84,84,84,84,84,0 ; M
	.byte 60,68,68,68,68,68,68,0 ; N
	.byte 60,68,68,68,68,68,120,0 ; O
	.byte 124,4,4,120,64,64,64,0 ; P
	.byte 60,68,68,68,68,72,116,0 ; Q
	.byte 124,4,4,120,72,68,68,0 ; R
	.byte 60,64,64,124,4,4,120,0 ; S
	.byte 124,16,16,16,16,16,16,0 ; T
	.byte 68,68,68,68,68,68,120,0 ; U
	.byte 68,68,68,68,72,80,96,0 ; V
	.byte 68,68,68,84,84,84,104,0 ; W
	.byte 68,68,40,0,40,68,68,0 ; X
	.byte 68,68,40,0,16,16,16,0 ; Y
	.byte 124,4,8,0,32,64,124,0 ; Z
	.byte 60,32,32,32,32,32,60,0 ; [
	.byte 64,64,32,16,8,4,4,0 ; \
	.byte 60,4,4,4,4,4,60,0 ; ]
	.byte 16,40,68,0,0,0,0,0 ; ^
	.byte 0,0,0,0,0,0,0,255 ; _
	.byte 60,68,64,88,64,64,124,0 ; £
	.byte 0,0,60,4,52,68,124,0 ; a
	.byte 64,64,92,68,68,68,120,0 ; b
	.byte 0,0,60,68,64,64,124,0 ; c
	.byte 4,4,52,68,68,68,120,0 ; d
	.byte 0,0,60,68,88,64,124,0 ; e
	.byte 28,32,0,120,32,32,32,0 ; f
	.byte 0,0,60,68,68,116,4,56 ; g
	.byte 64,64,92,68,68,68,68,0 ; h
	.byte 16,0,16,16,16,16,16,0 ; i
	.byte 8,0,8,8,8,8,8,112 ; j
	.byte 64,64,68,72,80,72,68,0 ; k
	.byte 24,8,8,8,8,8,8,0 ; l
	.byte 0,0,60,68,84,84,84,0 ; m
	.byte 0,0,60,68,68,68,68,0 ; n
	.byte 0,0,60,68,68,68,120,0 ; o
	.byte 0,0,60,68,68,88,64,64 ; p
	.byte 0,0,60,68,68,116,4,4 ; q
	.byte 0,0,92,68,64,64,64,0 ; r
	.byte 0,0,60,64,124,4,120,0 ; s
	.byte 32,32,120,0,32,32,60,0 ; t
	.byte 0,0,68,68,68,68,120,0 ; u
	.byte 0,0,68,68,72,80,96,0 ; v
	.byte 0,0,84,84,84,68,120,0 ; w
	.byte 0,0,68,68,40,68,68,0 ; x
	.byte 0,0,68,68,68,116,4,56 ; y
	.byte 0,0,124,8,0,32,124,0 ; z
	.byte 28,16,16,96,16,16,28,0 ; {
	.byte 16,16,16,16,16,16,16,0 ; |
	.byte 112,16,16,12,16,16,112,0 ; }
	.byte 100,84,76,0,0,0,0,0 ; ~
	.byte 63,65,157,165,161,189,130,252 ; ©
