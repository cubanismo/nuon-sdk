
;
; sourcetile0.moo = a MacrOObject that
; defines a source tile.

st0:

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	($0c030080|sourcetile)
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	0	        ;prototype to use
	.dc.s	0			;no secondary data

	.dc.s	st0_end-st0		;length
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
    .dc.s   $0f100      ;Speed
    .dc.s   2           ;Mode (Sine)

 	.dc.s   0           ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $1c100      ;Speed
    .dc.s   1           ;Mode (Sine)

; ranges

	.dc.s	$20
	.dc.s	$80	
	.dc.s	$f0
	.dc.s	$20
	.dc.s	0
	.dc.s	$3fff0000
	.dc.s	$4ffff
	.dc.s	$10
	.dc.s	$04ff0000
	.dc.s	$01ff0000,$1ff0000,0,0,0,0,0

; secondary data
    
    .dc.s   2,$00,thingy_masks,tile_img
    
    .dc.s   $51f05a00,0,spot_mask,$7ffffff
    .dc.s   $10808000,0,full_mask,$1f00000

; command

    .ascii  "_a=a"
    .ascii  "$_e=b"
    .ascii  "_d=c"
    .ascii  "C[46]!#_c=_g"
    .ascii  "A[43]=_f<"
    .ascii  "B[43]=_f>:"

	.align.v

st0_end: