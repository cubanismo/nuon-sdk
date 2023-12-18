/*
 * Title	INNER233.S
 * Description	MPR Inner Loop 233
 * Version	1.0
 * Start Date	11/15/98
 * Last Update	11/15/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn233
	.origin		mprinnerbase

	.export _inn233_start, _inn233_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	1	CLUT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha
 	;* 9    1	Additive Shade On

	;* Setup	13+8 cycles
	;* Per Pixel	10+3 cycles
	;* Exit		3 cycles
MPR_inn233:
       {
	mv_s	#-0x8000,v1[3]		;v1[3] -0.5 in 16.16
       }
       {
	mv_s	#1<<30,_DGRBA[3] 	;_DGRBA[3] = One as 2.30
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
	addr	#-1<<16,rx		;Pre-Step rx
       }
       {
	ld_p	(_GRBA[3]),v1		;Read Pixel1
	mul	#1,v2[0],>>#1,v2[0]	;Clut Entry
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
	addr	_DV,rv			;Next rv
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
       }
       {
	bra	c0ne,`loop		;Loop
	ld_p	(v2[0]),v2		;Read Pixel3
	sub_p	v0,v1			;
	mul	#1,v0[3],>>acshift,_UVZ[3]	;Insert Z
       }
       {
	mul_sv	ru,v1,>>#30,v1		;ru*v1
	addr	_DU,ru 			;Next ru
       }
       {
	st_pz	_UVZ,(xy)		;Store destination pixel
	sub_p	v2,v3			;
	mul_sv	rv,_DGRBA,>>#30,_UVZ	;Set oldrv
	addr	_DV,rv			;Next rv
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

