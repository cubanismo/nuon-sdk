/*
 * Title	INNER2A9.S
 * Description	MPR Inner Loop 2A9
 * Version	1.0
 * Start Date	12/30/98
 * Last Update	12/30/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn2A9
	.origin		mprinnerbase

	.export _inn2A9_start, _inn2A9_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	0	DIRECT
	;* 2	0	YCC Screen
	;* 3	1	Perspective Correct
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	1	Color On
	;* 8    0       Alpha Off
	;* 9    1       Additive Shade On

	;* Setup	11+6 cycles
	;* Per Pixel	10+3 cycles	;9 Definately Possible!
	;* Exit		3 cycles

MPR_inn2A9:
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
	nop
       }
       {
	st_pz	v1,(xy)				;Store New Pixel
	addr	#1<<16,rx			;Next Pixel
	add_p	_DGRBA,_GRBA			;Next _GRBA
	addm	_DZ,_Z				;Next _Z
       }
       ;----------------------------------------;bra c0ne,`loop

       {
	ld_s	(MPR_WXCLXHYCTY),v0[3]	;Inner Loop Counter
	sub	_DiZ,_iZ		;Re-Step _iZ
       }

;*Additive Shading Based on Alpha
;* Note: CHNORM is on in GRB mode, since:
;*  a(R1-128) + (1-a)(R2-128) = aR1 + (1-a)R2 - 128

       {
	st_s	#(1<<28)|(PIX_32B<<20),linpixctl	;32Bit YCrCb
	sub	v2[3],v2[3]		;Clear v2[3]
       }
       {
	ld_p	(MPR_ExtraColor),v3	;Read Extra color
	mvr	v2[3],rx 		;Back to 1st pixel
	bset	#30,v2[3]		;v2[3] One in 2.30
       }

	;Setup `AddShadeLoop
       {
	ld_pz	(xy),v1			;Read Pixel
	lsr	#16,v0[3]		;Discrete Length
       }
       {
	st_s	v0[3],rc0		;Restore Inner Loop Counter
	mul_p	_A,v3,>>#30,v2		;Alpha*ExtraColor
	sub	_A,v2[3],v3[3]		;1-Alpha
       }
       {
	mul_p	v3[3],v1,>>#30,v1	;(1-Alpha)*v1
	add	_DA,_A			;Update Alpha
	addr	#1<<16,rx		;Next Pixel
	dec	rc0			;Decrement Inner Loop Counter
       }

`AddShadeLoop:
       {
	bra	c0eq,`ShadeDone		;Finished
	dec	rc0			;Decrement Inner Loop Counter
	ld_pz	(xy),v0			;Read Pixel
	addr	#-1<<16,rx  		;Previous Pixel
	sub	_A,v2[3],v3[3]		;1-Alpha
       }
       {
	add_p	v2,v1			;Accumulate pixels
	mul_p	_A,v3,>>#30,v2		;Alpha*ExtraColor
       }
       {
	st_pz	v1,(xy)			;Store Destination Pixel
	addr	#2<<16,rx		;Next Pixel
	add	_DA,_A			;Update Alpha
	mul_p	v3[3],v0,>>#30,v0	;(1-Alpha)*v0
       }
       {
	bra	c0ne,`AddShadeLoop 	;Loop
	dec	rc0			;Decrement Inner Loop Counter
	ld_pz	(xy),v1			;Read Pixel
	addr	#-1<<16,rx 		;Previous Pixel
	sub	_A,v2[3],v3[3]		;1-Alpha
       }
       {
	add_p	v2,v0			;Accumulate pixels
	mul_p	_A,v3,>>#30,v2		;Alpha*ExtraColor
       }
       {
	st_pz	v0,(xy)			;Store Destination Pixel
	addr	#2<<16,rx		;Next Pixel
	add	_DA,_A			;Update Alpha
	mul_p	v3[3],v1,>>#30,v1	;(1-Alpha)*v1
       }
       ;--------------------------------;bra c0ne,`AddShadeLoop
`ShadeDone:
	ld_s	(xyctl),r2		;read xyctl
	sub	r0,r0			;No Transparent Pixels
       {
	rts				;Finished
	and	#1<<28,r2		;Isolate CHNORM
       }
	or	#(PIX_16B<<20),r2	;Insert 16Bit
       {
	st_s	r2,(linpixctl)		;Reset linpixctl
	sub	r1,r1  			;Clear Translucency Flag
       }
       ;--------------------------------;rts

