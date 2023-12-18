;
; shsrce.moo = a MacrOObject that
; uses Qwarp to display a raw source-tile.

shsrce:

	.dc.s	0		;Prev
	.dc.s	0			;Next
	.dc.s	$7080000		;length of param block (4 vects); Type (1, feedback sprite)
	.dc.s	0       ;param address, if not local

	.dc.s	0	    ;Address of ranges table, if not local
	.dc.s	0		;this'll be where the command string is, if not local
	.dc.s	warpobj    ;here's the proto
	.dc.s	0

    .dc.s   shsrce_end-shsrce
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0


 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $04100    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $13100    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $02000    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $11100    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $13400    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $11400    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $01700    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $c743       ;Phase offset
    .dc.s   $01900    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)




	.dc.s	$00
	.dc.s	-$40	
	.dc.s	$40
	.dc.s	-$1000
	.dc.s	$1000
	.dc.s	-$20
    .dc.s   $20,0
    .dc.s   0,0,0,0,0,0,0,0

    .dc.s   tile_img   ;address
    .dc.s   $00000000      ;tuii/tvii
    .dc.s   $500           ;warp subtype
    .dc.s   $00940058      ;position
    .dc.s   $00400040     ;size
    .dc.s   $00000000      ;tuss/tvss
    .dc.s   $4000         

	.ascii	"_a=j"      ;set address
    .ascii  "_g=e"   ;tui
    .ascii  "_b=f"   ;tvi
    .ascii  "_b=g"      ;tuii/tvii
;    .ascii  "E*A[56]=m<"
;    .ascii  "F*B[56]=m>"
    .ascii  "_b=m"
    .ascii  "_b=h"   ;tui
    .ascii  "_g=k"   ;tvi
;    .ascii  "A*B*C*D[02]=c"
;    .ascii  "E*F*G*H[02]=d"
    .ascii  "_b=cc=d"
    .ascii  "_b=l"      ;tuss/tvss
    .ascii  "_c=p>"     ;warp type
    .ascii  "_d=a"      ;position
    .ascii  "_e=b:"     ;size

	.align.v

shsrce_end: