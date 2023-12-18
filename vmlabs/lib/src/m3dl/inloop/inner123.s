/*
 * Title	INNER123.S
 * Description	MPR Inner Loop 123
 * Version	1.0
 * Start Date	11/05/98
 * Last Update	11/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn123
	.origin		mprinnerbase

	.export _inn123_start, _inn123_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	1	CLUT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	3 cycles
	;* Per Pixel	4 cycles
	;* Exit		2 cycles
MPR_inn123:
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	lsr	#1,r0			;16 Bit Clut

`loop:
       {
	ld_p	(r0),v1			;Read source pixel
	addr	_DV,rv			;Add Delta V
	dec	rc0			;Decrement Loop Counter
       }
       {
	bra	c0ne,`loop              ;Loop
	ld_p	(uv),v0			;Read clut lookup
	sub	_DU,#0,v2[2]		;v2[2] -_DU
       }
       {
	rts
	copy	_Z,v1[3]		;Insert Z
	addm	_DZ,_Z			;Next Z
	addr	_DU,ru			;Add Delta U
       }
       {
	st_pz	v1,(xy)			;Store destination pixel
	addr	#1<<16,rx		;Next Pixel
	lsr	#1,r0			;16 Bit Clut
       }
       ;--------------------------------;bra c0ne,`loop
       {
	addr	v2[2],ru		;Re-Step ru
	sub	r0,r0			;No Transparent Pixels
	mv_s	#1,r1			;Set Translucency Flag
       }
       ;--------------------------------;rts

