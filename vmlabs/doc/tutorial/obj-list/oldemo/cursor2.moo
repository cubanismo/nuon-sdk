
;
; cursor2.moo = a MacrOObject that
; defines a simple cross cursor
; whose *velocity* is attached to the joystick.

curs2:

; header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$30000		;3 vects params
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0				;no secondary data

	.dc.s	curs2_end-curs2		;length
    .dc.s   0,0,0

    .dc.s   0,0,0,0

; variables

	.dc.s	cursor1     ;Address of polyline definition
    .dc.s   $71deca00   ;Colour     
    .dc.s   $00100010   ;Scale   
    .dc.s   $0

    .dc.s   $b00000     ;pos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000101   ;lim, type etc.

    .dc.s   $780000     ;pos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000102   ;lim, type etc.

; ranges

	.dc.s	0
	.dc.s	$1680000    ;max X	
	.dc.s	$f00000     ;max Y
	.dc.s	-$180000     ;min velocity
	.dc.s	$180000      ;max velocity
	.dc.s	$20000      
	.dc.s	$00
	.dc.s	$000
	.dc.s	$20
	.dc.s	0,0,0,0,0,0,0

; command

    .ascii  "A0=h"              ;set address of polyline in object
    .ascii  "A1=c"
    .ascii  "c=d"               ;set colour
    .ascii  "A2=e"              ;set scale

    .ascii  "@x[34]=B1"         ;set xvel from stick
    .ascii  "@y[34]=C1"         ;set yvel from stick
    .ascii  "@x[05]=g"          ;check it out!
    .ascii  "B0!=a<"            ;set xpos to int b-pos
    .ascii  "C0!=a>:"            ;set ypos to int c-pos, end.

	.align.v

curs2_end: