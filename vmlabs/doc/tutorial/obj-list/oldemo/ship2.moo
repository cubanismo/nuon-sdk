
;
; ship2.moo = a MacrOObject that
; defines a simple type of ship
; controlled by the joystick.
;
; This one has both angle and velocity
; directly set from the joystick.

shp2:

; Header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$50000		;Type (Zero), 5 vects variables
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0			;no secondary data

	.dc.s	shp2_end-shp2		;length
    .dc.s   0,0,0

    .dc.s   0,0,0,0

; Variables

	.dc.s	plship2     ;Address of polyline definition
    .dc.s   $d2921000   ;Colour     
    .dc.s   $00100010   ;Scale   
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
    .dc.s   $80000101   ;lim, type (Wrap)

    .dc.s   $780000     ;Ypos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000102   ;lim, type (Wrap)

; Ranges

	.dc.s	0
	.dc.s	$1680000    ;max X	
	.dc.s	$f00000     ;max Y
	.dc.s	-$18000     ;min angle
	.dc.s	$18000      ;max angle
	.dc.s	-$20000     ;min velocity
	.dc.s	$20000      ;max velocity
	.dc.s	$7c000000
	.dc.s	$20
	.dc.s	0,0,0,0,0,0,0

; Command

    .ascii  "A0=h"              ;set address of polyline in object
    .ascii  "A1=c"
    .ascii  "c=d"               ;set colour
    .ascii  "A2=e"              ;set scale

    .ascii  "@x[34]=g"          ;set rotate angle from stick
    .ascii  "g+A3=B1"           ;set phase of wave B from angle+$8000
    .ascii  "g=C1"              ;set phase of wave C from angle
    .ascii  "@y*B[56]=D1"       ;set X-velocity from sine
    .ascii  "@y*C[56]=E1"       ;set Y-velocity from cosine
    .ascii  "D0!=a<"            ;set X position
    .ascii  "E0!=a>:"           ;set Y-position and finish
    
	.align.v

shp2_end: