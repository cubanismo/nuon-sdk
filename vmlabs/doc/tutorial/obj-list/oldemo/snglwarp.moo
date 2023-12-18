;
; snglwarp.moo = a MacrOObject that
; defines a translucent 1-layer warp

snglwarp1:

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$140b0000		;Type (Zero with ten vectors of params)
	.dc.s	0			;Address of parameter block, if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is if not local
	.dc.s	warpobj	;here is the object prototype...
	.dc.s	0			;here is the base of the warp_params (will be concatinated)

	.dc.s	snglwarp1_end-snglwarp1
	.dc.s	0				;routine # for init object (0 = none)
	.dc.s	0,0

	.dc.s	0,0,0,0

; local paramspace


 .dc.s   0              ;Phase relative to current
        .dc.s   $2743   ;Phase offset
        .dc.s   $0140   ;Speed
        .dc.s   2       ;Mode (Sin)

 .dc.s   0              ;Phase relative to current
        .dc.s   $10000  ;Phase offset
        .dc.s   $0735   ;Speed
        .dc.s   3       ;Mode (Cos)

 .dc.s   0              ;Phase relative to current
        .dc.s   $19287  ;Phase offset
        .dc.s   $1676   ;Speed
        .dc.s   2       ;Mode (Sin)

 .dc.s   0              ;Phase relative to current
        .dc.s   $7294   ;Phase offset
        .dc.s   $1620   ;Speed
        .dc.s   3       ;Mode (Cos)

 .dc.s   0              ;Phase relative to current
        .dc.s   $4000   ;Phase offset
        .dc.s   $115f   ;Speed
        .dc.s   2       ;Mode (Sin)

 .dc.s   0              ;Phase relative to current
        .dc.s   $8203   ;Phase offset
        .dc.s   $1e3c   ;Speed
        .dc.s   3       ;Mode (Cos)

 .dc.s   0              ;Phase relative to current
        .dc.s   $1122   ;Phase offset
        .dc.s   $0125   ;Speed
        .dc.s   2       ;Mode (Sin)

 .dc.s   0              ;Phase relative to current
        .dc.s   $4000   ;Phase offset
        .dc.s   $076e   ;Speed
        .dc.s   3       ;Mode (Cos)

 .dc.s   0              ;Phase relative to current
        .dc.s   $2933   ;Phase offset
        .dc.s   $0818   ;Speed
        .dc.s   2       ;Mode (Sin)
        
 .dc.s   0              ;Phase relative to current
        .dc.s   $f0f0   ;Phase offset
        .dc.s   $0945   ;Speed
        .dc.s   3       ;Mode (Cos)

    .dc.s   tile_img    ;tile 1 srce
    .dc.s   $16800f0    ;Size
    .dc.s   1           ;Innerloop style
    .dc.s   0           ;Position

; ranges table
    
	.dc.s	-$2000
	.dc.s	$2000	
	.dc.s	-$100000
	.dc.s	$200000
	.dc.s	-$300000
	.dc.s	$300000
	.dc.s	$00,$4000
	.dc.s	-$300000,$200000,-$f00,$f00,0,0,0,0

; here is local workspace (20 longs)

    .dc.s   0,0,0,0,0,0,0,0,0,0
    .dc.s   0,0,0,0,0,0,0,0,0,0

; command string

    .ascii  "$_a=m"     ;pass address of local data block to the object
    .ascii  "E*F[67]=h<"    ;generate translucency
    .ascii  "K0=k"          ;set some constants
    .ascii  "K3=a"
    .ascii  "K1=b"
    .ascii  "K2=n"
    .ascii  "a=l"
	.ascii	"I[45]=_a"      ;position X
	.ascii	"J[45]=_b"      ;position Y
    
	.ascii	"A[23]=_e"      ;du/dx
	.ascii	"B[23]=_f"      ;dv/dx
	.ascii	"C[01]=_g"      ;d2u/dx
	.ascii	"D[01]=_h"      ;d2v/dx
    
	.ascii	"H[23]=_m"      ;du/dy
	.ascii	"G[23]=_n"      ;dv/dy
	.ascii	"F[01]=_o"      ;d2u/dy
	.ascii	"E[01]=_p:"     ;d2v/dy

	.align.v

snglwarp1_end: