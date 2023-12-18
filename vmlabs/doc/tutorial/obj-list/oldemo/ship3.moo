
;
; ship3.moo = a MacrOObject that
; defines a simple type of ship
; controlled by the joystick.
;
; This one has its speed directly
; set by the Y-position of the
; joystick.

shp3:

; Header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$50000		;InitType (Zero), 5 vects params
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0			;no secondary data

	.dc.s	shp3_end-shp3		;length
    .dc.s   0,0,0

    .dc.s   0,0,0,0

; Variables

	.dc.s	plship2     ;Address of polyline definition
    .dc.s   $51f05a00   ;Colour     
    .dc.s   $000c0018   ;Scale   
    .dc.s   $8000       ;Phase offset to make thrust vector correct

    .dc.s   0           ;Phase
    .dc.s   0           ;Phase offset
    .dc.s   0           ;Speed
    .dc.s   $40000002   ;sine   (stopped)

    .dc.s   0           ;Phase
    .dc.s   0           ;Phase offset
    .dc.s   0           ;Speed
    .dc.s   $40000003   ;cos    (stopped)

    .dc.s   $b00000     ;Xpos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000301   ;lim, type (Max)

    .dc.s   $780000     ;Ypos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000302   ;lim, type (Max)

; Limits

	.dc.s	0
	.dc.s	$1680000    ;max X	
	.dc.s	$f00000     ;max Y
	.dc.s	-$400       ;min angle increment
	.dc.s	$400        ;max angle increment
	.dc.s	-$30000     ;min velocity
	.dc.s	$30000      ;max velocity
	.dc.s	$7c000000
	.dc.s	$20
	.dc.s	0,0,0,0,0,0,0

; Command

    .ascii  "A0=h"              ;set address of polyline in object
    .ascii  "A1=c"              ;set colour in c
    .ascii  "c=d"               ;set colour in d
    .ascii  "A2=e"              ;set scale

    .ascii  "@x[34]+C1=C1"     ;add to rotate angle from stick
    .ascii  "C1=g"             ;set angle in object
    .ascii  "g+A3=B1"          ;set phase of wave B from angle + $8000
    .ascii  "@y*B[56]=D1"      ;set X-velocity from sine
    .ascii  "@y*C[56]=E1"      ;set Y-velocity from cosine
    .ascii  "D0!=a<"           ;set X position
    .ascii  "E0!=a>:"          ;set Y-position and finish
     

	.align.v

shp3_end: