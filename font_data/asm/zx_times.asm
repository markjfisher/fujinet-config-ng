	; ZX Times font from https://damieng.com/zx-origins
	.byte 0,0,0,0,0,0,0,0 ;  
	.byte 56,56,56,16,16,0,56,0 ; !
	.byte 108,108,72,0,0,0,0,0 ; "
	.byte 0,20,126,40,40,252,80,0 ; #
	.byte 62,106,120,60,30,86,124,16 ; $
	.byte 114,218,116,24,46,91,78,0 ; %
	.byte 48,104,104,119,218,220,118,0 ; &
	.byte 24,24,16,0,0,0,0,0 ; '
	.byte 8,16,48,48,48,48,16,8 ; (
	.byte 32,16,24,24,24,24,16,32 ; )
	.byte 0,16,84,56,84,16,0,0 ; *
	.byte 0,24,24,126,24,24,0,0 ; +
	.byte 0,0,0,0,0,24,24,16 ; ,
	.byte 0,0,0,124,0,0,0,0 ; -
	.byte 0,0,0,0,0,24,24,0 ; .
	.byte 6,12,12,24,24,48,48,96 ; /
	.byte 24,36,102,102,102,36,24,0 ; 0
	.byte 24,56,24,24,24,24,60,0 ; 1
	.byte 60,102,6,12,24,50,126,0 ; 2
	.byte 60,102,6,28,6,102,60,0 ; 3
	.byte 12,28,44,76,126,12,12,0 ; 4
	.byte 62,96,112,12,6,70,60,0 ; 5
	.byte 28,48,96,124,102,102,60,0 ; 6
	.byte 126,70,6,12,12,24,24,0 ; 7
	.byte 60,98,114,60,78,70,60,0 ; 8
	.byte 60,102,102,62,6,12,56,0 ; 9
	.byte 0,0,24,24,0,24,24,0 ; :
	.byte 0,0,24,24,0,24,24,16 ; ;
	.byte 0,6,28,112,28,6,0,0 ; <
	.byte 0,0,124,0,124,0,0,0 ; =
	.byte 0,96,56,14,56,96,0,0 ; >
	.byte 60,102,6,12,16,0,48,0 ; ?
	.byte 56,68,222,230,230,222,64,60 ; @
	.byte 24,24,44,44,126,70,239,0 ; A
	.byte 252,102,102,124,102,102,252,0 ; B
	.byte 58,102,192,192,192,98,60,0 ; C
	.byte 248,108,102,102,102,108,248,0 ; D
	.byte 254,98,104,120,104,98,252,0 ; E
	.byte 254,98,104,120,104,96,240,0 ; F
	.byte 52,108,192,206,196,100,56,0 ; G
	.byte 247,102,102,126,102,102,239,0 ; H
	.byte 60,24,24,24,24,24,60,0 ; I
	.byte 30,12,12,12,108,104,48,0 ; J
	.byte 238,100,104,112,120,108,238,0 ; K
	.byte 240,96,96,96,96,98,252,0 ; L
	.byte 247,118,118,90,90,90,231,0 ; M
	.byte 206,100,116,124,92,76,228,0 ; N
	.byte 56,108,198,198,198,108,56,0 ; O
	.byte 252,102,102,100,120,96,240,0 ; P
	.byte 56,108,198,198,198,108,56,12 ; Q
	.byte 252,102,102,124,108,102,247,0 ; R
	.byte 58,102,112,60,14,102,92,0 ; S
	.byte 126,90,24,24,24,24,60,0 ; T
	.byte 231,98,98,98,98,98,60,0 ; U
	.byte 231,98,98,52,52,24,24,0 ; V
	.byte 247,106,106,126,126,118,98,0 ; W
	.byte 230,100,56,56,56,76,206,0 ; X
	.byte 247,98,52,52,24,24,60,0 ; Y
	.byte 126,70,12,24,48,98,126,0 ; Z
	.byte 60,48,48,48,48,48,48,60 ; [
	.byte 96,48,48,24,24,12,12,6 ; \
	.byte 60,12,12,12,12,12,12,60 ; ]
	.byte 16,56,108,68,0,0,0,0 ; ^
	.byte 0,0,0,0,0,0,0,255 ; _
	.byte 28,54,48,120,48,50,126,0 ; £
	.byte 0,0,60,70,62,102,62,0 ; a
	.byte 224,96,108,118,102,102,124,0 ; b
	.byte 0,0,60,102,96,98,60,0 ; c
	.byte 28,12,108,220,204,204,126,0 ; d
	.byte 0,0,60,102,126,96,62,0 ; e
	.byte 28,54,48,120,48,48,120,0 ; f
	.byte 0,0,61,102,60,96,60,6 ; g
	.byte 224,96,108,118,102,102,238,0 ; h
	.byte 24,0,56,24,24,24,60,0 ; i
	.byte 12,0,28,12,12,12,12,56 ; j
	.byte 224,96,108,104,120,108,238,0 ; k
	.byte 56,24,24,24,24,24,60,0 ; l
	.byte 0,0,244,126,106,106,235,0 ; m
	.byte 0,0,236,118,102,102,247,0 ; n
	.byte 0,0,60,102,102,102,60,0 ; o
	.byte 0,0,236,118,102,124,96,240 ; p
	.byte 0,0,110,220,204,124,12,30 ; q
	.byte 0,0,236,118,96,96,240,0 ; r
	.byte 0,0,62,112,60,14,124,0 ; s
	.byte 16,48,124,48,48,52,24,0 ; t
	.byte 0,0,238,102,102,110,55,0 ; u
	.byte 0,0,238,100,56,56,16,0 ; v
	.byte 0,0,247,98,106,52,52,0 ; w
	.byte 0,0,118,56,24,44,110,0 ; x
	.byte 0,0,231,98,52,24,24,112 ; y
	.byte 0,0,126,76,24,50,126,0 ; z
	.byte 12,24,24,112,24,24,24,12 ; {
	.byte 24,24,24,24,24,24,24,24 ; |
	.byte 48,24,24,14,24,24,24,48 ; }
	.byte 0,118,220,0,0,0,0,0 ; ~
	.byte 60,66,157,181,177,157,66,60 ; ©
