/*
 * Title	INNER0A1.S
 * Description	MPR Inner Loop 0A1
 * Version	1.0
 * Start Date	11/05/98
 * Last Update	11/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn0A1
	.origin		mprinnerbase

	.export _inn0A1_start, _inn0A1_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	0	DIRECT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	1	Color On
	;* 8    0       No Alpha

	;* Setup	2 cycles
	;* Per Pixel	3 cycles
	;* Exit		2 cycles
MPR_inn0A1:
       {
	ld_p	(uv),v0			;Read Pixel
	sub	_DU,#0,v2[2]		;v1[3] -_DU
	addr	_DU,ru			;Next U
       }
       {
	sub	_DV,#0,v2[3]		;v2[3] -_DV
	addr	_DV,rv			;Next V
	dec	rc0			;Decrease Loop Counter
       }

`loop:
       {
	bra	c0ne,`loop		;Loop
	ld_p	(uv),v0			;Read Pixel
	mul_p	_GRBA,v0,>>#30,v1	;Multiply GRB
	addr	_DU,ru			;Next U
       }
       {
	addr	_DV,rv 			;Next V
	dec	rc0			;Decrease Loop Counter
	copy	_Z,v1[3]		;Insert Z Value
       }
       {
	st_pz	v1,(xy)			;Store New Pixel
	addr	#1<<16,rx		;Next Pixel
	add_p	_DGRBA,_GRBA		;Next _GRBA
	addm	_DZ,_Z			;Next Z
	rts
       }
       ;--------------------------------;bra c0ne,`loop
       {
	addr	v2[2],ru		;Re-Step ru
	sub	r1,r1			;Clear Translucency Flag
       }
       {
	addr	v2[3],rv		;Re-Step rv
	sub	r0,r0			;No Transparent Pixels
       }
       ;--------------------------------;rts

