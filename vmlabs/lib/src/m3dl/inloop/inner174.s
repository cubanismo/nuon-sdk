/*
 * Title	INNER174.S
 * Description	MPR Inner Loop 174
 * Version	1.0
 * Start Date	11/08/98
 * Last Update	11/08/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn174
	.origin		mprinnerbase

	.export _inn174_start, _inn174_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	1	Black Transparent
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	11+9 cycles
	;* Per Pixel	8+4 cycles
	;* Exit		2 cycles
MPR_inn174:
;* Transparent Pixel Detection
       {
	sub_sv	v1,v1				;Clear v1
	mv_s	#0xFFFF0000,_WIDXTOT		;#of Transparent Pixel -1
       }
       {
	bset	#16,v1[0]                       ;v1[0] One in 16.16
	subm	_DZ,_Z				;Re-Step Z
       }

       ;Pre-Read 1st Pixel
       {
	ld_p	(uv),v0				;Read source pixel
	addr	_DU,ru				;Next ru
	mul	#2,_DU,>>acshift,v2[0]		;v2[0] 2*_DU
	copy	v1[0],v1[1]			;v1[1] One in 16.16
       }
       {
	bra	`TransLoop
	addr	_DV,rv				;Next rv
	copy	v1[0],v1[2]			;v1[2] One in 16.16
       }
       {
	dotp	v0,v1,>>#32,v0[3]  		;Check Color values
	sub_sv	_DGRBA,_GRBA			;Re-Step GRBA
       }
       {
	sub	_WIDXCUR,_WIDXCUR		;Initially Assume Nothing
       }
       ;----------------------------------------;bra eq,`transloop
`AllTrans:
       {
	mv_s	_DV,v2[3]			;_DV
	rts 					;Finished
	neg	v2[0]				;-2*_DU
       }
       {
	st_s	_WIDXCUR,(MPR_WXCLXHYCTY)	;Set Width Counter
	addr	v2[0],ru			;Re-Step ru
	neg	v2[3]				;-_DV
       }
       {
	mv_s	_WIDXTOT,r0			;r0 #of Transparent Pixels
	addr	v2[3],rv			;Re-Step rv
	sub	r1,r1				;Clear Translucency Flag
       }

`TransLoop:
       {
	bra	c0eq,`AllTrans			;Done (nothing to render)
	ld_p	(uv),v0				;Read source pixel
	cmp	#0,v0[3]			;Transparent Pixel ?
       }
       {
	bra	eq,`TransLoop			;Nope, loop
	addr	_DU,ru				;Next ru
	add_sv	_DGRBA,_GRBA			;Update GRBA
	addm	_DZ,_Z				;Update Z
       }
       {
	dotp	v0,v1,>>#32,v0[3]  		;Check Color values
	add	v1[0],_WIDXTOT			;Decrement TOT Width
       }
       {
	addr	_DV,rv				;Next rv
	dec	rc0				;Decrement Loop Counter
       }
       ;----------------------------------------;bra eq,`transloop
	ld_s	(ru),v2[2]			;Backup ru
	ld_s	(rv),v2[3]			;Backup rv
`OpaqueLoop:
       {
	bra	c0eq,`OpaqueDone		;Finished
	ld_p	(uv),v0				;Read source pixel
	addm	v1[0],_WIDXCUR			;Increment Current Width
	cmp	#0,v0[3]			;Transparent Pixel ?
       }
       {
	bra	ne,`OpaqueLoop			;Nope, loop
	addr	_DU,ru				;Next ru
       }
       {
	addr	_DV,rv				;Next rv
	dec	rc0				;Decrement Loop Counter
	dotp	v0,v1,>>#32,v0[3]  		;Check Color values
       }
       {
	nop					;Delay slot
       }
       ;----------------------------------------;bra eq,`transloop
`OpaqueDone:
       {
	st_s	_WIDXCUR,(MPR_WXCLXHYCTY)	;Set Width Counter
	mul	#1,_WIDXCUR,>>#16,_WIDXCUR	;Shift down
	sub	_DV,>>#-1,v2[3]			;Re-Step rv
       }
       {
	st_s	_WIDXTOT,(MPR_TransPix)		;Set #of Transparent Pixels
	mvr	v2[3],rv                        ;Set rv
	sub	v2[0],v2[2]			;Re-Step ru
       }
       {
	mvr	v2[2],ru			;Set ru
	mv_s	#-0x8000,v2[3]		;v1[3] -0.5 in 16.16
       }
       ;----------------------------------------;EndTransparentDetect
;* End of Transparent Pixel Detection
;* NOTE: st_s _WIDXCUR,(rc0) swapped with mv_s #-0x8000,v2[3] instruction
;* End of Transparent Pixel Detection
       {
	mv_s	#1<<29,v3[3]		;0.5 in 2.30
	addr	v2[3],ru		;ru - 0.5
	add	_DU,v2[3],v1[3]		;-0.5 + _DU
       }
       {
	st_s	_WIDXCUR,(rc0)			;Set Inner loop Counter
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
	ld_s	(MPR_TransPix),r0	;Return #of Transparent Pixels
	add	_DZ,_Z 			;Step Z
	addr	v1[3],ru		;Re-Step ru
       }
       {
	addr	v2[3],rv		;Re-Step rv
	or	#1,r1 			;Set Translucency Flag
       }
       ;--------------------------------;rts

