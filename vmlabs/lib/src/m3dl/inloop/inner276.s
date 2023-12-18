/*
 * Title	INNER276.S
 * Description	MPR Inner Loop 276
 * Version	1.0
 * Start Date	11/09/98
 * Last Update	11/09/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn276
	.origin		mprinnerbase

	.export _inn276_start, _inn276_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	CLUT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	1	Black Transparent
	;* 7	0	Color Off
	;* 8    0       No Alpha
	;* 9    1	Additive Shade On

	;* Setup	12+9+8 cycles
	;* Per Pixel	10+4+3 cycles
	;* Exit		3 cycles
MPR_inn276:
;* Transparent Pixel Detection
       {
	sub_sv	v1,v1				;Clear v1
	mv_s	#0xFFFF0000,_WIDXTOT		;#of Transparent Pixel -1
	subm	_DZ,_Z				;Re-Step Z
       }

       ;Pre-Read 1st Pixel
       {
	bra	`TransLoop
	ld_p	(uv),v0				;Read source pixel
	addr	_DU,ru				;Next ru
	bset	#16,v1[0]			;v1[0] One in 16.16
       }
       {
	addr	_DV,rv				;Next rv
	addm	_DU,_DU,v2[0]			;v2[0] 2*_DU
	sub_sv	_DGRBA,_GRBA			;Re-Step GRB and Alpha
       }
       {
	bits	#11-1,>>#0,v0[0]		;Isolate Clut Entry
	subm	_WIDXCUR,_WIDXCUR		;Initially Assume Nothing
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
	addr	v2[3],rv			;Re-Step rv
	mv_s	_WIDXTOT,r0			;r0 #of Transparent Pixels
	sub	r1,r1				;Clear Translucency Flag
       }

`TransLoop:
       {
	bra	c0eq,`AllTrans			;Done (nothing to render)
	ld_p	(uv),v0				;Read source pixel
	cmp	#0,v0[0]			;Transparent Pixel ?
       }
       {
	bra	eq,`TransLoop			;Nope, loop
	addr	_DU,ru				;Next ru
	add_sv	_DGRBA,_GRBA			;Update GRBA
	addm	_DZ,_Z				;Update Z
       }
       {
	addm	v1[0],_WIDXTOT			;Next Transparent Pixel
	bits	#11-1,>>#0,v0[0]		;Isolate Clut Entry
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
	cmp	#0,v0[0]			;Transparent Pixel ?
       }
       {
	bra	ne,`OpaqueLoop			;Nope, loop
	addr	_DU,ru				;Next ru
       }
       {
	addr	_DV,rv				;Next rv
	dec	rc0				;Decrement Loop Counter
       }
       {
	bits	#11-1,>>#0,v0[0]		;Isolate Clut Entry
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
	st_s	_WIDXCUR,(rc0)			;Set Inner loop Counter
	sub	#1,>>#-15,v1[3]			;v1[3] -0.5 in 16.16
       }
       ;----------------------------------------;EndTransparentDetect
;* End of Transparent Pixel Detection

       {
	mv_s	#1<<30,_DGRBA[3] 	;_DGRBA[3] = One in 2.30
	addr	v1[3],ru		;ru - 0.5
       }
       {
	st_s	_GRBA[3],(MPR_AlphaBackup)	;Backup Alpha Value
	sub	_DZ,_Z,v0[3]		;Pre-Step _Z
	addr	v1[3],rv		;rv - 0.5
       }
       {
	ld_p	(uv),v0			;Read Pixel0 lut entry
	addr	#1<<16,ru		;ru+1
	lsr	#1,_DGRBA[3],v2[3]	;0.5 in 2.30
       }
       {
	ld_p	(uv),_UVZ               ;Read Pixel1 lut entry
	addr	#1<<16,rv               ;rv+1
	mul	#1,_DGRBA[3],>>acshift,v1[3]	;oldru One in 2.30
       }
       {
	ld_p	(uv),v3                 ;Read Pixel2 lut entry
	addr	#-1<<16,ru              ;ru-1
	mul	#1,v0[0],>>#1,v0[0]	;Clut Entry
       }
       {
	ld_p	(uv),v2                 ;Read Pixel3 lut entry
	addr	#-1<<16,rv              ;rv-1
	lsr	#1,_UVZ[0],_GRBA[3]	;Clut Entry
       }
       {
	ld_p	(v0[0]),v0		;Read Pixel0
	mul	#1,v3[0],>>#1,v3[0]	;Clut Entry
	sub	_DZ,_Z,v0[3]		;Pre-Step _Z
       }
       {
	ld_p	(_GRBA[3]),v1		;Read Pixel1
	mul	#1,v2[0],>>#1,v2[0]	;Clut Entry
	addr	#-1<<16,rx		;Pre-Step pixel
       }
       {
	ld_p	(v3[0]),v3		;Read Pixel2
       }
       {
	ld_p	(v2[0]),v2		;Read Pixel3
	sub_p	v0,v1			;
       }
       {
	mul_sv	ru,v1,>>#30,v1		;ru*v1
	addr	_DU,ru 			;Next ru
       }
       {
	sub_p	v2,v3			;
	mul_sv	rv,_DGRBA,>>#30,_UVZ	;Set oldrv
	addr	_DV,rv 			;Next rv
       }

`loop:
       {
	ld_p	(uv),v0			;Read Pixel0 lut entry
	addr	#1<<16,ru		;ru+1
	dec	rc0			;Decrement Loop Counter
	add_p	v0,v1			;
	mul_p	v1[3],v3,>>#30,v3	;oldru*v3
       }
       {
	ld_p	(uv),_UVZ               ;Read Pixel1 lut entry
	addr	#1<<16,rv               ;rv+1
	sub_p	v1,v2			;
	mul	#1,_DGRBA[3],>>acshift,v1[3]	;oldru One in 2.30
       }
       {
	ld_p	(uv),v3                 ;Read Pixel2 lut entry
	addr	#-1<<16,ru              ;ru-1
	add_p	v3,v2			;
	mul	#1,v0[0],>>#1,v0[0]	;Clut Entry
       }
       {
	ld_p	(uv),v2                 ;Read Pixel3 lut entry
	addr	#-1<<16,rv              ;rv-1
	lsr	#1,_UVZ[0],_GRBA[3]	;Clut Entry
	mul_p	_UVZ[3],v2,>>#30,_UVZ	;oldrv*v2
       }
       {
	ld_p	(v0[0]),v0		;Read Pixel0
	add	_DZ,v0[3]		;Next Z
	mul	#1,v3[0],>>#1,v3[0]	;Clut Entry
       }
       {
	add_p	v1,_UVZ			;
	ld_p	(_GRBA[3]),v1		;Read Pixel1
	mul	#1,v2[0],>>#1,v2[0]	;Clut Entry
       }
       {
	ld_p	(v3[0]),v3		;Read Pixel2
	addr	#1<<16,rx		;Next pixel
	sub	v2[3],_UVZ[1]		;CHNORM Red
       }
       {
	bra	c0ne,`loop		;Loop
	ld_p	(v2[0]),v2		;Read Pixel3
	sub_p	v0,v1			;
	mul	#1,v0[3],>>acshift,_UVZ[3]	;Insert Z
       }
       {
	mul_sv	ru,v1,>>#30,v1		;ru*v1
	addr	_DU,ru			;Next ru
	sub	v2[3],_UVZ[2]		;CHNORM Blue
       }
       {
	st_pz	_UVZ,(xy)		;Store destination pixel
	sub_p	v2,v3			;
	mul_sv	rv,_DGRBA,>>#30,_UVZ	;Set oldrv
	addr	_DV,rv 			;Next rv
       }
       ;--------------------------------;bra c0ne,`loop

       {
	ld_s	(MPR_AlphaBackup),_GRBA[3]	;Restore Alpha
	sub	_DU,#0x8000,v2[3]	;0.5 - DU
       }
       {
	ld_sv	(MPR_DGRBA),_DGRBA	;Restore _DGRBA
	addr	v2[3],ru		;Re-Step ru
	sub	_DV,#0x8000,v3[3]	;0.5 - DV
       }
       {
	add	_DZ,v0[3],_Z 		;Step Z
	ld_s	(MPR_WXCLXHYCTY),v0[3]	;Inner Loop Counter
	addr	v3[3],rv		;Re-Step rv
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
       {
	rts				;Finished
	st_s	#PIX_16B<<20,(linpixctl);Restore linpixctl 16Bit GRB
       }
	ld_s	(MPR_TransPix),r0	;Return #of Transparent Pixels
	sub	r1,r1  			;Clear Translucency Flag
       ;--------------------------------;rts

