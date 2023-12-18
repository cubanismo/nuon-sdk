
;
; ship6.moo = a MacrOObject that
; defines a simple type of ship
; controlled by the joystick.
;
; This one is a Lunar Lander!

lndr:

; Header block

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$70000		;Type (Zero), 7 vects of variables
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype object to use
	.dc.s	0			;no secondary data

	.dc.s	lndr_end-lndr		;length
    .dc.s   0,0,0

    .dc.s   0,0,0,0

; Variables

    .dc.s   lland       ;Polyline definition
    .dc.s   $f0808000   ;Colour     
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

    .dc.s   $b00000     ;xpos
    .dc.s   0           ;vel
    .dc.s   $ffe0       ;fr
    .dc.s   $80000201   ;lim, type (bounce)

    .dc.s   $780000     ;ypos
    .dc.s   0           ;vel
    .dc.s   $ffe0       ;fr
    .dc.s   $80000302   ;lim, type (max)

    .dc.s   0
    .dc.s   0
    .dc.s   $cfc0
    .dc.s   $80000078   ;Used to make thrust
    
    .dc.s   0,$200,0,0  ;Storage and 'G'

; Range table

	.dc.s	0
	.dc.s	$1680000    ;max X	
	.dc.s	$c00000     ;max Y
	.dc.s	-$400     ;min angle inc
	.dc.s	$400      ;max angle inc
	.dc.s	-$f0000     ;min velocity inc
	.dc.s	$f0000      ;max velocity inc
	.dc.s	-$7fff0000
	.dc.s	$7fff0000
	.dc.s	-$f0000,$f0000,0,0,0,0,0

; Command section

    .ascii  "A0=h"              ;set address of polyline in object
    .ascii  "A1=c"              ;set colour in d
    .ascii  "c=d"               ;set colour in c
    .ascii  "A2=e"              ;set scale

    .ascii  "@x[34]+G0=G0"      ;set rotate angle from stick in G0
    .ascii  "G0=g"              ;set angle in object
    .ascii  "G0*@0?C1"          ;if button 0 pressed, set phase of C to G0
    .ascii  "g+A3=B1"           ;if the button is pressed. set phase of B from angle + constant A3
    .ascii  "@y[56]+F1=F1;"     ;if the button is pressed, inc velocity; end of conditional.
    .ascii  "F1*B[9:]+D1=D1"    ;increase X-velocity from sine
    .ascii  "F1*C[9:]+E1=E1"    ;increase Y-velocity from cosine
    .ascii  "G1+E1=E1"          ;grav!
    .ascii  "D0!=a<"            ;set X position
    .ascii  "E0!=a>:"           ;set Y-position and finish
    

	.align.v

lndr_end: