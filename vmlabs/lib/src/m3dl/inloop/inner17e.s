/*
 * Title	INNER17E.S
 * Description	MPR Inner Loop 17E
 * Version	1.0
 * Start Date	12/31/98
 * Last Update	12/31/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn17E
	.origin		mprinnerbase

	.export _inn17E_start, _inn17E_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	Clut
	;* 2	1	GRB Screen
	;* 3	1	Perspective Correct
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    1       Alpha On

	;* Setup	17 cycles
	;* Per Pixel	17 cycles
	;* Exit		2 cycles

MPR_inn17E:
       {
	msb	_iZ,v1[3]			;msb (_iZ)
	st_s	_GRBA[3],(MPR_AlphaBackup)	;Backup Alpha
       }
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
       }
       {
	ld_p	(uv),_DGRBA			;Fetch Primary Texel
	addr	#0xFFFF8000,ru			;ru -0.5
       }
	addr	#0xFFFF8000,rv			;ru -0.5

`loop:
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru			;ru+1
	add	#iprec-(preciz+precuviz),v1[3],_DA 	;Resulting Fracbits
	addm	_DU,_U				;Next _U
       }
       {
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv			;rv+1
	addm	_DV,_V				;Next _V
	add	_DiZ,_iZ			;Next _iZ
       }
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
	ftst	#0x7FF,_DG 			;Transparent Pixel ?
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
	bra	ne,`NoTransparent		;No Transparent Pixel (add_p does not modify cc)
	sub_p	v1,v2				;Pixel2-(Pixel0+ru(Pixel1-Pixel0))
	mul	_V,v2[3],>>_DA,v2[3]		;_V
       }
       {
	add_p	v3,v2				;Pixel2+ru(Pixel3-Pixel2)-(Pixel0+(ru(Pixel1-Pixel0))
	mvr	_A,ru				;Set ru
	dec	rc0				;Decrement Loop Counter
	mul	v3[3],_iZ,>>acshift,_A		;z*RecipLut value
	mv_s	#1<<29,_DB			;CHNORM value
       }
       {
	mul_p	rv,v2,>>#30,v2			;rv*()
	sub	_DB,v1[1]			;CHNORM Red
	mvr	v2[3],rv			;Set rv
	mv_s   	_Z,v2[3]			;Insert _Z
       }
       ;----------------------------------------;bra eq,`NoTransparent
	mv_s	#0,v2[3]			;Transparent Pixel
`NoTransparent:
       {
	bra	c0ne,`loop			;Loop
	ld_p	(uv),_DGRBA			;Read Primary Texel
	addr	#0xFFFF8000,ru			;ru -0.5
	sub	_DB,v1[2]			;CHNORM Blue
       }
       {
	add_p	v1,v2				;Final Blended Pixel
	addr	#0xFFFF8000,rv			;ru -0.5
	addm	_DZ,_Z	 			;Next _Z
       }
       {
	st_pz	v2,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	rts					;Done
       }
       ;----------------------------------------;bra c0ne,`loop
       {
	ld_s	(MPR_AlphaBackup),_GRBA[3]	;Restore Alpha
	subm	r0,r0			;No Transparent Pixels
	sub	_DiZ,_iZ		;Re-Step _iZ
       }
       {
	add	#1,r0,r1			;Set Translucency Flag
	st_s	#0,(acshift)		;Restore acshift
       }
       ;----------------------------------------;rts

