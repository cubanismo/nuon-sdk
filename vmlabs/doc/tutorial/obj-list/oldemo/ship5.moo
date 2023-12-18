
;
; ship5.moo = a MacrOObject that
; defines a ship that behaves like
; an Asteroids player's ship (except
; that it bounces off the top and bottom
; screen edges); and also the amount of
; Thrust when the button is pressed is
; defined by the Y position of the
; joystick.


astship2:

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$50000		;Type (Zero), 5 vects variables
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0			;no secondary data

	.dc.s	astship2_end-astship2		;length
    .dc.s   0,0,0

	.dc.s	$0,0,0,0

; Variables

 	.dc.s   $c000       ;A is used mostly for storage
    .dc.s   $0          
    .dc.s   $0000       
    .dc.s   $2000000    ;Acceleration, added when button is pressed

 	.dc.s   $b00000     ;X Position 16:16
    .dc.s   $000        ;Velocity
    .dc.s   $ff00       ;Friction
    .dc.s   $80000123   ;Mode (Positional, Limits [2:3], Wrap 

 	.dc.s   $780000     ;Y Position 16:16
    .dc.s   $000        ;Velocity
    .dc.s   $ff00       ;Friction
    .dc.s   $80000224   ;Mode (Positional, Limits [2:4], Bounce 

    .dc.s   0,0,0,$2    ;Sine wave used to generate X accel component

    .dc.s   0,0,0,$2    ;Sine wave used to generate Y accel component

; Ranges

	.dc.s	-$7f0       ;Rotate speed limits
	.dc.s	$7f0	
	.dc.s	0
	.dc.s	$1680000    ;X position max
	.dc.s	$f00000     ;Y position max
	.dc.s	-$20000
	.dc.s	$20000
	.dc.s	-$8000000   ;accel min
	.dc.s	$8000000    ;accel max
	.dc.s	0,0,0,0,0,0,0

; Command

    .ascii  "@x[01]+D1=D1"      ;add phase from joy X to D1
    .ascii  "D1=g"              ;sets rotate angle from D1
    .ascii  "D1+A0=E1"          ;set phase of E to phase of D offset by -1/4
    .ascii  "@y[78]~*@0=A2"          ;add thrust to A2 (evaluates to 0 if button not pressed)
    .ascii  "A2*D[56]+B1=B1"          ;set X vel
    .ascii  "A2*E[56]+C1=C1"          ;set Y vel
    .ascii  "B0!=a<"            ;xpos = int of B's positional
    .ascii  "C0!=a>:"           ;ypos = int of C's positional    

	.align.v

astship2_end: