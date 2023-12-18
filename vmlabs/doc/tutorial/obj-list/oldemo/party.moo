
;
; cursor2.moo = a MacrOObject that
; defines a simple cross cursor
; whose *velocity* is attached to the joystick.

party:

; header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$3040000		;3 vects sec data
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	particleobj	    ;prototype to use
	.dc.s	0				;no secondary data

	.dc.s	party_end-party		;length
    .dc.s   3,0,0

    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   0

; waves

    .dc.s   0 
    .dc.s   0 
    .dc.s   $5000 
    .dc.s   2 

    .dc.s   0 
    .dc.s   0 
    .dc.s   $1450 
    .dc.s   2 
 
    .dc.s   0 
    .dc.s   0 
    .dc.s   $12450 
    .dc.s   2 

    .dc.s   0 
    .dc.s   0 
    .dc.s   $6000 
    .dc.s   2 
    

; ranges

	.dc.s	$020000     ;min X scale
	.dc.s	$ff0000    ;max X	
	.dc.s	$020000     ;min Y scale
	.dc.s	$ff0000    ;max Y scale
	.dc.s	$0          ;zero
	.dc.s	$3fff       ;max blend       
	.dc.s	-$80000
	.dc.s	$18000
	.dc.s	$2000       ;min blend
	.dc.s	10,32,0,0,0,0,0

; sec

    .dc.s   $00b40098       ;position
    .dc.s   48             ;n-particles
    .dc.s   0

; command

    .ascii  "A[01]=j"
    .ascii  "B[23]=k"
    .ascii  "C*A[85]=h<"
    .ascii  "D[9:]=n"
;    .ascii  "A*B[47]=g"
    .ascii  "_b=i"
    .ascii  "_a=a:"

	.align.v

party_end: