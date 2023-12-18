
;
; asteroid.moo = a MacrOObject that
; defines an Asteroids asteroid

ast:

; header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$60000		;Type (Zero), 6 vects params
	.dc.s	0			;Address of parameter block if not local

	.dc.s	ast_ranges			;Address of ranges table, if not local
	.dc.s	ast_command			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0				;no secondary data

	.dc.s	ast_end-ast		;length
	.dc.s	2				;init routine (called when object is first generated)
	.dc.s	0,0

	.dc.s	0,0,0,0

; variables

 	.dc.s   0           ;xpos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr.
    .dc.s   $80000164   ;mode (wrap), limits

 	.dc.s   0           ;ypos
    .dc.s   0           ;vel
    .dc.s   $10000      ;fr.
    .dc.s   $80000174   ;mode (wrap), limits


 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $18100    ;Speed
    .dc.s   0       ;Mode (Sawtooth)

 	.dc.s   0       ;Phase relative to current
    .dc.s   asteroid       ;Phase offset (doesn't matter what it is, so using it as storage)
    .dc.s   $1c100    ;Speed
    .dc.s   2       ;Mode (Sine)

 	.dc.s   0               ;Phase relative to current
    .dc.s   $00100010       ;Phase offset (actually storage for scales)
    .dc.s   $1e100    ;Speed
    .dc.s   $2       ;Mode (Sine)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $13100    ;Speed
    .dc.s   2       ;Mode (Sine)

ast_end: