/*
 * Title	INNER2A3.S
 * Description	MPR Inner Loop 2A3
 * Version	1.0
 * Start Date	11/15/98
 * Last Update	11/15/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn2A3
	.origin		mprinnerbase

	.export _inn2A3_start, _inn2A3_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	1	CLUT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	1	Color On
	;* 8    0       No Alpha
	;* 9    1	Additive Shade On

	;* Setup	6+6 cycles
	;* Per Pixel	4+3 cycles
	;* Exit		3 cycles
MPR_inn2A3:
       {
	ld_p	(uv),v1			;Read Pixel
	addr	_DU,ru			;Next U
       }
       {
	addr	_DV,rv			;Add Delta V
       }
       {
	lsr	#1,r4			;16 Bit Clut
       }
       {
	ld_p	(r4),v1			;Read source pixel
	sub	_DU,#0,v0[3]		;v0[3] -_DU
       }
       {
	ld_p	(uv),v0			;Read clut lookup
	sub	_DV,#0,v1[3]		;v1[3] -_DV
       }
	mul_p	_GRBA,v1,>>#30,v2	;GRB Multiply

`loop:
       {
	addr	_DU,ru			;Add Delta U
	dec	rc0			;Decrement Loop Counter
	mv_s	_Z,v2[3]		;Insert Z
	lsr	#1,r0			;16 Bit Clut
       }
       {
	bra	c0ne,`loop              ;Loop
	ld_p	(r0),v1			;Read source pixel
	addr	_DV,rv			;Add Delta V
       }
       {
	ld_p	(uv),v0			;Read clut lookup
	addm	_DZ,_Z			;Next Z
	add_p	_DGRBA,_GRBA		;Next GRBA
       }
       {
	st_pz	v2,(xy)			;Store destination pixel
	addr	#1<<16,rx		;Next Pixel
	mul_p	_GRBA,v1,>>#30,v2	;GRB Multiply
       }
       ;--------------------------------;bra c0ne,`loop

       {
	addr	v0[3],ru		;Re-Step ru
	ld_s	(MPR_WXCLXHYCTY),v0[3]	;Inner Loop Width
       }

;*Additive Shading Based on Alpha
;* Note: CHNORM is on in GRB mode, since:
;*  a(R1-128) + (1-a)(R2-128) = aR1 + (1-a)R2 - 128

       {
	addr	v1[3],rv 		;Re-Step rv
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


