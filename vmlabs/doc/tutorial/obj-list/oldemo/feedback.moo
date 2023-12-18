;
; feedback.moo = a MacrOObject that
; defines a scale/rotate/blurfield

fb:

	.dc.s	0		;Prev
	.dc.s	0			;Next
	.dc.s	$40001		;length of param block (4 vects); Type (1, feedback sprite)
	.dc.s	0       ;param address, if not local

	.dc.s	0	    ;Address of ranges table, if not local
	.dc.s	0		;this'll be where the command string is, if not local
	.dc.s	spriteobj    ;here's the proto
	.dc.s	0

    .dc.s   fb_end-fb
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0

; local paramspace

fb_params:

; one timer

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $24100    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $1c100    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $1f000    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $11100    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)


fb_ranges:

	.dc.s	$3080
	.dc.s	$3c00	
	.dc.s	$0000fa00
	.dc.s	$00010700
	.dc.s	-$120
	.dc.s	$120
    .dc.s   0,0
    .dc.s   0,0,0,0,0,0,0,0

fb_cmd:

	.ascii	"A[01]=h<"
	.ascii	"B[23]=e"
	.ascii	"C[23]=f"
	.ascii	"D[45]=g:"

	.align.v

fb_end: