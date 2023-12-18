/*
 * Title	INNER126.S
 * Description	MPR Inner Loop 126
 * Version	1.0
 * Start Date	11/05/98
 * Last Update	11/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn126
	.origin		mprinnerbase

	.export _inn126_start, _inn126_size

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

	;* Setup	3 cycles
	;* Per Pixel	4 cycles
	;* Exit		2 cycles
MPR_inn126:
       {
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	sub_sv	v3,v3			;Clear v3
       }
       {
	bset	#29,v3[1]		;1/2 in 2.30 format
	subm	_DU,v3[3]		;-_DU
       }
       {
	mv_s	v3[1],v3[2]		;1/2 in 2.30 format
	lsr	#1,r0			;16 Bit Clut
       }

`loop:
       {
	dec	rc0			;Decrement Loop Counter
	ld_p	(r0),v1			;Read source pixel
	addr	_DV,rv			;Add Delta V
       }
       {
	bra	c0ne,`loop              ;Loop
	ld_p	(uv),v0			;Read clut lookup
	addr	_DU,ru			;Add Delta U
	copy	_Z,v2[3]		;Insert Z
       }
       {
	rts
	sub_p	v3,v1,v2		;CHNORM
	addm	_DZ,_Z			;Next Z
       }
       {
	st_pz	v2,(xy)			;Store destination pixel
	addr	#1<<16,rx		;Next Pixel
	lsr	#1,r0			;16 Bit Clut
       }
       ;--------------------------------;bra c0ne,`loop
       {
	addr	v3[3],ru 		;Re-Step ru
	sub	r0,r0			;No Transparent Pixels
	mv_s	#1,r1  			;Set Translucency Flag
       }
       ;--------------------------------;rts



