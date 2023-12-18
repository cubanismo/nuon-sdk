
;
; ship4.moo = a MacrOObject that
; defines a simple type of ship
; controlled by the joystick.
;
; This one is kinda like an Asteroids
; ship, except that the amount of Thrust is
; determined by the Y-axis position of the
; joystick.

shp4:

; Header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$60000		;InitType (Zero), 6 vects params
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0			;no secondary data

	.dc.s	shp4_end-shp4		;length
    .dc.s   0,0,0

    .dc.s   0,0,0,0

; Variables

	.dc.s	plship3     ;Address of polyline definition
    .dc.s   $306ef000   ;Colour     
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
    .dc.s   $80000102   ;lim, type  (Wrap)

    .dc.s   0           ;used for Thrust
    .dc.s   0
    .dc.s   $ffc0
    .dc.s   $80000000

; Ranges

	.dc.s	0
	.dc.s	$1680000    ;max X	
	.dc.s	$f00000     ;max Y
	.dc.s	-$400     ;min angle inc
	.dc.s	$400      ;max angle inc
	.dc.s	-$700000     ;min velocity inc
	.dc.s	$700000      ;max velocity inc
	.dc.s	-$f0000
	.dc.s	$f0000
	.dc.s	0,0,0,0,0,0,0

; Command

    .ascii  "A0=h"              ;set address of polyline in object
    .ascii  "A1=c"
    .ascii  "c=d"               ;set colour
    .ascii  "A2=e"              ;set scale

    .ascii  "@x[34]+C1=C1"          ;set rotate angle from stick
    .ascii  "C1=g"             ;set phase of wave C from angle
    .ascii  "g+A3=B1"           ;set phase of wave B from angle
    .ascii  "@y[56]+F1=F1"          ;inc velocity
    .ascii  "F1*B[78]=D1"          ;set X-velocity from sine
    .ascii  "F1*C[78]=E1"          ;set Y-velocity from cosine
    .ascii  "D0!=a<"            ;set X position
    .ascii  "E0!=a>:"           ;set Y-position and finish
    

	.align.v

shp4_end: