;
; qwarp.moo = a MacrOObject that
; defines a simple warp effect

qw:

	.dc.s	0		;Prev
	.dc.s	0			;Next
	.dc.s	$6080000	
	.dc.s	0       ;param address, if not local

	.dc.s	0	    ;Address of ranges table, if not local
	.dc.s	0		;this'll be where the command string is, if not local
	.dc.s	warpobj    ;here's the proto
	.dc.s	0

    .dc.s   qw_end-qw
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0


 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $04100    ;Speed
    .dc.s   1       ;Mode (triangle)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $13100    ;Speed
    .dc.s   2       ;Mode (sine)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $02000    ;Speed
    .dc.s   2       ;Mode (sine)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $11100    ;Speed
    .dc.s   2       ;Mode (sine)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $13400    ;Speed
    .dc.s   2       ;Mode (sine)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $11400    ;Speed
    .dc.s   2       ;Mode (sine)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $01700    ;Speed
    .dc.s   2       ;Mode (sine)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $c743       ;Phase offset
    .dc.s   $01900    ;Speed
    .dc.s   2       ;Mode (sine)

	.dc.s	$00
	.dc.s	-$40	
	.dc.s	$40
	.dc.s	-$1000
	.dc.s	$1000
	.dc.s	-$20
    .dc.s   $20,0
    .dc.s   0,0,0,0,0,0,0,0

    .dc.s   tile_img2   ;address
    .dc.s   $0018fff4      ;tuii/tvii
    .dc.s   $200           ;warp subtype
    .dc.s   $00000000      ;position
    .dc.s   $16800f0     ;size
    .dc.s   $fff00027      ;tuss/tvss

	.ascii	"_a=j"      ;set address
    .ascii  "A*D[34]=e"   ;tui
    .ascii  "C*B[34]=f"   ;tvi
    .ascii  "_b=g"      ;tuii/tvii
    .ascii  "E*A[56]=m<"
    .ascii  "F*B[56]=m>"
    .ascii  "E*H[34]=h"   ;tus
    .ascii  "G*F[34]=k"   ;tvs
    .ascii  "A*B*C*D[02]=c"   ;xpos in texture
    .ascii  "E*F*G*H[02]=d"   ;ypos in texture
    .ascii  "_f=l"      ;tuss/tvss
    .ascii  "_c=p>"     ;warp type
    .ascii  "_d=a"      ;position
    .ascii  "_e=b:"     ;size

	.align.v

qw_end: