	; Wand font from https://damieng.com/zx-origins
	.byte 0,0,0,0,0,0,0,0 ;  
	.byte 12,8,8,16,0,32,32,0 ; !
	.byte 20,20,40,0,0,0,0,0 ; "
	.byte 0,72,120,72,72,120,72,0 ; #
	.byte 4,12,20,8,36,56,16,0 ; $
	.byte 36,40,8,16,32,40,72,0 ; %
	.byte 12,20,16,28,36,40,52,0 ; &
	.byte 8,8,16,0,0,0,0,0 ; '
	.byte 8,16,16,32,32,32,16,0 ; (
	.byte 8,4,4,4,8,8,16,0 ; )
	.byte 0,20,8,44,16,40,0,0 ; *
	.byte 0,8,8,60,16,16,0,0 ; +
	.byte 0,0,0,0,0,16,16,32 ; ,
	.byte 0,0,0,60,0,0,0,0 ; -
	.byte 0,0,0,0,0,16,16,0 ; .
	.byte 4,8,8,16,16,32,32,0 ; /
	.byte 12,20,20,36,36,40,16,0 ; 0
	.byte 4,24,8,8,16,16,16,0 ; 1
	.byte 12,20,4,8,16,36,56,0 ; 2
	.byte 12,20,8,24,4,36,56,0 ; 3
	.byte 8,16,20,36,60,8,8,0 ; 4
	.byte 14,8,16,24,4,4,56,0 ; 5
	.byte 12,16,16,44,52,36,56,0 ; 6
	.byte 28,36,4,8,8,16,16,0 ; 7
	.byte 12,20,20,24,36,36,56,0 ; 8
	.byte 28,36,44,52,8,8,48,0 ; 9
	.byte 0,8,8,0,16,16,0,0 ; :
	.byte 0,8,8,0,0,16,16,32 ; ;
	.byte 0,8,16,32,16,16,8,0 ; <
	.byte 0,0,60,0,120,0,0,0 ; =
	.byte 0,32,16,24,16,32,32,0 ; >
	.byte 12,20,4,24,0,32,32,0 ; ?
	.byte 12,20,28,52,44,32,24,0 ; @
	.byte 12,20,20,36,60,36,36,0 ; A
	.byte 12,20,20,40,52,36,56,0 ; B
	.byte 12,20,20,32,32,32,28,0 ; C
	.byte 8,20,20,36,36,36,56,0 ; D
	.byte 12,20,16,40,48,36,56,0 ; E
	.byte 12,20,16,56,32,32,32,0 ; F
	.byte 12,20,16,36,36,36,24,0 ; G
	.byte 18,36,36,60,68,72,72,0 ; H
	.byte 4,8,8,8,16,16,16,0 ; I
	.byte 12,8,8,8,16,80,96,0 ; J
	.byte 36,40,40,48,80,72,72,0 ; K
	.byte 8,16,16,32,32,36,24,0 ; L
	.byte 22,42,42,66,66,68,68,0 ; M
	.byte 12,20,20,36,36,36,36,0 ; N
	.byte 12,20,20,36,36,40,16,0 ; O
	.byte 12,20,20,40,48,32,32,0 ; P
	.byte 12,20,20,36,36,40,28,4 ; Q
	.byte 12,20,20,40,48,40,36,0 ; R
	.byte 12,20,16,8,4,36,56,0 ; S
	.byte 30,8,8,8,16,16,16,0 ; T
	.byte 36,36,36,72,72,72,48,0 ; U
	.byte 36,36,40,72,80,80,96,0 ; V
	.byte 18,34,34,34,84,84,104,0 ; W
	.byte 36,36,40,16,40,72,72,0 ; X
	.byte 36,36,36,24,8,16,32,0 ; Y
	.byte 56,8,16,32,32,64,112,0 ; Z
	.byte 28,16,16,32,32,32,56,0 ; [
	.byte 32,16,16,8,8,4,4,0 ; \
	.byte 28,4,4,4,8,8,56,0 ; ]
	.byte 8,24,60,16,16,32,32,0 ; ^
	.byte 0,0,0,0,0,0,0,248 ; _
	.byte 12,20,16,56,32,36,56,0 ; £
	.byte 0,0,28,36,40,88,108,0 ; a
	.byte 8,16,16,40,52,36,56,0 ; b
	.byte 0,0,12,20,32,32,28,0 ; c
	.byte 4,4,8,56,72,72,112,0 ; d
	.byte 0,0,12,20,56,32,24,0 ; e
	.byte 0,12,20,16,120,32,32,32 ; f
	.byte 0,0,12,20,36,24,8,48 ; g
	.byte 16,32,32,56,68,72,72,0 ; h
	.byte 4,0,8,8,16,16,16,0 ; i
	.byte 4,0,4,4,8,8,40,48 ; j
	.byte 16,16,20,24,40,36,36,0 ; k
	.byte 4,8,8,16,16,20,8,0 ; l
	.byte 0,0,22,42,42,68,68,0 ; m
	.byte 0,0,12,20,20,36,36,0 ; n
	.byte 0,0,28,36,36,40,16,0 ; o
	.byte 0,0,28,36,40,48,64,64 ; p
	.byte 0,0,24,36,44,20,8,8 ; q
	.byte 0,0,12,20,16,32,32,0 ; r
	.byte 0,0,12,16,8,36,56,0 ; s
	.byte 8,16,16,56,32,36,56,0 ; t
	.byte 0,0,36,36,72,72,48,0 ; u
	.byte 0,0,36,40,72,80,96,0 ; v
	.byte 0,0,34,34,84,84,104,0 ; w
	.byte 0,0,36,40,16,40,72,0 ; x
	.byte 0,0,20,36,44,20,8,48 ; y
	.byte 0,0,28,8,16,32,120,0 ; z
	.byte 28,16,16,96,32,32,56,0 ; {
	.byte 8,8,16,16,16,32,32,32 ; |
	.byte 56,8,8,12,16,16,112,0 ; }
	.byte 20,40,0,0,0,0,0,0 ; ~
	.byte 30,33,45,82,90,66,60,0 ; ©
