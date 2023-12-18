/*
 * Title	INNER039.S
 * Description	MPR Inner Loop 039
 * Version	1.0
 * Start Date	12/31/98
 * Last Update	12/31/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn039
	.origin		mprinnerbase

	.export _inn039_start, _inn039_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	0	DIRECT
	;* 2	0	YCC Screen
	;* 3	1	Perspective Correct
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	15 cycles
	;* Per Pixel	14 cycles
	;* Exit		2 cycles

MPR_inn039:
       {
	mv_s	_iZ,v3[3]			;_iZ value
	msb	_iZ,v1[3]			;msb _iZ
       }
       {
	sub	#indexbits+1+1,v1[3],v0[3]	;Indexshift
       }
       {
	as	v0[3],_iZ,v0[3]			;Indexoffset
	addm	_DiZ,_iZ			;Next _iZ
       }
       {
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]
	mv_s	v1[3],_DA			;msb _iZ
       }
       {
	ld_w	(v0[3]),_A  			;Fetch RecipLut value
	msb	_iZ,v1[3]			;msb _iZ
       }
       {
	sub	#indexbits+1+1,v1[3],v0[3]	;Indexshift
       }
       {
	mul	_A,v3[3],>>_DA,v3[3]		;z*RecipLut value
       }
       {
	add	#iprec-(preciz+precuviz),_DA,v2[3]	;Resulting fracbits
       }
       {
	sub	v3[3],#fix(2,iprec),v3[3] 	;2 - z*RecipLut value
       }
       {
	mul	_A,v3[3],>>#iprec,v3[3]	;RecipLut(2 - z*RecipLut)
	mv_s	v1[3],_DA			;msb _iZ
       }
       {
	mv_s	_U,v0[0]			;_U*iZ
	mvr	#0xFFFF8000,ru			;ru -0.5
       }
       {
	mv_s	_V,v0[1]			;_V*iZ
	mul	v3[3],v0[0],>>v2[3],v0[0]	;_U
	mvr	#0xFFFF8000,rv			;rv -0.5
       }
       {
	mul	v3[3],v0[1],>>v2[3],v0[1] 	;_V
	as	v0[3],_iZ,v0[3]			;Indexoffset
       }
       {
	addr	v0[0],ru			;Set ru
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]
	mv_s	_iZ,v3[3]			;_iZ value
       }
       {
	addr	v0[1],rv			;Set rv
	ld_w	(v0[3]),_A  			;Fetch RecipLut value
	addm	_DiZ,_iZ			;Next _iZ
       }

`loop:
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
	msb	_iZ,v1[3]			;msb _iZ
	addm	_DU,_U				;Next _U
       }
       {
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv			;rv+1
	sub	#indexbits+1+1,v1[3],v0[3]	;Indexshift
	addm	_DV,_V				;Next _V
       }
       {
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru			;ru-1
	mul	_A,v3[3],>>_DA,v3[3]		;z*RecipLut value
	add	#iprec-(preciz+precuviz),_DA,v2[3]	;Resulting fracbits
       }
       {
	ld_p	(uv),v2				;Read Pixel2
	sub_p	v0,v1				;Pixel1-Pixel0
       }
       {
	mul_p	ru,v1,>>#30,v1			;ru*(Pixel1-Pixel0)
	sub	v3[3],#fix(2,iprec),v3[3] 	;2 - z*RecipLut value
       }
       {
	sub_p	v2,v3				;Pixel3-Pixel2
	mul	_A,v3[3],>>#iprec,v3[3]	;RecipLut(2 - z*RecipLut)
       }
       {
	mul_p	ru,v3,>>#30,v3			;ru*(Pixel3-Pixel2)
	add_p	v0,v1                           ;Pixel0+ru(Pixel1-Pixel0)
	mv_s	_U,v0[0]			;_U*iZ
	mvr	#0xFFFF8000,ru			;ru -0.5
       }
       {
	sub_p	v1,v2				;Pixel2-(Pixel0+ru(Pixel1-Pixel0))
	mv_s	_V,v0[1]			;_V*iZ
	mul	v3[3],v0[0],>>v2[3],v0[0]	;_U
       }
       {
	add_p	v2,v3				;Pixel2+ru(Pixel3-Pixel2)-(Pixel0+(ru(Pixel1-Pixel0))
	mul	v3[3],v0[1],>>v2[3],v0[1] 	;_V
	mv_s	v1[3],_DA			;msb _iZ
       }
       {
	mul_p	rv,v3,>>#30,v3			;rv*()
	as	v0[3],_iZ,v0[3]			;Indexoffset
       }
       {
	mvr	v0[1],rv			;Set rv
	dec	rc0				;Decrement Loop Counter
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]
	mv_s	_iZ,v3[3]			;_iZ value
       }
       {
	bra	c0ne,`loop			;Loop
	add_p	v3,v1				;Final Blended Pixel
	mv_s   	_Z,v1[3]			;Insert _Z
	addm	_DZ,_Z				;Next _Z
	addr	v0[0],ru			;ru - 0.5
       }
       {
	rts					;Done
	ld_w	(v0[3]),_A  			;Fetch RecipLut value
	addr	#0xFFFF8000,rv			;rv - 0.5
       }
       {
	st_pz	v1,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	add	_DiZ,_iZ			;Next _iZ
       }
       ;----------------------------------------;bra c0ne,`loop
       {
	sub	_DiZ,>>#-1,_iZ		;Re-Step _iZ
	subm	r0,r0			;No Transparent Pixels
	mv_s	#0,r1			;Clear Translucency Flag
       }
       ;----------------------------------------;rts

