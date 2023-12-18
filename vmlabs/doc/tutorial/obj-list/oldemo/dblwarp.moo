;
; feedback.moo = a MacrOObject that
; defines a scale/rotate/blurfield

dblwarp1:

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$140c0000		;Type (Zero with ten vectors of params)
	.dc.s	0			;Address of parameter block, if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is if not local
	.dc.s	warpobj	;here is the object prototype...
	.dc.s	0			;here is the base of the warp_params (will be concatinated)

	.dc.s	dblwarp1_end-dblwarp1
	.dc.s	0				;routine # for init object (0 = none)
	.dc.s	0,0

	.dc.s	0,0,0,0

; local paramspace


 .dc.s   0       ;Phase relative to current
        .dc.s   $2743       ;Phase offset
        .dc.s   $0140    ;Speed
        .dc.s   2       ;Mode (Sine)

 .dc.s   0       ;Phase relative to current
        .dc.s   $10000       ;Phase offset
        .dc.s   $0735    ;Speed
        .dc.s   3       ;Mode (Cos)

 .dc.s   0       ;Phase relative to current
        .dc.s   $19287       ;Phase offset
        .dc.s   $1676    ;Speed
        .dc.s   2       ;Mode (Sine)

 .dc.s   0       ;Phase relative to current
        .dc.s   $7294       ;Phase offset
        .dc.s   $1620    ;Speed
        .dc.s   3       ;Mode (Cos)

 .dc.s   0       ;Phase relative to current
        .dc.s   $4000       ;Phase offset
        .dc.s   $115f    ;Speed
        .dc.s   2       ;Mode (Sine)

 .dc.s   0       ;Phase relative to current
        .dc.s   $8203       ;Phase offset
        .dc.s   $1e3c    ;Speed
        .dc.s   3       ;Mode (Cos)

 .dc.s   0       ;Phase relative to current
        .dc.s   $1122       ;Phase offset
        .dc.s   $0125    ;Speed
        .dc.s   2       ;Mode (Sine)

 .dc.s   0       ;Phase relative to current
        .dc.s   $4000       ;Phase offset
        .dc.s   $076e    ;Speed
        .dc.s   3       ;Mode (Cos)

 .dc.s   0       ;Phase relative to current
        .dc.s   $2933       ;Phase offset
        .dc.s   $0818    ;Speed
        .dc.s   2       ;Mode (Sine)
        
 .dc.s   0       ;Phase relative to current
        .dc.s   $f0f0       ;Phase offset
        .dc.s   $0345    ;Speed
        .dc.s   3       ;Mode (Cos)

    .dc.s   tile_img  ;tile 1 srce
    .dc.s   $16800f0     ;Size
    .dc.s   3           ;Innerloop style
    .dc.s   0           ;Position

    .dc.s   tile_img2   ;tile 2 srce
    .dc.s   0
    .dc.s   0
    .dc.s   0

; ranges

	.dc.s	-$2000
	.dc.s	$2000	
	.dc.s	-$100000
	.dc.s	$200000
	.dc.s	-$300000
	.dc.s	$300000
	.dc.s	$000,$fff
	.dc.s	-$300000,$200000,-$f00,$f00,0,0,0,0

; here is local workspace (20 longs)

    .dc.s   0,0,0,0,0,0,0,0,0,0
    .dc.s   0,0,0,0,0,0,0,0,0,0

; command

    .ascii  "$_a=m"     ;pass address of local data block to the object
    .ascii  "B[:;]=e"       ;X displacement magnitude
    .ascii  "C[:;]=f"       ;Y displacement magnitude
    .ascii  "E*F[67]=h<"    ;Blend-through of layer1 to layer2
    .ascii  "K0=k"          ;assorted constants
    .ascii  "L0=l"
    .ascii  "K3=a"
    .ascii  "K1=b"
    .ascii  "K2=n"
	.ascii	"I[45]=_a"      ;vary all the params for both warps
	.ascii	"C[45]=_b"
	.ascii	"D[45]=_c"
	.ascii	"J[45]=_d"
    
	.ascii	"A[23]=_e"
	.ascii	"B[23]=_f"
	.ascii	"C[01]=_g"
	.ascii	"D[01]=_h"
    
    .ascii  "E[23]=_i"
    .ascii  "F[23]=_j"
    .ascii  "G[01]=_k"
    .ascii  "H[01]=_l"
    
	.ascii	"H[23]=_m"
	.ascii	"G[23]=_n"
	.ascii	"F[01]=_o"
	.ascii	"E[01]=_p"

    .ascii  "D[23]=_q"
    .ascii  "C[23]=_r"
    .ascii  "B[01]=_s"
    .ascii  "A[01]=_t:"

	.align.v

dblwarp1_end: