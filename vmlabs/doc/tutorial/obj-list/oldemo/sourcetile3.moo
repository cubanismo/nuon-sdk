
;
; sourcetile0.moo = a MacrOObject that
; defines a source tile.

st3:

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	($1c0a0080|sourcetile)
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	0	        ;prototype to use
	.dc.s	0			;no secondary data

	.dc.s	st3_end-st3		;length
	.dc.s	0				;init routine
	.dc.s	$0              ;clock-mode
    .dc.s   0      
    
	.dc.s	0,0,0,0


; local paramspace

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $0c100      ;Speed
    .dc.s   1           ;Mode (Sawtooth)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $2f100      ;Speed
    .dc.s   0           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $1c100      ;Speed
    .dc.s   1           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   -$31100      ;Speed
    .dc.s   0           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $15100      ;Speed
    .dc.s   1           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $23100      ;Speed
    .dc.s   0           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $0f100      ;Speed
    .dc.s   1           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $22100      ;Speed
    .dc.s   1           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $2c100      ;Speed
    .dc.s   0           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $18100      ;Speed
    .dc.s   1           ;Mode (Sine)


; ranges

	.dc.s	$20
	.dc.s	$80	
	.dc.s	$f0
	.dc.s	$08
	.dc.s	0
	.dc.s	$3fff0000
	.dc.s	$3ffff
	.dc.s	$10
	.dc.s	$04ff0000
	.dc.s	$01ff0000,$1ff0000,0,0,0,0,0

; secondary data
    
    .dc.s   6,$00,flipper_masks,tile_img
    
    .dc.s   $d292107f,$0005,spot_mask,$1fffffff
    .dc.s   $61c08a7f,0,spot_mask,$fffffff
    .dc.s   $41f08a7f,0,spot_mask,$fffffff
    .dc.s   $41f08a7f,0,spot_mask,$fffffff
    .dc.s   $41f08a7f,0,spot_mask,$fffffff
    .dc.s   $10808000,0,full_mask,$1f00000

; command

    .ascii  "_a=a"
    .ascii  "$_e=b"
    .ascii  "_d=c"
    .ascii  "C[46]!#_c=_g"
    .ascii  "A[43]=_j<"
    .ascii  "B[40]=_j>"
    .ascii  "C[43]=_n<"
    .ascii  "D[40]=_n>"
    .ascii  "E[43]=_r<"
    .ascii  "G[40]=_r>"
    .ascii  "H[43]=_v<"
    .ascii  "I[40]=_v>"

;    .ascii  "I[40]=_f<"
    .ascii  "F[40]=_f>:"

	.align.v

st3_end: