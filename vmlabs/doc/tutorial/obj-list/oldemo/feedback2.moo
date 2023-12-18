;
; feedback.moo = a MacrOObject that
; defines a scale/rotate/blurfield

fb2:

	.dc.s	0		;Prev
	.dc.s	0			;Next
	.dc.s	$1040001		;length of param block (4 vects); Type (1, feedback sprite)
	.dc.s	0       ;param address, if not local

	.dc.s	0	    ;Address of ranges table, if not local
	.dc.s	0		;this'll be where the command string is, if not local
	.dc.s	spriteobj    ;here's the proto
	.dc.s	0

    .dc.s   fb2_end-fb2
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0

; vars



 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $24100    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $0c100    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $0f000    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $8743       ;Phase offset
    .dc.s   $11100    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Bit 0 = Running)

; ranges

	.dc.s	$3080
	.dc.s	$3c00	
	.dc.s	$00010500
	.dc.s	$00011000
	.dc.s	-$120
	.dc.s	$120
    .dc.s   0,0
    .dc.s   0,0,0,0,0,0,0,0

; secondary data

    .dc.s   0       ;type

; command

	.ascii	"B[23]=e"
	.ascii	"C[23]=f"
    .ascii  "_a=h3:"

;	.ascii	"A[01]=h<"
;	.ascii	"D[45]=g:"

	.align.v

fb2_end: