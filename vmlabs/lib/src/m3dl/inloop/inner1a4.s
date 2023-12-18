/*
 * Title	INNER1A4.S
 * Description	MPR Inner Loop 1A4
 * Version	1.0
 * Start Date	11/05/98
 * Last Update	11/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn1A4
	.origin		mprinnerbase

	.export _inn1A4_start, _inn1A4_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture On
	;* 6	0	Black Opaque
	;* 7	1	Color On
	;* 8    0       No Alpha

	;* Setup	3 cycles
	;* Per Pixel	3 cycles
	;* Exit		2 cycles
MPR_inn1A4:
       {
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	sub_sv	v2,v2			;Clear v2
       }
       {
	addr	_DV,rv			;Next V
	bset	#29,v2[1]		;1/2 in 2.30 format
	dec	rc0			;Decrease Loop Counter
       }
       {
	mul_p	_GRBA,v0,>>#30,v3	;Multiply GRB
	mv_s	v2[1],v2[2]		;1/2 in 2.30 format
	add_p	_DGRBA,_GRBA		;Next _GRBA
       }
`loop:
       {
	bra	c0ne,`loop		;Loop
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	copy	_Z,v1[3]		;Insert Z Value
       }
       {
	addr	_DV,rv 			;Next V
	dec	rc0			;Decrease Loop Counter
	addm	_DZ,_Z			;Next Z
	sub_p	v2,v3,v1		;CHNORM
       }
       {
	mul_p	_GRBA,v0,>>#30,v3	;Multiply GRB
	add_p	_DGRBA,_GRBA		;Next _GRBA
	st_pz	v1,(xy)			;Store New Pixel
	addr	#1<<16,rx		;Next Pixel
       }
       ;--------------------------------;bra c0ne,`loop
       {
	rts				;Done
	sub	_DU,#0,v2[3]		;v2[3] -_DU
	mv_s	#1,r1			;Set Translucency Flag
       }
       {
	addr	v2[3],ru 		;Re-Step ru
	sub	_DV,#0,v2[3]		;v2[3] -_DU
       }
       {
	addr	v2[3],rv 		;Re-Step ru
	sub_p	_DGRBA,_GRBA		;Re-Step _GRBA
	subm	r0,r0			;No Transparent Pixels
       }
       ;--------------------------------;rts

