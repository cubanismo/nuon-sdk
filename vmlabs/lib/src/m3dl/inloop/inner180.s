/*
 * Title	INNER180.S
 * Description	MPR Inner Loop 180
 * Version	1.0
 * Start Date	12/05/98
 * Last Update	12/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn180
	.origin		mprinnerbase

	.export _inn180_start, _inn180_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	0	Texture ON
	;* 6	0	Black Opaque
	;* 7	1	Color On
	;* 8    0       No Alpha

	;* Setup	1 cycles
	;* Per Pixel	3 cycles
	;* Exit		1 cycles
MPR_inn180:
	dec	rc0			;Decrease Loop Counter

`loop:
       {
	bra	c0ne,`loop		;Loop
	mv_v	_GRBA,v0		;
       }
       {
	rts				;Done
	mv_s	_Z,v0[3]		;Insert _Z
	add_p	_DGRBA,_GRBA		;Update GRBA
       }
       {
	add 	_DZ,_Z			;Update _Z
	st_pz	v0,(xy)			;Store New Pixel
	addr	#1<<16,rx		;Next Pixel
	dec	rc0			;Decrease Loop Counter
       }
       ;--------------------------------;bra c0ne,`loop
       {
	mv_s	#1,r1			;Set Translucency Flag
	subm	r0,r0			;No Transparent Pixels
       }
       ;--------------------------------;rts

