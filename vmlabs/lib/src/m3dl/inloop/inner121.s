/*
 * Title	INNER121.S
 * Description	MPR Inner Loop 121
 * Version	1.0
 * Start Date	11/05/98
 * Last Update	11/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn121
	.origin		mprinnerbase

	.export _inn121_start, _inn121_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	0	DIRECT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	0	Black Opaque
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	1 cycle
	;* Per Pixel	3 cycles
	;* Exit		1 cycle
MPR_inn121:
	dec	rc0			;Decrease Loop Counter
`loop:
       {
	bra	c0ne,`loop		;Loop
	ld_p	(uv),v0			;Read Pixel
	copy	_Z,v0[3]		;Insert Z Value
	addr	_DU,ru			;Next U
       }
       {
	addr	_DV,rv 			;Next V
	add	_DZ,_Z			;Next Z
	dec	rc0			;Decrease Loop Counter
	rts
       }
       {
	st_pz	v0,(xy)			;Store New Pixel
	addr	#1<<16,rx		;Next Pixel
       }
       ;--------------------------------;bra c0ne,`loop
       {
	sub	r0,r0			;No Transparent Pixels
	mv_s	#1,r1			;Set Translucency Flag
       }
       ;--------------------------------;rts

