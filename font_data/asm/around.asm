	; Around font from https://damieng.com/zx-origins
	.byte 0,0,0,0,0,0,0,0 ;  
	.byte 16,16,16,16,0,16,16,0 ; !
	.byte 18,36,36,72,0,0,0,0 ; "
	.byte 36,36,255,36,36,255,36,36 ; #
	.byte 12,63,104,56,14,11,126,24 ; $
	.byte 97,146,148,104,22,41,73,134 ; %
	.byte 56,100,64,56,72,66,102,59 ; &
	.byte 48,16,32,0,0,0,0,0 ; '
	.byte 28,48,32,32,32,32,48,28 ; (
	.byte 56,12,4,4,4,4,12,56 ; )
	.byte 8,8,8,119,8,20,34,0 ; *
	.byte 8,8,8,127,8,8,8,0 ; +
	.byte 0,0,0,0,4,8,8,16 ; ,
	.byte 0,0,0,126,0,0,0,0 ; -
	.byte 0,0,0,0,0,0,24,0 ; .
	.byte 1,2,4,8,16,32,64,128 ; /
	.byte 62,99,69,73,73,81,99,62 ; 0
	.byte 8,24,56,8,8,8,8,8 ; 1
	.byte 62,99,65,3,14,56,96,127 ; 2
	.byte 127,2,28,6,3,65,67,62 ; 3
	.byte 4,8,16,18,34,127,2,2 ; 4
	.byte 127,64,94,99,1,65,99,62 ; 5
	.byte 62,64,94,99,65,65,99,62 ; 6
	.byte 126,3,1,1,1,1,1,1 ; 7
	.byte 62,99,34,62,99,65,99,62 ; 8
	.byte 62,99,65,65,99,61,1,62 ; 9
	.byte 0,0,24,0,0,24,0,0 ; :
	.byte 0,0,24,0,8,16,16,32 ; ;
	.byte 4,8,16,32,32,16,8,4 ; <
	.byte 0,0,126,0,126,0,0,0 ; =
	.byte 32,16,8,4,4,8,16,32 ; >
	.byte 62,99,65,3,14,0,8,8 ; ?
	.byte 62,99,77,83,81,79,96,63 ; @
	.byte 62,99,65,65,127,65,65,65 ; A
	.byte 126,67,65,126,67,65,67,126 ; B
	.byte 62,99,65,64,64,65,99,62 ; C
	.byte 126,67,65,65,65,65,67,126 ; D
	.byte 63,96,64,124,64,64,96,63 ; E
	.byte 63,96,64,64,124,64,64,64 ; F
	.byte 62,99,65,64,79,65,99,62 ; G
	.byte 65,65,65,127,65,65,65,65 ; H
	.byte 8,8,8,8,8,8,8,8 ; I
	.byte 1,1,1,1,1,65,99,62 ; J
	.byte 65,66,68,120,68,66,65,65 ; K
	.byte 64,64,64,64,64,64,96,63 ; L
	.byte 54,107,73,73,73,73,65,65 ; M
	.byte 62,99,65,65,65,65,65,65 ; N
	.byte 62,99,65,65,65,65,99,62 ; O
	.byte 126,67,65,67,126,64,64,64 ; P
	.byte 62,99,65,65,73,69,102,59 ; Q
	.byte 126,67,65,67,126,68,66,65 ; R
	.byte 62,99,65,56,14,65,99,62 ; S
	.byte 127,8,8,8,8,8,8,8 ; T
	.byte 65,65,65,65,65,65,99,62 ; U
	.byte 65,65,65,65,34,34,28,8 ; V
	.byte 65,65,73,73,73,73,107,54 ; W
	.byte 65,65,34,28,34,65,65,65 ; X
	.byte 65,65,34,20,8,8,8,8 ; Y
	.byte 126,1,1,14,56,64,64,63 ; Z
	.byte 28,48,32,32,32,32,48,28 ; [
	.byte 128,64,32,16,8,4,2,1 ; \
	.byte 56,12,4,4,4,4,12,56 ; ]
	.byte 0,28,42,73,8,8,8,8 ; ^
	.byte 0,0,0,0,0,0,0,255 ; _
	.byte 30,49,32,32,126,32,32,127 ; £
	.byte 0,0,62,1,63,65,97,63 ; a
	.byte 64,64,94,99,65,65,67,126 ; b
	.byte 0,0,62,99,64,64,99,62 ; c
	.byte 1,1,61,99,65,65,97,63 ; d
	.byte 0,0,62,99,65,127,64,63 ; e
	.byte 30,48,32,32,124,32,32,32 ; f
	.byte 0,0,62,67,97,63,1,62 ; g
	.byte 64,64,94,99,65,65,65,65 ; h
	.byte 8,0,8,8,8,8,8,8 ; i
	.byte 2,0,2,2,2,2,70,60 ; j
	.byte 64,65,65,66,124,66,65,65 ; k
	.byte 32,32,32,32,32,32,48,28 ; l
	.byte 0,0,54,107,73,73,73,73 ; m
	.byte 0,0,62,99,65,65,65,65 ; n
	.byte 0,0,62,99,65,65,99,62 ; o
	.byte 0,0,126,67,65,99,94,64 ; p
	.byte 0,0,63,97,65,99,61,1 ; q
	.byte 0,0,94,99,65,64,64,64 ; r
	.byte 0,0,62,67,56,14,97,62 ; s
	.byte 16,16,124,16,16,16,24,14 ; t
	.byte 0,0,65,65,65,65,99,61 ; u
	.byte 0,0,65,65,34,34,28,8 ; v
	.byte 0,0,65,73,73,73,107,54 ; w
	.byte 0,0,65,34,28,28,34,65 ; x
	.byte 0,0,65,65,99,61,1,62 ; y
	.byte 0,0,126,1,14,56,64,63 ; z
	.byte 14,24,16,96,16,16,24,14 ; {
	.byte 8,8,8,8,8,8,8,8 ; |
	.byte 112,24,8,6,8,8,24,112 ; }
	.byte 49,73,70,0,0,0,0,0 ; ~
	.byte 126,195,157,181,161,157,195,126 ; ©
