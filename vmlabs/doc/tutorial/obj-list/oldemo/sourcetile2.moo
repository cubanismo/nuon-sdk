
;
; sourcetile.moo = a MacrOObject that
; defines a source tile.

st2:

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$12060083		;Type (Zero), ten vects params, run init external routine 3
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	0	;prototype to use
	.dc.s	0				;no secondary data

	.dc.s	st2_end-st2		;length
	.dc.s	0				;init routine
	.dc.s	$0               ;clock-mode
    .dc.s   0      
    
	.dc.s	0,0,0,0


; local paramspace

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $0c100    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Sawtooth)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $0f100    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Sawtooth)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $1c100    ;Clock (24:8, relative to framecounter)
    .dc.s   2       ;Mode (Sawtooth)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $1f100    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Sawtooth)

 	.dc.s   0       ;Phase relative to current
    .dc.s   $2743       ;Phase offset
    .dc.s   $15100    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Sawtooth)

    .dc.s   0       ;Phase relative to current
    .dc.s   $7743       ;Phase offset
    .dc.s   $1c100    ;Clock (24:8, relative to framecounter)
    .dc.s   1       ;Mode (Sawtooth)

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
    
    .dc.s   4,$00ff,thingy_masks,tile_img
    
    .dc.s   $51f05a00,0,spot_mask,$3ffffff
    .dc.s   $d2921000,0,spot_mask,$3ffffff
    .dc.s   $306ef000,0,spot_mask,$3ffffff
    .dc.s   $10808000,0,full_mask,$2f00000


    .ascii  "_a=a"
    .ascii  "$_e=b"
    .ascii  "_d=c"
    .ascii  "D[46]!#_c=_k"
    .ascii  "C[46]!#_c=_o"
    .ascii  "B[46]!#_c=_g"
    .ascii  "A[43]=_f<"
    .ascii  "B[43]=_f>"
    .ascii  "_f=_j"
    .ascii  "_f=_n"
    .ascii  "E[47]+_f<=_j<"
    .ascii  "F[47]+_f>=_n>"
    .ascii  "C[02]=_q0"
    .ascii  "B[02]=_q1"
    .ascii  "A[02]=_q2:"

	.align.v

st2_end: