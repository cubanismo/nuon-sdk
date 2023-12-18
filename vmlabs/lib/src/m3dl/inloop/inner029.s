/*
 * Title	INNER029.S
 * Description	MPR Inner Loop 029
 * Version	1.0
 * Start Date	12/30/98
 * Last Update	12/30/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn029
	.origin		mprinnerbase

	.export _inn029_start, _inn029_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	0	DIRECT
	;* 2	0	YCC Screen
	;* 3	1	Perspective Correct
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	10 cycles
	;* Per Pixel	9 cycles
	;* Exit		1 cycle

MPR_inn029:
	msb	_iZ,v3[1]			;msb _iZ
	sub	#indexbits+1+1,v3[1],v3[2]	;Indexshift
	as	v3[2],_iZ,v3[2]			;Indexoffset
	add	#MPR_RecipLUT - 128*sizeofscalar,v3[2]
	ld_w	(v3[2]),v3[2]			;Fetch RecipLut value
	copy	_iZ,v3[3]			;_iZ value
       {
	mv_s	#fix(2,iprec),v0[3]	;v0[3] #fix(2,iprec)
	mul	v3[2],v3[3],>>v3[1],v3[3]	;z*RecipLut value
       }
       {
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


`loop:
       {
	sub	#indexbits+1+1,v3[1],v3[2]	;Indexshift
	mv_s	_U,v1[0]			;_U*iZ
       }
       {
	as	v3[2],_iZ,v3[2]			;Indexoffset
	mul	v3[3],v1[0],>>v2[3],v1[0]	;_U
	mv_s	_V,v1[1]			;_V*iZ
       }
       {
	add	#MPR_RecipLUT - 128*sizeofscalar,v3[2]
	mul	v3[3],v1[1],>>v2[3],v1[1] 	;_V
	mv_s	_iZ,v3[3]			;_iZ value
       }
       {
	mvr	v1[0],ru			;Set ru
	add	_DU,_U				;Next _U
	ld_w	(v3[2]),v3[2]			;Fetch RecipLut value
	mul	#1,_Z,>>acshift,v1[3]		;Insert _Z
       }
       {
	mvr	v1[1],rv			;Set rv
	dec	rc0				;Decrement Loop Counter
	add	_DiZ,_iZ			;Next _iZ
       }
       {
	ld_p	(uv),v1				;Read Pixel
	add	_DV,_V				;Next _V
	mul	v3[2],v3[3],>>v3[1],v3[3]	;z*RecipLut value
       }
       {
	bra	c0ne,`loop			;Loop
	add	#iprec-(preciz+precuviz),v3[1],v2[3]	;Resulting fracbits
       }
       {
	rts					;Done
	subm	v3[3],v0[3],v3[3]		;2 - z*RecipLut value
	add	_DZ,_Z			;Next _Z
	mv_s	#0,r0			;No Transparent Pixels
       }
       {
	st_pz	v1,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	mul	v3[2],v3[3],>>#iprec,v3[3]	;RecipLut(2 - z*RecipLut)
	msb	_iZ,v3[1]			;msb _iZ
       }
       ;----------------------------------------;bra c0ne,`loop
       {
	mv_s	#0,r1			;Clear Translucency Flag
	sub	_DiZ,_iZ		;Re-Step _iZ
       }
       ;----------------------------------------;rts

