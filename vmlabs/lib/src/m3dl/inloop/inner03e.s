/*
 * Title	INNER03E.S
 * Description	MPR Inner Loop 03E
 * Version	1.0
 * Start Date	12/31/98
 * Last Update	12/31/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn03E
	.origin		mprinnerbase

	.export _inn03E_start, _inn03E_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	Clut
	;* 2	1	GRB Screen
	;* 3	1	Perspective Correct
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	17 cycles
	;* Per Pixel	16 cycles (it used to be 15...)
	;* Exit		2 cycles

MPR_inn03E:
	msb	_iZ,v1[3]			;msb (_iZ)
	sub	#indexbits+1+1,v1[3],v0[3]	;IndexShift
	as	v0[3],_iZ,v0[3]			;IndexOffset
	add	#MPR_RecipLUT - 128*sizeofscalar,v0[3]	;Ptr RecipLut
       {
	ld_w	(v0[3]),v3[3]			;Fetch RecipLut Value
	sub_p	_DGRBA,_DGRBA			;Clear _DGRBA
       }
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
	bset	#29,_DGRBA[1]			;CHNorm Red
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
	bset	#29,_DGRBA[2]			;CHNorm Blue
       }


`loop:
       {
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru			;ru-1
	mul	#1,v0[0],>>#1,v0[0]		;16Bit Clut
	msb	_iZ,v1[3]			;msb (_iZ)
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
       }
       {
	ld_p	(v2[0]),v2			;Read Pixel2
	sub_p	v0,v1				;Pixel1-Pixel0
	mul	v3[3],_A,>>#iprec,_A		;z*RecipLut value
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
	add_p	v3,v2				;Pixel2+ru(Pixel3-Pixel2)-(Pixel0+(ru(Pixel1-Pixel0))
	addr	_A,ru				;Set ru
	dec	rc0				;Decrement Loop Counter
	mul	v3[3],_iZ,>>acshift,_A		;z*RecipLut value
       }
       {
	mul_p	rv,v2,>>#30,v2			;rv*()
	sub_p	_DGRBA,v1			;CHNORM
	mvr	#0xFFFF8000,rv			;rv -0.5
       }
       {
	mv_s   	_Z,v2[3]			;Insert _Z
	addr	v2[3],rv			;Silly Instruction huh ?
       }
       {
	bra	c0ne,`loop			;Loop
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
	add	#iprec-(preciz+precuviz),v1[3],_DA 	;Resulting Fracbits
       }
       {
	add_p	v1,v2				;Final Blended Pixel
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv			;rv+1
	addm	_DU,_U				;Next _U
       }
       {
	rts					;Done
	st_pz	v2,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	add	_DiZ,_iZ			;Next _iZ
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

