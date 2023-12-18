
;
; cursor2.moo = a MacrOObject that
; defines a simple cross cursor
; whose *velocity* is attached to the joystick.

boball:

; header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$3030000		;3 vects params
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	fcircobj	    ;prototype to use
	.dc.s	0				;no secondary data

	.dc.s	boball_end-boball		;length
    .dc.s   $0600                   ;external routines/events
    .dc.s   0
    .dc.s   0

    .dc.s   ($100000)             ;(EVNTEN|??????) - enable Collision Event, set Info 1
    .dc.s   0           ;Collision Size (X|Y)
    .dc.s   (COCA|COPOINT|CODBEN|COLEN) ;Events|Collision Flags)
    .dc.s   0           ;Time slew

; variables

	.dc.s	bat     ;Address of polyline definition
    .dc.s   $71deca00   ;Colour     
    .dc.s   $00100010   ;Scale   
    .dc.s   $0

    .dc.s   $b00000     ;pos
    .dc.s   $20000           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000201   ;lim, type etc.

    .dc.s   $800000     ;pos
    .dc.s   $10000           ;vel
    .dc.s   $10000      ;fr
    .dc.s   $80000262   ;lim, type etc.

; ranges

	.dc.s	$200000
	.dc.s	$1200000    ;max X	
	.dc.s	$e00000     ;max Y
	.dc.s	-$180000     ;min velocity
	.dc.s	$180000      ;max velocity
	.dc.s	$1000      
	.dc.s	$140000
	.dc.s	$000
	.dc.s	$20
	.dc.s	0,0,0,0,0,0,0

; local

    .dc.s   $f0808000   ;colour
    .dc.s   $010000c0   ;scales
    .dc.s   $0006f000   ;size/edge-width
    
; command

    .ascii  "_a=c"
    .ascii  "_b=e"
    .ascii  "_c=b"
;    .ascii  "A0=h"              ;set address of polyline in object
;    .ascii  "A1=c"
;    .ascii  "c=d"               ;set colour
;    .ascii  "A2=e"              ;set scale

;    .ascii  "@x[34]=B1"         ;set xvel from stick
;    .ascii  "@y[34]=C1"         ;set yvel from stick
;    .ascii  "@x[75]=g"          ;check it out!
    .ascii  "B0!=a<"            ;set xpos to int b-pos
    .ascii  "C0!=a>:"            ;set ypos to int c-pos, end.

	.align.v

boball_end: