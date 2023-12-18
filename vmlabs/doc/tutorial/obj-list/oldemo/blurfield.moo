;
; blurfield.moo = a MacrOObject that
; defines a nonscaling blurfield

bf:

	.dc.s	0		;Prev
	.dc.s	0			;Next
	.dc.s	$6080001		;length of param block (4 vects); Type (1, feedback sprite)
	.dc.s	0       ;param address, if not local

	.dc.s	0	    ;Address of ranges table, if not local
	.dc.s	0		;this'll be where the command string is, if not local
	.dc.s	warpobj    ;here's the proto
	.dc.s	0

    .dc.s   bf_end-bf
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0


 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $0410000    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $0310000    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $0200000    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $0110000    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $0340000    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $0140000    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $0170000    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $c743       ;Phase offset
    .dc.s   $0190000    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

	.dc.s	$00
	.dc.s	-$40	
	.dc.s	$40
	.dc.s	-$1000
	.dc.s	$1000
	.dc.s	-$80
    .dc.s   $80,0
    .dc.s   0,0,0,0,0,0,0,0

    .dc.s   $2fff0000       ;intensity
    .dc.s   $10808000      ;colour
    .dc.s   $100           ;warp subtype
    .dc.s   $00000000      ;position
    .dc.s   $16800f0     ;size
    .dc.s   $fff00027      ;tuss/tvss

    .ascii  "_a=h"      ;set intensity
    .ascii  "_b=l"      ;set colour
    .ascii  "_c=p>"     ;warp type
    .ascii  "_d=a"      ;position
    .ascii  "_e=b:"     ;size

	.align.v

bf_end: