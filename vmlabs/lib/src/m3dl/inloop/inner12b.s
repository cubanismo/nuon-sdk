/*
 * Title	INNER12B.S
 * Description	MPR Inner Loop 12B
 * Version	1.0
 * Start Date	12/30/98
 * Last Update	12/30/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn12B
	.origin		mprinnerbase

	.export _inn12B_start, _inn12B_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	CLUT
	;* 2	1	GRB Screen
	;* 3	1	Perspective Correct
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    1       Alpha On

	;* Setup	12 cycles
	;* Per Pixel	10 cycles
	;* Exit		2 cycles

MPR_inn12B:
       {
	msb	_iZ,v3[1]			;msb _iZ
	subm	_DZ,_Z				;Re-Step _Z
       }
	sub	#indexbits+1+1,v3[1],v3[2]	;Indexshift
	as	v3[2],_iZ,v3[2]			;Indexoffset
	add	#MPR_RecipLUT - 128*sizeofscalar,v3[2]
       {
	ld_w	(v3[2]),v3[2]			;Fetch RecipLut value
       }
       {
	copy	_iZ,v3[3]			;_iZ value
	addm	_DiZ,_iZ			;Next _iZ
       }
       {
	mv_s	#fix(2,iprec),v0[3]	;v0[3] #fix(2,iprec)
	mul	v3[2],v3[3],>>v3[1],v3[3]	;z*RecipLut value
       }
       {
	add	#iprec-(preciz+precuviz),v3[1],v2[3]	;Resulting fracbits
       }
       {
	sub	v3[3],v0[3],v3[3]		;2 - z*RecipLut value
       }
       {
	mul	v3[2],v3[3],>>#iprec,v3[3]	;RecipLut(2 - z*RecipLut)
	msb	_iZ,v3[1]			;msb _iZ
       }
       {
	sub	#indexbits+1+1,v3[1],v3[2]	;Indexshift
	mv_s	_U,v0[0]			;_U*iZ
       }
       {
	as	v3[2],_iZ,v3[2]			;Indexoffset
	mul	v3[3],v0[0],>>v2[3],v0[0]	;_U
	mv_s	_V,v0[1]			;_V*iZ
       }

`loop:
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
	add	_DiZ,_iZ 			;Next _iZ
	addm	_DZ,_Z 				;Next _Z
       }
       {
	ld_p	(uv),v1				;Read Pixel
	add	_DV,_V				;Next _V
	mul	v3[2],v3[3],>>v3[1],v3[3]	;z*RecipLut value
       }
       {
	add	#iprec-(preciz+precuviz),v3[1],v2[3]	;Resulting fracbits
       }
       {
	lsr	#1,v1[0]			;16Bit Clut
	subm	v3[3],v0[3],v3[3]		;2 - z*RecipLut value
	mv_s	_U,v0[0]			;_U*iZ
       }
       {
	ld_p	(v1[0]),v1 			;Read Pixel
	mul	v3[2],v3[3],>>#iprec,v3[3]	;RecipLut(2 - z*RecipLut)
	msb	_iZ,v3[1]			;msb _iZ
       }
       {
	bra	c0ne,`loop			;Loop
	sub	#indexbits+1+1,v3[1],v3[2]	;Indexshift
	mul	#1,_Z,>>acshift,v1[3]		;Insert Depth Z
       }
       {
	mul	v3[3],v0[0],>>v2[3],v0[0]	;_U
	mv_s	_V,v0[1]			;_V*iZ
       }
       {
	rts					;Done
	st_pz	v1,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	as	v3[2],_iZ,v3[2]			;Indexoffset
       }
       ;----------------------------------------;bra c0ne,`loop
       {
	mv_s	#0,r0			;No Transparent Pixels
	add	_DZ,_Z			;Next _Z
       }
       {
	mv_s	#1,r1			;Set Translucency Flag
	sub	_DiZ,_iZ		;Re-Step _Z
       }
       ;--------------------------------;rts

