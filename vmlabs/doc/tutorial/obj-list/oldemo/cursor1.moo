
;
; cursor1.moo = a MacrOObject that
; defines a simple cross cursor attached to the joystick.

curs1:

; header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$2000000		;2 long secondary data
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0				;not external secondary data

	.dc.s	curs1_end-curs1		;length
    .dc.s   0,0,0

    .dc.s   0,0,0,0

; Ranges table

	.dc.s	-$20
	.dc.s	$188	
	.dc.s	$120,0
    
	.dc.s	0,0,0,0
	.dc.s	0,0,0,0
	.dc.s	0,0,0,0

; Secondary data

	.dc.s	cursor1     ;Address of polyline definition
    .dc.s   $00200010   ;Scale

; Command string

    .ascii  "_a=h"              ;set address of polyline in object
    .ascii  "_b=e"              ;set scale
    .ascii  "@x[01]=a<"         ;set xpos from stick
    .ascii  "@y[02]=a>:"        ;set ypos from stick and end.


	.align.v

curs1_end: