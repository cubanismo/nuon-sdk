/*
 * Title	INNER073.S
 * Description	MPR Inner Loop 073
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

	.overlay	inn073
	.origin		mprinnerbase

	.export _inn073_start, _inn073_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	1	CLUT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	1	Bilinear
	;* 5	1	Texture ON
	;* 6	1	Black Transparent
	;* 7	0	Color Off
	;* 8    0       Alpha Off

	;* Setup	6 cycles
	;* Per Pixel	20 cycles
	;* Exit		2 cycles
MPR_inn073:
       {
	addr	#0xFFFF8000,ru			;ru - 0.5
       }
       {
	addr	#0xFFFF8000,rv			;rv - 0.5
       }
       {
	ld_p	(uv),v0				;Read Pixel0
	addr	#1<<16,ru
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
       }
	sat	#24,v3[3]       	        ;Transparent/Opaque
	sub_sv	v0,v1				;Pixel1-Pixel0
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
       }
       {
	mul	#1,v0[0],>>#1,v0[0]		;Lut Entry
	sat	#2,v2[3]			;0/1
	dec	rc0				;Decrement Loop Counter
       }
       {
	bra	c0ne,`loop			;Loop
	mul	_Z,v2[3],>>#0,v2[3]		;Insert Z
       }
       {
	ld_p	(uv),v3				;Read Pixel3
	addr	#-1<<16,ru
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
	mv_s	#0,r1				;No Translucency
	addr	#0xFFFF8000,rv			;rv - 1 + 0.5
       }
       ;----------------------------------------;rts

