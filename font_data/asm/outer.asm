	; Outer font from https://damieng.com/zx-origins
	.byte 0,0,0,0,0,0,0,0 ;  
	.byte 16,16,16,16,16,0,56,0 ; !
	.byte 72,72,72,0,0,0,0,0 ; "
	.byte 0,108,254,108,108,254,108,0 ; #
	.byte 16,120,64,124,12,124,16,0 ; $
	.byte 224,164,232,16,46,74,14,0 ; %
	.byte 124,96,60,102,100,126,126,0 ; &
	.byte 16,16,16,0,0,0,0,0 ; '
	.byte 12,24,48,48,48,24,12,0 ; (
	.byte 48,24,12,12,12,24,48,0 ; )
	.byte 16,84,124,56,108,0,0,0 ; *
	.byte 0,24,24,126,24,24,0,0 ; +
	.byte 0,0,0,0,0,56,8,48 ; ,
	.byte 0,0,0,126,0,0,0,0 ; -
	.byte 0,0,0,0,0,0,56,0 ; .
	.byte 2,6,12,24,48,96,64,0 ; /
	.byte 124,76,76,76,76,124,124,0 ; 0
	.byte 48,48,16,16,16,16,16,0 ; 1
	.byte 124,124,100,4,124,96,124,0 ; 2
	.byte 124,124,76,24,12,76,124,0 ; 3
	.byte 100,100,100,100,124,12,12,0 ; 4
	.byte 124,96,124,4,100,124,124,0 ; 5
	.byte 124,76,64,124,76,76,124,0 ; 6
	.byte 124,124,4,8,24,24,24,0 ; 7
	.byte 124,124,100,56,100,100,124,0 ; 8
	.byte 124,100,100,124,4,124,124,0 ; 9
	.byte 0,0,56,0,0,56,0,0 ; :
	.byte 0,0,56,0,0,56,8,48 ; ;
	.byte 0,12,24,48,48,24,12,0 ; <
	.byte 0,0,126,0,126,0,0,0 ; =
	.byte 0,48,24,12,12,24,48,0 ; >
	.byte 124,124,100,4,28,0,56,0 ; ?
	.byte 62,34,46,106,110,96,126,0 ; @
	.byte 124,76,76,124,76,76,76,0 ; A
	.byte 124,76,76,76,120,76,124,0 ; B
	.byte 124,76,76,64,64,76,124,0 ; C
	.byte 124,124,76,76,76,76,124,0 ; D
	.byte 124,76,76,124,124,96,124,0 ; E
	.byte 124,76,64,120,120,64,64,0 ; F
	.byte 124,76,64,92,76,76,124,0 ; G
	.byte 76,76,76,124,124,68,68,0 ; H
	.byte 56,0,16,16,16,16,16,0 ; I
	.byte 28,28,4,4,100,100,124,0 ; J
	.byte 76,88,112,124,76,76,76,0 ; K
	.byte 64,64,64,64,64,124,124,0 ; L
	.byte 126,106,106,106,106,106,106,0 ; M
	.byte 124,124,76,76,76,76,76,0 ; N
	.byte 124,124,100,100,100,100,124,0 ; O
	.byte 124,124,100,100,124,64,64,0 ; P
	.byte 124,124,100,100,100,100,124,16 ; Q
	.byte 124,76,76,76,120,76,76,0 ; R
	.byte 124,76,64,124,12,76,124,0 ; S
	.byte 126,120,24,24,24,24,24,0 ; T
	.byte 100,100,100,100,100,100,124,0 ; U
	.byte 70,70,70,44,44,24,24,0 ; V
	.byte 86,86,86,86,86,126,126,0 ; W
	.byte 76,76,76,56,76,76,76,0 ; X
	.byte 76,76,76,124,12,12,124,0 ; Y
	.byte 124,12,24,48,96,124,124,0 ; Z
	.byte 60,32,32,32,32,60,60,0 ; [
	.byte 64,96,48,24,12,6,2,0 ; \
	.byte 60,60,4,4,4,4,60,0 ; ]
	.byte 16,56,124,84,16,16,16,0 ; ^
	.byte 0,0,0,0,0,0,0,255 ; _
	.byte 124,100,96,120,96,96,124,0 ; £
	.byte 0,0,124,12,124,100,124,0 ; a
	.byte 64,64,124,76,76,124,124,0 ; b
	.byte 0,0,124,76,64,76,124,0 ; c
	.byte 4,4,124,100,100,124,124,0 ; d
	.byte 0,0,124,76,124,96,124,0 ; e
	.byte 60,44,32,56,56,32,32,0 ; f
	.byte 0,0,124,76,124,124,12,124 ; g
	.byte 96,96,124,124,68,68,68,0 ; h
	.byte 0,56,0,16,16,16,16,0 ; i
	.byte 0,28,0,8,8,8,56,48 ; j
	.byte 64,64,76,88,124,76,76,0 ; k
	.byte 24,24,24,24,24,24,24,0 ; l
	.byte 0,0,126,126,106,106,106,0 ; m
	.byte 0,0,124,100,100,100,100,0 ; n
	.byte 0,0,124,124,100,100,124,0 ; o
	.byte 0,0,124,124,100,124,64,64 ; p
	.byte 0,0,124,124,76,124,4,4 ; q
	.byte 0,0,124,124,76,64,64,0 ; r
	.byte 0,0,124,96,124,4,124,0 ; s
	.byte 64,64,112,64,76,124,124,0 ; t
	.byte 0,0,100,100,100,100,124,0 ; u
	.byte 0,0,76,76,56,56,16,0 ; v
	.byte 0,0,86,86,86,126,126,0 ; w
	.byte 0,0,76,76,56,76,76,0 ; x
	.byte 0,0,76,76,76,124,12,60 ; y
	.byte 0,0,124,12,16,96,124,0 ; z
	.byte 12,24,24,48,24,24,12,0 ; {
	.byte 24,24,24,24,24,24,24,0 ; |
	.byte 48,24,24,12,24,24,48,0 ; }
	.byte 54,126,108,0,0,0,0,0 ; ~
	.byte 126,66,90,82,90,66,126,0 ; ©
