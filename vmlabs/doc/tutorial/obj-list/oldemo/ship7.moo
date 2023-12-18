;
; ship7.moo = a MacrOObject that
; defines a simple type of ship
; controlled by the joystick.
;
; This one is a Lunar Lander with a thrust-flame!

lndr2:

; Header block

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$05080000		;3 secondary data, 7 vects of variables
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype object to use
	.dc.s	0			;no secondary data

	.dc.s	lndr2_end-lndr2		;length
    .dc.s   0,0,0

    .dc.s   0,0,0,0

; Variables

    .dc.s   lland       ;Polyline definition
    .dc.s   $f080f000   ;Colour
    .dc.s   $00140014   ;Scale
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

    .dc.s   0           ;Phase
    .dc.s   0           ;Phase offset
    .dc.s   $1c2000      ;Speed
    .dc.s   $1          ;triangle

; Range table

	.dc.s	0
	.dc.s	$1680000    ;max X
	.dc.s	$c00000     ;max Y
	.dc.s	-$400     ;min angle inc
	.dc.s	$400      ;max angle inc
	.dc.s	$0000     ;min velocity inc
	.dc.s	$f0000      ;max velocity inc
	.dc.s	$00b0       ;minimum flame ypos
	.dc.s	$01f0       ;maximum flame ypos

	.dc.s	-$f0000,$f0000,0,$40,0,0,0

; Secondary data.

    .dc.s   lland_xtra          ;Address of a link in the llander definition.
    .dc.s   $80000001           ;The default value there - end.
    .dc.s   $80000002           ;If the button is pressed, put this in instead.
    .dc.s   lland_tail          ;Address of the tail point of the flame.
    .dc.s   $00f00000           ;Default value of same.

; Command section

    .ascii  "A0=h"              ;set address of polyline in object
    .ascii  "A1=c"              ;set colour in d
    .ascii  "c=d"               ;set colour in c
    .ascii  "A2=e"              ;set scale

    .ascii  "@x[34]+G0=G0"      ;set rotate angle from stick in G0
    .ascii  "G0=g"              ;set angle in object
    .ascii  "_a%_b"             ;Default _b to (_a).
    .ascii  "G0*@0?C1"          ;if button 0 pressed, set phase of C to G0
    .ascii  "_a%_c"             ;Inside the conditional, store _c at (_a).
    .ascii  "@y[78]=_e<"        ;Set flame size according to ystick
    .ascii  "H[0<]+_e<=_e<"     ;add flicker displacement
    .ascii  "_d%_e"             ;store it in the polyline-def
    .ascii  "g+A3=B1"           ;if the button is pressed. set phase of B from angle + constant A3
    .ascii  "@y[56]~+F1=F1;"     ;if the button is pressed, inc velocity; end of conditional.
    .ascii  "F1*B[9:]+D1=D1"    ;increase X-velocity from sine
    .ascii  "F1*C[9:]+E1=E1"    ;increase Y-velocity from cosine
    .ascii  "G1+E1=E1"          ;grav!
    .ascii  "D0!=a<"            ;set X position
    .ascii  "E0!=a>:"           ;set Y-position and finish


	.align.v

lndr2_end: