/*
 * Title	INNER136.S
 * Description	MPR Inner Loop 136
 * Version	1.0
 * Start Date	11/09/98
 * Last Update	11/09/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn136
	.origin		mprinnerbase

	.export _inn136_start, _inn136_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	CLUT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	13 cycles
	;* Per Pixel	10 cycles
	;* Exit		3 cycles
MPR_inn136:
       {
	mv_s	#-0x8000,v1[3]		;v1[3] -0.5 in 16.16
       }
       {
	mv_s	#1<<30,_DGRBA[3] 	;_DGRBA[3] = One in 2.30
	addr	v1[3],ru		;ru - 0.5
       }
       {
	st_s	_GRBA[3],(MPR_AlphaBackup)	;Backup Alpha
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
	rts				;Done
	sub	_DU,#0x8000,v2[3]	;0.5 - DU
       }
       {
	addr	v2[3],ru		;Re-Step ru
	sub	_DV,#0x8000,v3[3]	;0.5 - DV
	subm	r0,r0			;No Transparent Pixels
       }
       {
	mv_s	#1,r1			;Set Translucency Flag
	add	_DZ,v0[3],_Z 		;Step Z
	addr	v3[3],rv		;Re-Step rv
       }
       ;--------------------------------;rts

