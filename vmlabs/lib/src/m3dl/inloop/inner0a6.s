/*
 * Title	INNER0A6.S
 * Description	MPR Inner Loop 0A6
 * Version	1.0
 * Start Date	11/05/98
 * Last Update	11/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn0A6
	.origin		mprinnerbase

	.export _inn0A6_start, _inn0A6_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	CLUT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	1	Color On
	;* 8    0       No Alpha

	;* Setup	6 cycles
	;* Per Pixel	4 cycles
	;* Exit		2 cycles
MPR_inn0A6:
       {
	ld_p	(uv),v1			;Read Pixel
	addr	_DU,ru			;Next U
	sub_sv	v3,v3			;Clear v3
       }
       {
	addr	_DV,rv			;Add Delta V
	bset	#29,v3[1]		;1/2 in 2.30 format
       }
       {
	mv_s	v3[1],v3[2]		;1/2 in 2.30 format
	lsr	#1,r4			;16 Bit Clut
       }
       {
	ld_p	(r4),v1			;Read source pixel
	sub	_DU,#0,v0[3]		;v0[3] -_DU
       }
       {
	ld_p	(uv),v0			;Read clut lookup
	sub	_DV,#0,v1[3]		;v1[3] -_DV
       }
	mul_p	_GRBA,v1,>>#30,v2	;GRB Multiply

`loop:
       {
	addr	_DU,ru			;Add Delta U
	dec	rc0			;Decrement Loop Counter
	mv_s	_Z,v2[3]		;Insert Z
	lsr	#1,r0			;16 Bit Clut
       }
       {
	bra	c0ne,`loop              ;Loop
	ld_p	(r0),v1			;Read source pixel
	addr	_DV,rv			;Add Delta V
	add_p	_DGRBA,_GRBA		;Next GRBA
       }
       {
	ld_p	(uv),v0			;Read clut lookup
	sub_p	v3,v2			;CHNORM
	addm	_DZ,_Z			;Next Z
       }
       {
	st_pz	v2,(xy)			;Store destination pixel
	addr	#1<<16,rx		;Next Pixel
	mul_p	_GRBA,v1,>>#30,v2	;GRB Multiply
	rts
       }
       ;--------------------------------;bra c0ne,`loop
       {
	addr	v0[3],ru		;Re-Step ru
	sub	r1,r1			;Clear Translucency Flag
       }
       {
	addr	v1[3],rv		;Re-Step rv
	sub	r0,r0			;No Transparent Pixels
       }
       ;--------------------------------;rts

