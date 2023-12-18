/*
 * Title	INNER1F6.S
 * Description	MPR Inner Loop 1F6
 * Version	1.1
 * Start Date	11/09/98
 * Last Update	05/31/99
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  v1.1 - Edge 'Smoothing'
 * Known bugs:
*/

	.overlay	inn1F6
	.origin		mprinnerbase

	.export _inn1F6_start, _inn1F6_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	1	CLUT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	1	Black Transparent
	;* 7	1	Color On
	;* 8    1       Alpha On

	;* Setup	6 cycles
	;* Per Pixel	20 cycles
	;* Exit		2 cycles
MPR_inn1F6:
       {
	addr	#0xFFFF8000,ru			;ru - 0.5
	sub	_iZ,_iZ
       }
       {
	addr	#0xFFFF8000,rv			;rv - 0.5
	bset	#29,_iZ				;CHNORM value
       }
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru
	sub_p	_DGRBA,_GRBA			;Restep _GRBA
       }
       {
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv
       }
       {
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru
	mul	#1,v0[0],>>#1,v0[0]		;Lut Entry
	lsl	#21,v0[0],v0[3]
       }

`loop:
       {
	ld_p	(uv),v2				;Read Pixel2
	addr	#-1<<16,rv
	mul	#1,v1[0],>>#1,v1[0]		;Lut Entry
	lsl	#21,v1[0],v1[3]
       }
       {
	ld_p	(v0[0]),v0			;Read Pixel0
	mul	#1,v3[0],>>#1,v3[0]		;Lut Entry
	lsl	#21,v3[0],v3[3]
       }
       {
	ld_p	(v1[0]),v1			;Read Pixel1
	mul	#1,v2[0],>>#1,v2[0]		;Lut Entry
	lsl	#21,v2[0],v2[3]
       }
       {
	ld_p	(v3[0]),v3			;Read Pixel3
	sat	#24,v0[3]			;Transparent/Opaque
       }
       {
	ld_p	(v2[0]),v2			;Read Pixel2
	sat	#24,v1[3]               	;Transparent/Opaque
	addm	_DG,_G				;Update _G
       }
       {
	sat	#24,v3[3]       	        ;Transparent/Opaque
	addm	_DR,_R				;Update _R
       }
       {
	sub_sv	v0,v1				;Pixel1-Pixel0
	addm	_DB,_B				;Update _B
       }
       {
	sat	#24,v2[3] 	                ;Transparent/Opaque
	mul_sv	ru,v1,>>#30,v1			;ru(Pixel1-Pixel0)
       }
	sub_sv	v2,v3				;Pixel3-Pixel2
       {
	mul_sv	ru,v3,>>#30,v3			;ru(Pixel3-Pixel2)
	addr	_DU,ru				;Update ru
	add_sv	v0,v1				;avg(01)
       }
	sub_sv	v1,v2				;2-avg(01)
	add_sv	v2,v3 				;avg(23)
       {
	mul_sv	rv,v3,>>#30,v3			;avg(23-01)
	addr	_DV,rv				;Update rv
       }
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru
       }
       {
	add_sv	v1,v3,v2			;avg(0123)
	ld_p	(uv),v1				;Read Pixel1
	addr	#1<<16,rv
       }
       {
	lsr	#22,v2[3]			;
	mul_p	_GRBA,v2,>>#30,v2		;Color Multiply
       }
       {
	mul	#1,v0[0],>>#1,v0[0]		;Lut Entry
	sat	#2,v2[3]			;0/1
	dec	rc0				;Decrement Loop Counter
       }
       {
	bra	c0ne,`loop			;Loop
	mul	_Z,v2[3],>>#0,v2[3]		;Insert Z
	sub	_iZ,v2[1]			;CHNorm Red
       }
       {
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru
	sub	_iZ,v2[2]			;CHNorm Blue
       }
       {
	st_pz	v2,(xy)				;Store pixel
	addr	#1<<16,rx			;Next Pixel
	addm	_DZ,_Z				;Next Z
	lsl	#21+1,v0[0],v0[3]
	rts					;Done
       }
       ;----------------------------------------;bra c0ne,`loop
       {
	mv_s	#0,r0				;No Transparent Pixels
	addr	#0x8000,ru			;ru + 0.5
       }
       {
	mv_s	#1,r1				;Set Translucency Flag
	addr	#0xFFFF8000,rv			;rv - 1 + 0.5
	add_p	_DGRBA,_GRBA			;Update _GRBA
       }
       ;----------------------------------------;rts

