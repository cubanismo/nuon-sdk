/*
 * Title	INNER263.S
 * Description	MPR Inner Loop 263
 * Version	1.0
 * Start Date	11/15/98
 * Last Update	11/15/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn263
	.origin		mprinnerbase

	.export _inn263_start, _inn263_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	1	CLUT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	1	Black Transparent
	;* 7	0	Color Off
	;* 8    0       No Alpha
	;* 9    1	Additive Shade On

	;* Setup	3+9+5 cycles
	;* Per Pixel	4+4+3 cycles
	;* Exit		3 cycles
MPR_inn263:
;* Transparent Pixel Detection
       {
	sub_sv	v1,v1				;Clear v1
	mv_s	#0xFFFF0000,_WIDXTOT		;#of Transparent Pixel -1
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
       }
       ;----------------------------------------;EndTransparentDetect
;* End of Transparent Pixel Detection

	ld_p	(uv),v0			;Read Pixel
       {
	ld_s	(rc0),v0[3]		;Backup Inner Loop Counter
	addr	_DU,ru			;Next U
       }
	lsr	#1,r0			;16 Bit Clut

`loop:
       {
	ld_p	(r0),v1			;Read source pixel
	addr	_DV,rv			;Add Delta V
	dec	rc0			;Decrement Loop Counter
       }
       {
	bra	c0ne,`loop              ;Loop
	ld_p	(uv),v0			;Read clut lookup
	sub	_DU,#0,v2[2]		;v2[2] -_DU
       }
       {
	copy	_Z,v1[3]		;Insert Z
	addm	_DZ,_Z			;Next Z
	addr	_DU,ru			;Add Delta U
       }
       {
	st_pz	v1,(xy)			;Store destination pixel
	addr	#1<<16,rx		;Next Pixel
	lsr	#1,r0			;16 Bit Clut
       }
       ;--------------------------------;bra c0ne,`loop

;*Additive Shading Based on Alpha
;* Note: CHNORM is on in GRB mode, since:
;*  a(R1-128) + (1-a)(R2-128) = aR1 + (1-a)R2 - 128

       {
	addr	v2[2],ru 		;Re-Step ru
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
	sub	_A,v2[3],v3[3]		;1-Alpha
       }
       {
	st_s	v0[3],rc0		;Restore Inner Loop Counter
	mul_p	_A,v3,>>#30,v2		;Alpha*ExtraColor
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
	ld_s	(MPR_TransPix),r0	;Return #of Transparent Pixels
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

