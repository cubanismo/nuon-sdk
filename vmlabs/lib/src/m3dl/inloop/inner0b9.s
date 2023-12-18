/*
 * Title	INNER0B9.S
 * Description	MPR Inner Loop 0B9
 * Version	1.0
 * Start Date	12/31/98
 * Last Update	01/05/99
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn0B9
	.origin		mprinnerbase

	.export _inn0B9_start, _inn0B9_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	1	GRB Screen
	;* 3	1	Perspective Correct
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7   	1	Color On
	;* 8    0       No Alpha

	;* Setup	16 cycles
	;* Per Pixel	14 cycles
	;* Exit		2 cycles


MPR_inn0B9:
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
	add	#iprec-(preciz+precuviz),_DA	;Resulting fracbits
       }
       {
	sub	v3[3],#fix(2,iprec),v3[3] 	;2 - z*RecipLut value
       }
       {
	mul	_A,v3[3],>>#iprec,v3[3]	;RecipLut(2 - z*RecipLut)
	mvr	#0xFFFF8000,ru			;ru -0.5
       }
       {
	mv_s	_U,v0[0]			;_U*iZ
	mvr	#0xFFFF8000,rv			;rv -0.5
       }
       {
	mv_s	_V,v0[1]			;_V*iZ
	mul	v3[3],v0[0],>>_DA,v0[0]		;_U
       }
       {
	mul	v3[3],v0[1],>>_DA,v0[1] 	;_V
	as	v0[3],_iZ,v0[3]			;Indexoffset
	mv_s	v1[3],_DA			;msb _iZ
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
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
	msb	_iZ,v2[3]			;msb _iZ
	addm	_DU,_U				;Next _U
       }

`loop:
       {
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv			;rv+1
	sub	#indexbits+1+1,v2[3],v0[3]	;Indexshift
	addm	_DV,_V				;Next _V
       }
       {
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru			;ru-1
	mul	_A,v3[3],>>_DA,v3[3]		;z*RecipLut value
	add	#iprec-(preciz+precuviz),_DA	;Resulting fracbits
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
	mul	v3[3],v0[0],>>_DA,v0[0]		;_U
       }
       {
	add_p	v2,v3				;Pixel2+ru(Pixel3-Pixel2)-(Pixel0+(ru(Pixel1-Pixel0))
	mul	v3[3],v0[1],>>_DA,v0[1]   	;_V
	mv_s	v2[3],_DA			;msb _iZ
       }
       {
	mul_p	rv,v3,>>#30,v3			;rv*()
	mvr	#0xFFFF8000,rv			;rv -0.5
	as	v0[3],_iZ,v0[3]			;Indexoffset
	mv_s   	_Z,v1[3]			;Insert _Z
       }
       {
	dec	rc0				;Decrement Loop Counter
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]
	mv_s	_iZ,v3[3]			;_iZ value
	addr	v0[0],ru			;Set ru
       }
       {
	add_p	v3,v1				;Final Blended Pixel
	addm	_DZ,_Z				;Next _Z
	addr	v0[1],rv			;Set rv
       }
       {
	bra	c0ne,`loop			;Loop
	ld_w	(v0[3]),_A  			;Fetch RecipLut value
	mul_p	_GRBA,v1,>>#30,v1		;RGB Multiply
	add	_DiZ,_iZ			;Next _iZ
       }
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
	msb	_iZ,v2[3]			;msb _iZ
       }
       {
	rts					;Done
	st_pz	v1,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	add_p	_DGRBA,_GRBA			;Next _GRBA
	addm	_DU,_U				;Next _U
       }
       ;----------------------------------------;bra c0ne,`loop
       {
	sub	_DiZ,>>#-1,_iZ		;Re-Step _iZ
	mv_s	#0,r1			;Clear Translucency Flag
       }
       {
	mv_s	#0,r0			;No Transparent Pixels
	subm	_DU,_U				;Re-Step _U
       }
       ;----------------------------------------;rts

