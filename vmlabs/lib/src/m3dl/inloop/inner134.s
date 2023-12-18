/*
 * Title	INNER134.S
 * Description	MPR Inner Loop 134
 * Version	1.0
 * Start Date	11/08/98
 * Last Update	11/08/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn134
	.origin		mprinnerbase

	.export _inn134_start, _inn134_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	11 cycles
	;* Per Pixel	8 cycles
	;* Exit		2 cycles
MPR_inn134:
       {
	mv_s	#-0x8000,v2[3]		;v1[3] -0.5 in 16.16
       }
       {
	mv_s	#1<<29,v3[3]		;0.5 in 2.30
	addr	v2[3],ru		;ru - 0.5
	add	_DU,v2[3],v1[3]		;-0.5 + _DU
       }
       {
	addr	v2[3],rv		;rv - 0.5
	add	_DV,v2[3],v2[3]		;-0.5 + _DV
       }
       {
	ld_p	(uv),v0			;Read pixel0
	addr	#1<<16,ru		;ru+1
	neg	v1[3]			;0.5 - _DU
       }
       {
	ld_p	(uv),v1                 ;Read pixel1
	addr	#1<<16,rv		;rv+1
	neg	v2[3]			;0.5 - _DV
       }
       {
	ld_p	(uv),v3                 ;Read pixel3
	addr	#-1<<16,ru		;ru-1
       }
       {
	ld_p	(uv),v2                 ;Read pixel2
	addr	#-1<<16,rv		;rv-1
	sub_p	v0,v1			;pixel1-pixel0
       }
       {
	mul_p	ru,v1,>>#30,v1		;ru(pixel1-pixel0)
	addr	#-1<<16,rx		;rx-1
       }
       {
	sub_p	v2,v3			;pixel3-pixel2
	mv_s	#1<<30,v0[3]		;v0[3] = One as 2.30
       }
       {
	mul_p	ru,v3,>>#30,v3		;ru(pixel3-pixel2)
	addr	_DU,ru	 		;Step ru
	mv_s	v0[3],_DGRBA[3]		;_DGRBA[3] = 0x40000000
	sub	_DZ,_Z			;Pre-Step _Z
       }
       {
	add_p	v0,v1,_UVZ		;pixel0 + ru(pixel1-pixel0)
	mul_sv	rv,_DGRBA,>>#30,_DGRBA	;_DGRBA[3] = rv
	addr	_DV,rv  		;Step rv
       }

`loop:
       {
	ld_p	(uv),v0			;Read pixel0
	addr	#1<<16,ru		;ru+1
	dec	rc0			;Decrement Loop Counter
	sub_p	_UVZ,v2			;pixel2-(pixel0+ru(pixel1-pixel0))
       }
       {
	ld_p	(uv),v1                 ;Read pixel1
	addr	#1<<16,rv		;rv+1
	add_p	v3,v2			;(pixel2+ru(pixel3-pixel2))-(pixel0+ru(pixel1-pixel0))
	addm	_DZ,_Z 			;Step Z
       }
       {
	ld_p	(uv),v3                 ;Read pixel3
	addr	#-1<<16,ru		;ru-1
	mul_p	_DGRBA[3],v2,>>#30,_DGRBA;rv((pixel2+ru(pixel3-pixel2))-(pixel0+ru(pixel1-pixel0)))
	sub	v3[3],_UVZ[1]		;CHNORM Red
       }
       {
	ld_p	(uv),v2                 ;Read pixel2
	addr	#-1<<16,rv		;rv-1
	sub_p	v0,v1			;pixel1-pixel0
       }
       {
	add_p	_DGRBA,_UVZ		;(pixel0+ru(pixel1-pixel0))+rv((pixel2+ru(pixel3-pixel2))-(pixel0+ru(pixel1-pixel0)))
	mul_p	ru,v1,>>#30,v1		;ru(pixel1-pixel0)
	addr	#1<<16,rx		;rx+1
       }
       {
	sub_p	v2,v3			;pixel3-pixel2
	bra	c0ne,`loop		;Loop
       }
       {
	mul_p	ru,v3,>>#30,v3		;ru(pixel3-pixel2)
	addr	_DU,ru 			;Step ru
	mv_s	v0[3],_DGRBA[3]		;_DGRBA[3] = 0x40000000
	sub	v3[3],_UVZ[2]		;CHNORM Blue
       }
       {
	st_pz	_UVZ,(xy)		;Store destination pixel
	add_p	v0,v1,_UVZ		;pixel0 + ru(pixel1-pixel0)
	mul_sv	rv,_DGRBA,>>#30,_DGRBA	;_DGRBA[3] = rv
	addr	_DV,rv 			;Step rv
	rts				;Done
       }
       ;--------------------------------;bra c0ne,`loop
       {
	add	_DZ,_Z 			;Step Z
	addr	v1[3],ru		;Re-Step ru
       }
       {
	addr	v2[3],rv		;Re-Step rv
	subm	r0,r0			;No Transparent Pixels
	mv_s	#1,r1			;Set Translucency Flag
       }
       ;--------------------------------;rts

