/*
 * Title	INNER0BE.S
 * Description	MPR Inner Loop 0BE
 * Version	1.0
 * Start Date	12/31/98
 * Last Update	12/31/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn0BE
	.origin		mprinnerbase

	.export _inn0BE_start, _inn0BE_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	Clut
	;* 2	1	GRB Screen
	;* 3	1	Perspective Correct
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	1	Color On
	;* 8    0       No Alpha

	;* Setup	18 cycles
	;* Per Pixel	17 cycles
	;* Exit		2 cycles

MPR_inn0BE:
	msb	_iZ,v1[3]			;msb (_iZ)
	sub	#indexbits+1+1,v1[3],v0[3]	;IndexShift
	as	v0[3],_iZ,v0[3]			;IndexOffset
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]	;Ptr RecipLut
	ld_w	(v0[3]),v3[3]			;Fetch RecipLut Value
       {
	st_s	v1[3],(acshift)			;Set shift
	add	#iprec-(preciz+precuviz),v1[3],_DA 	;Resulting Fracbits
       }
       {
	mul	v3[3],_iZ,>>acshift,_A		;z*RecipLut value
	add	_DiZ,_iZ			;Next _iZ
       }
       {
	msb	_iZ,v1[3]			;msb (_iZ)
	mvr	#0xFFFF8000,ru			;ru -0.5
       }
	sub	_A,#fix(2,iprec),_A		;2 - z*RecipLut value
       {
	mul	v3[3],_A,>>#iprec,_A		;z*RecipLut value
	sub	#indexbits+1+1,v1[3],v0[3]	;IndexShift
       }
       {
	as	v0[3],_iZ,v0[3]			;IndexOffset
	mvr	#0xFFFF8000,rv			;rv -0.5
       }
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
	addr	_A,ru				;Set ru
	add	_DU,_U				;Next _U
       }
       {
	mul	v3[3],_iZ,>>acshift,_A		;z*RecipLut value
	addr	v0[1],rv			;Set rv
	add	#iprec-(preciz+precuviz),v1[3],_DA 	;Resulting Fracbits
       }
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
	add	_DiZ,_iZ			;Next _iZ
       }
       {
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv			;rv+1
       }
       {
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru			;ru-1
	mul	#1,v0[0],>>#1,v0[0]		;16Bit Clut
	msb	_iZ,v1[3]			;msb (_iZ)
       }


`loop:
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
	add	_DV,_V				;Next _V
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
	sub_p	v1,v2				;Pixel2-(Pixel0+ru(Pixel1-Pixel0))
	mul	_V,v2[3],>>_DA,v2[3]		;_V
	mvr	#0xFFFF8000,ru			;ru -0.5
       }
       {
	mv_s	#1<<29,v0[3]			;CHNorm value
	add_p	v3,v2				;Pixel2+ru(Pixel3-Pixel2)-(Pixel0+(ru(Pixel1-Pixel0))
	addr	_A,ru				;Set ru
	dec	rc0				;Decrement Loop Counter
	mul	v3[3],_iZ,>>acshift,_A		;z*RecipLut value
       }
       {
	mul_p	rv,v2,>>#30,v2			;rv*()
	add	_DU,_U				;Next _U
	mvr	#0xFFFF8000,rv			;rv -0.5
       }
       {
	addr	v2[3],rv			;Set rv
	mv_s   	_Z,v2[3]			;Insert _Z
	add	#iprec-(preciz+precuviz),v1[3],_DA 	;Resulting Fracbits
       }
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
	add_p	v1,v2				;Final Blended Pixel
	addm	_DiZ,_iZ			;Next _iZ
       }
       {
	mul_p	_GRBA,v2,>>#30,v2		;GRB Multiply
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv			;rv+1
	msb	_iZ,v1[3]			;msb (_iZ)
       }
       {
	bra	c0ne,`loop			;Loop
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru			;ru-1
	lsr	#1,v0[0]			;16Bit Clut
       }
       {
	sub	v0[3],v2[1]			;CHNorm Red
	subm	v0[3],v2[2]			;CHNorm Blue
       }
       {
	rts					;Done
	st_pz	v2,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	add_p	_DGRBA,_GRBA			;Next _GRBA
	addm	_DZ,_Z	 			;Next _Z
       }
       ;----------------------------------------;bra c0ne,`loop
       {
	sub	r0,r0			;No Transparent Pixels
	st_s	#0,(acshift)		;Restore acshift
       }
       {
	mv_s	#0,r1			;Clear Translucency Flag
	sub	_DiZ,>>#-1,_iZ		;Re-Step _iZ
	subm	_DU,_U			;Re-Step _U
       }
       ;----------------------------------------;rts

