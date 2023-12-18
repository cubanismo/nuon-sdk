/*
 * Title	INNER224.S
 * Description	MPR Inner Loop 224
 * Version	1.0
 * Start Date	11/15/98
 * Last Update	11/15/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn224
	.origin		mprinnerbase

	.export _inn224_start, _inn224_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha
	;* 9    1	Additive Shade On

	;* Setup	4+6 cycles
	;* Per Pixel	3+3 cycles
	;* Exit		3 cycles
MPR_inn224:
	ld_s	(rc0),v0[3]		;Backup Inner Loop Counter
       {
	ld_p	(uv),v1			;Read Pixel
	addr	_DU,ru			;Next U
	sub_sv	v2,v2			;Clear v2
       }
       {
	addr	_DV,rv			;Next V
	dec	rc0			;Decrease Loop Counter
	bset	#29,v2[1]		;1/2 in 2.30 format
       }
       {
	mv_s	v2[1],v2[2]		;1/2 in 2.30 format
	sub	v2[1],v1[1]		;CHNORM
	subm	v2[1],v1[2]		;CHNORM
       }
`loop:
       {
	bra	c0ne,`loop		;Loop
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	copy	_Z,v1[3]		;Insert Z Value
       }
       {
	st_pz	v1,(xy)			;Store New Pixel
	addr	#1<<16,rx		;Next Pixel
	dec	rc0			;Decrease Loop Counter
	addm	_DZ,_Z			;Next Z
	sub	_DU,#0,v2[3]		;v2[3] -_DU
       }
       {
	addr	_DV,rv 			;Next V
	sub_p	v2,v0,v1		;CHNORM
       }
       ;--------------------------------;bra c0ne,`loop

       {
	addr	v2[3],ru 		;Re-Step ru
	sub	_DV,#0,v2[2]		;v2[2] -_DV
       }

;*Additive Shading Based on Alpha
;* Note: CHNORM is on in GRB mode, since:
;*  a(R1-128) + (1-a)(R2-128) = aR1 + (1-a)R2 - 128

       {
	addr	v2[2],rv  		;Re-Step rv
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
       {
	rts				;Finished
	st_s	#PIX_16B<<20,(linpixctl);Restore linpixctl 16Bit GRB
       }
	sub	r0,r0			;No Transparent Pixels
	sub	r1,r1  			;Clear Translucency Flag
       ;--------------------------------;rts

