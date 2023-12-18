
;
; cursor2.moo = a MacrOObject that
; defines a simple cross cursor
; whose *velocity* is attached to the joystick.

bobat:

; header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$30000		;3 vects params
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	clsobj	    ;prototype to use
	.dc.s	0				;no secondary data

	.dc.s	bobat_end-bobat		;length
    .dc.s   0,0,0

    .dc.s   ($100000|COINF3)             ;(EVNTEN|??????) - enable Collision Event
    .dc.s   $00200004           ;Collision Size (X|Y)
    .dc.s   (COBOX|COLEN) ;Events|Collision Flags)
    .dc.s   0           ;Time slew

 
 
; variables

	.dc.s	$00200004   ;size
    .dc.s   $f0808000   ;Colour     
    .dc.s   $00100010   ;Scale   
    .dc.s   $0

    .dc.s   $b00000     ;pos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000301   ;lim, type etc.

    .dc.s   $e00000     ;pos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000362   ;lim, type etc.

; ranges

	.dc.s	$1c0000     ;min X
	.dc.s	$1060000    ;max X	
	.dc.s	$d00000     ;max Y
	.dc.s	-$180000     ;min velocity
	.dc.s	$180000      ;max velocity
	.dc.s	$1000      
	.dc.s	$b00000
	.dc.s	$000
	.dc.s	$20
	.dc.s	0,0,0,0,0,0,0

; command

    .ascii  "A0=b"              ;set address of polyline in object
    .ascii  "A1=c"
;    .ascii  "c=d"               ;set colour
;    .ascii  "A2=e"              ;set scale

    .ascii  "@x[34]=B1"         ;set xvel from stick
;    .ascii  "@y[34]=C1"         ;set yvel from stick
;    .ascii  "@x[75]=g"          ;check it out!
    .ascii  "B0!=a<"            ;set xpos to int b-pos
    .ascii  "C0!=a>:"            ;set ypos to int c-pos, end.

	.align.v

bobat_end: