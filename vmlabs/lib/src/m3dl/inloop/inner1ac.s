/*
 * Title	INNER1AC.S
 * Description	MPR Inner Loop 1AC
 * Version	1.0
 * Start Date	12/30/98
 * Last Update	12/30/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn1AC
	.origin		mprinnerbase

	.export _inn1AC_start, _inn1AC_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	1	GRB Screen
	;* 3	1	Perspective Correct
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	1	Color On
	;* 8    1       Alpha On

	;* Setup	11 cycles
	;* Per Pixel	10 cycles
	;* Exit		1 cycle

MPR_inn1AC:
	msb	_iZ,v3[1]			;msb _iZ
	sub	#indexbits+1+1,v3[1],v3[2]	;Indexshift
	as	v3[2],_iZ,v3[2]			;Indexoffset
	add	#MPR_RecipLUT - 128*sizeofscalar,v3[2]
       {
	ld_w	(v3[2]),v3[2]			;Fetch RecipLut value
	sub_sv	v2,v2			;Clear v2
       }
	copy	_iZ,v3[3]			;_iZ value
       {
	mv_s	#fix(2,iprec),v0[3]	;v0[3] #fix(2,iprec)
	mul	v3[2],v3[3],>>v3[1],v3[3]	;z*RecipLut value
	bset	#29,v2[1]		;1/2 in 2.30 format
       }
       {
	mv_s	v2[1],v2[2]		;1/2 in 2.30 format
	add	#iprec-(preciz+precuviz),v3[1],v2[3]	;Resulting fracbits
       }
       {
	subm	v3[3],v0[3],v3[3]		;2 - z*RecipLut value
	add	_DiZ,_iZ			;Next _iZ
       }
       {
	mul	v3[2],v3[3],>>#iprec,v3[3]	;RecipLut(2 - z*RecipLut)
	msb	_iZ,v3[1]			;msb _iZ
       }
       {
	mv_s	_U,v0[0]			;_U*iZ
	sub	#indexbits+1+1,v3[1],v3[2]	;Indexshift
       }


`loop:
       {
	as	v3[2],_iZ,v3[2]			;Indexoffset
	mul	v3[3],v0[0],>>v2[3],v0[0]	;_U
	mv_s	_V,v0[1]			;_V*iZ
       }
       {
	add	#MPR_RecipLUT - 128*sizeofscalar,v3[2]
	mul	v3[3],v0[1],>>v2[3],v0[1] 	;_V
	mv_s	_iZ,v3[3]			;_iZ value
       }
       {
	mvr	v0[0],ru			;Set ru
	add	_DU,_U				;Next _U
	ld_w	(v3[2]),v3[2]			;Fetch RecipLut value
       }
       {
	mvr	v0[1],rv			;Set rv
	dec	rc0				;Decrement Loop Counter
	addm	_DV,_V				;Next _V
	add	_DiZ,_iZ			;Next _iZ
       }
       {
	ld_p	(uv),v1				;Read Pixel
	mul	v3[2],v3[3],>>v3[1],v3[3]	;z*RecipLut value
	add	#iprec-(preciz+precuviz),v3[1],v2[3]	;Resulting fracbits
       }
       {
	msb	_iZ,v3[1]			;msb _iZ
       }
       {
	sub	v3[3],v0[3],v3[3]		;2 - z*RecipLut value
	mul_p	_GRBA,v1,>>#30,v1		;Multiply GRB
	mv_s	_Z,v1[3]			;Insert _Z
       }
       {
	bra	c0ne,`loop			;Loop
	mul	v3[2],v3[3],>>#iprec,v3[3]	;RecipLut(2 - z*RecipLut)
	sub	#indexbits+1+1,v3[1],v3[2]	;Indexshift
	mv_s	_U,v0[0]			;_U*iZ
       }
       {
	rts					;Done
	sub_p	v2,v1 				;CHNORM
       }
       {
	st_pz	v1,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	add_p	_DGRBA,_GRBA			;Next _GRBA
	addm	_DZ,_Z				;Next _Z
       }
       ;----------------------------------------;bra c0ne,`loop
       {
	subm	r0,r0			;No Transparent Pixels
	sub	_DiZ,_iZ		;Re-Step _iZ
	mv_s	#1,r1			;Set Translucency Flag
       }
       ;----------------------------------------;rts

