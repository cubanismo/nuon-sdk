/*
 * Title	INNER124.S
 * Description	MPR Inner Loop 124
 * Version	1.0
 * Start Date	11/05/98
 * Last Update	11/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn124
	.origin		mprinnerbase

	.export _inn124_start, _inn124_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    1       Alpha On

	;* Setup	3 cycles
	;* Per Pixel	3 cycles
	;* Exit		2 cycles
MPR_inn124:
       {
	ld_p	(uv),v1			;Read Pixel
	addr	_DU,ru			;Next U
	sub_sv	v2,v2			;Clear v2
       }
       {
	addr	_DV,rv			;Next V
	dec	rc0			;Decrease Loop Counter
	bset	#29,v2[1]		;1/2 in 2.30 format
       }
       {
	mv_s	v2[1],v2[2]		;1/2 in 2.30 format
	sub	v2[1],v1[1]		;CHNORM
	subm	v2[1],v1[2]		;CHNORM
       }
`loop:
       {
	bra	c0ne,`loop		;Loop
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	copy	_Z,v1[3]		;Insert Z Value
       }
       {
	st_pz	v1,(xy)			;Store New Pixel
	addr	#1<<16,rx		;Next Pixel
	dec	rc0			;Decrease Loop Counter
	addm	_DZ,_Z			;Next Z
	sub	_DU,#0,v2[3]		;v2[3] -_DU
       }
       {
	addr	_DV,rv 			;Next V
	sub_p	v2,v0,v1		;CHNORM
	rts				;Done
       }
       ;--------------------------------;bra c0ne,`loop
       {
	addr	v2[3],ru 		;Re-Step ru
	neg	_DV			;-_DV
	mv_s	#1,r1			;Set Translucency Flag
       }
       {
	addr	_DV,rv			;Re-Step rv
	neg	_DV			; _DV
	subm	r0,r0			;No Transparent Pixels
       }
       ;--------------------------------;rts

