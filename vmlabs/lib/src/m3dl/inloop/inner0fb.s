/*
 * Title	INNER0FB.S
 * Description	MPR Inner Loop 0FB
 * Version	1.0
 * Start Date	12/31/98
 * Last Update	12/31/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn0FB
	.origin		mprinnerbase

	.export _inn0FB_start, _inn0FB_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	Clut
	;* 2	1	GRB Screen
	;* 3	1	Perspective Correct
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	1	Black Transparent
	;* 7	1	Color On
	;* 8    0       No Alpha

	;* Setup	20 cycles
	;* Per Pixel	18 cycles
	;* Exit		3 cycles

MPR_inn0FB:
	msb	_iZ,v1[3]			;msb (_iZ)
	sub	#indexbits+1+1,v1[3],v0[3]	;IndexShift
	as	v0[3],_iZ,v0[3]			;IndexOffset
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]	;Ptr RecipLut
       {
	ld_w	(v0[3]),v3[3]			;Fetch RecipLut Value
	sub_p	_DGRBA,_GRBA			;Re-Step _GRBA
       }
       {
	st_s	v1[3],(acshift)			;Set shift
	add	#iprec-(preciz+precuviz),v1[3],_DA 	;Resulting Fracbits
       }
       {
	mul	v3[3],_iZ,>>acshift,_A		;z*RecipLut value
	add	_DiZ,_iZ			;Next _iZ
       }
	msb	_iZ,v1[3]			;msb (_iZ)
	sub	_A,#fix(2,iprec),_A		;2 - z*RecipLut value
       {
	mul	v3[3],_A,>>#iprec,_A		;z*RecipLut value
	sub	#indexbits+1+1,v1[3],v0[3]	;IndexShift
       }
	as	v0[3],_iZ,v0[3]			;IndexOffset
       {
	mv_s	_A,v0[1]			;RecipValue
	mul	_U,_A,>>_DA,_A			;_U
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]	;Ptr RecipLut
       }
       {
	mul	_V,v0[1],>>_DA,v0[1]		;_V
	ld_w	(v0[3]),v3[3]			;Fetch RecipLut Value
       }
       {
	st_s	v1[3],(acshift)			;Set shift
	mvr	_A,ru				;Set ru
       }
       {
	mul	v3[3],_iZ,>>acshift,_A		;z*RecipLut value
	mvr	v0[1],rv			;Set rv
	add	#iprec-(preciz+precuviz),v1[3],_DA 	;Resulting Fracbits
       }
       {
	ld_p	(uv),_DGRBA			;Fetch Primary Texel
	addr	#0xFFFF8000,ru			;ru -0.5
	add	_DiZ,_iZ			;Next _iZ
       }
       {
	msb	_iZ,v1[3]			;msb (_iZ)
	addr	#0xFFFF8000,rv			;rv -0.5
       }
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
       }
       {
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv			;rv+1
       }
	lsr	#1,v0[0]			;16Bit Clut


`loop:
       {
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru			;ru-1
	add	_DU,_U				;Next _U
	addm	_DV,_V				;Next _V
       }
       {
	ld_p	(uv),v2				;Read Pixel2
	mul	#1,v1[0],>>#1,v1[0]		;16Bit Clut
	sub	_A,#fix(2,iprec),_A		;2 - z*RecipLut value
       }
       {
	ld_p	(v0[0]),v0			;Read Pixel0
	mul	#1,v3[0],>>#1,v3[0]		;16Bit Clut
	sub	#indexbits+1+1,v1[3],v0[3]	;IndexShift
       }
       {
	ld_p	(v1[0]),v1			;Read Pixel1
	mul	#1,v2[0],>>#1,v2[0]		;16Bit Clut
	as	v0[3],_iZ,v0[3]			;IndexOffset
       }
       {
	ld_p	(v3[0]),v3			;Read Pixel3
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]	;Ptr RecipLut
	mul	v3[3],_A,>>#iprec,_A		;z*RecipLut value
       }
       {
	ld_p	(v2[0]),v2			;Read Pixel2
	sub_p	v0,v1				;Pixel1-Pixel0
       }
       {
	st_s	v1[3],(acshift)			;Set shift
	mul_p	ru,v1,>>#30,v1			;ru*(Pixel1-Pixel0)
	and	#0x7FF,_DG			;Transparent Pixel ?
       }
       {
	mv_s	_A,v2[3]			;RecipValue
	sub_p	v2,v3				;Pixel3-Pixel2
	mul	_U,_A,>>_DA,_A			;_U
       }
       {
	ld_w	(v0[3]),v3[3]			;Fetch RecipLut Value
	mul_p	ru,v3,>>#30,v3			;ru*(Pixel3-Pixel2)
	add_p	v0,v1                           ;Pixel0+ru(Pixel1-Pixel0)
       }
       {
	bra	ne,`NoTransparent		;Nope, No Transparent Pixel
	sub_p	v1,v2				;Pixel2-(Pixel0+ru(Pixel1-Pixel0))
	mul	_V,v2[3],>>_DA,v2[3]		;_V
	ld_sv	(MPR_DGRBA),_DGRBA		;Read _DGRBA
       }
       {
	add_p	v3,v2				;Pixel2+ru(Pixel3-Pixel2)-(Pixel0+(ru(Pixel1-Pixel0))
	mvr	_A,ru				;Set ru
	dec	rc0				;Decrement Loop Counter
	mul	v3[3],_iZ,>>acshift,_A		;z*RecipLut value
       }
       {
	mul_p	rv,v2,>>#30,v2			;rv*()
	add_p	_DGRBA,_GRBA
	mvr	v2[3],rv			;Set rv
	mv_s   	_Z,v2[3]			;Insert _Z
       }
       ;----------------------------------------;bra ne,`NoTransparent
	mv_s	#0,v2[3]			;Transparent Pixel
`NoTransparent:
       {
	ld_p	(uv),_DGRBA			;Fetch Primary Texel
	add	#iprec-(preciz+precuviz),v1[3],_DA 	;Resulting Fracbits
	addr	#0xFFFF8000,ru			;ru -0.5
       }
       {
	addr	#0xFFFF8000,rv			;rv -0.5
	add_p	v1,v2				;Final Blended Pixel
       }
       {
	mul_p	_GRBA,v2,>>#30,v2		;GRB Multiply
	add	_DiZ,_iZ			;Next _iZ
       }
       {
	bra	c0ne,`loop			;Loop
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
	msb	_iZ,v1[3]			;msb (_iZ)
       }
       {
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv			;rv+1
       }
       {
	st_pz	v2,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	addm	_DZ,_Z	 			;Next _Z
	lsr	#1,v0[0]			;16Bit Clut
       }

       ;----------------------------------------;bra c0ne,`loop
       {
	rts					;Done
	ld_sv	(MPR_DGRBA),_DGRBA		;_DGRBA
	sub	r0,r0			;No Transparent Pixels
       }
       {
	st_s	#0,(acshift)		;Restore acshift
	sub	_DiZ,>>#-1,_iZ		;Re-Step _iZ
       }
       {
	add_p	_DGRBA,_GRBA
	mv_s	#0,r1			;Clear Translucency Flag
       }
       ;----------------------------------------;rts

