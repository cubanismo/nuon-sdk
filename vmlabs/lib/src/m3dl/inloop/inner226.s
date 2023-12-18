/*
 * Title	INNER226.S
 * Description	MPR Inner Loop 226
 * Version	1.0
 * Start Date	11/14/98
 * Last Update	11/14/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn226
	.origin		mprinnerbase

	.export _inn226_start, _inn226_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	CLUT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    1       Alpha On
	;* 9    1	Additive Shade On

	;* Setup	3+5 cycles
	;* Per Pixel	4+3 cycles
	;* Exit		3 cycles
MPR_inn226:
       {
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	sub_sv	v3,v3			;Clear v3
       }
       {
	ld_s	(rc0),v0[3]		;Backup rc0
	bset	#29,v3[1]		;1/2 in 2.30 format
	subm	_DU,v3[3]		;-_DU
       }
       {
	lsr	#1,r0			;16 Bit Clut
       }

`loop:
       {
	dec	rc0			;Decrement Loop Counter
	ld_p	(r0),v1			;Read source pixel
	addr	_DV,rv			;Add Delta V
	bset	#29,v3[2]		;1/2 in 2.30 format
       }
       {
	bra	c0ne,`loop              ;Loop
	ld_p	(uv),v0			;Read clut lookup
	addr	_DU,ru			;Add Delta U
	copy	_Z,v2[3]		;Insert Z
       }
       {
	sub_p	v3,v1,v2		;CHNORM
	addm	_DZ,_Z			;Next Z
       }
       {
	st_pz	v2,(xy)			;Store destination pixel
	addr	#1<<16,rx		;Next Pixel
	lsr	#1,r0			;16 Bit Clut
       }
       ;--------------------------------;bra c0ne,`loop

;*Additive Shading Based on Alpha
;* Note: CHNORM is on in GRB mode, since:
;*  a(R1-128) + (1-a)(R2-128) = aR1 + (1-a)R2 - 128

       {
	addr	v3[3],ru 		;Re-Step ru
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

