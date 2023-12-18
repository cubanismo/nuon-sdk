/*
 * Title	INNER0E3.S
 * Description	MPR Inner Loop 0E3
 * Version	1.0
 * Start Date	11/05/98
 * Last Update	11/05/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn0E3
	.origin		mprinnerbase

	.export _inn0E3_start, _inn0E3_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	1	CLUT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	1	Black Transparent
	;* 7	1	Color On
	;* 8    0       No Alpha

	;* Setup	6+9 cycles
	;* Per Pixel	4+4 cycles
	;* Exit		2 cycles
MPR_inn0E3:
;* Transparent Pixel Detection
       {
	sub_sv	v1,v1				;Clear v1
	mv_s	#0xFFFF0000,_WIDXTOT		;#of Transparent Pixel -1
       }

       ;Pre-Read 1st Pixel
       {
	bra	`TransLoop
	ld_p	(uv),v0				;Read source pixel
	addr	_DU,ru				;Next ru
	bset	#16,v1[0]			;v1[0] One in 16.16
       }
       {
	addr	_DV,rv				;Next rv
	addm	_DU,_DU,v2[0]			;v2[0] 2*_DU
       }
       {
	bits	#11-1,>>#0,v0[0]		;Isolate Clut Entry
	subm	_WIDXCUR,_WIDXCUR		;Initially Assume Nothing
       }
       ;----------------------------------------;bra eq,`transloop
`AllTrans:
       {
	mv_s	_DV,v2[3]			;_DV
	rts 					;Finished
	neg	v2[0]				;-2*_DU
       }
       {
	st_s	_WIDXCUR,(MPR_WXCLXHYCTY)	;Set Width Counter
	addr	v2[0],ru			;Re-Step ru
	neg	v2[3]				;-_DV
       }
       {
	addr	v2[3],rv			;Re-Step rv
	mv_s	_WIDXTOT,r0			;r0 #of Transparent Pixels
	sub	r1,r1				;Clear Translucency Flag
       }

`TransLoop:
       {
	bra	c0eq,`AllTrans			;Done (nothing to render)
	ld_p	(uv),v0				;Read source pixel
	cmp	#0,v0[0]			;Transparent Pixel ?
       }
       {
	bra	eq,`TransLoop			;Nope, loop
	addr	_DU,ru				;Next ru
       }
       {
	addm	v1[0],_WIDXTOT			;Next Transparent Pixel
	bits	#11-1,>>#0,v0[0]		;Isolate Clut Entry
       }
       {
	addr	_DV,rv				;Next rv
	dec	rc0				;Decrement Loop Counter
       }
       ;----------------------------------------;bra eq,`transloop
	ld_s	(ru),v2[2]			;Backup ru
	ld_s	(rv),v2[3]			;Backup rv
`OpaqueLoop:
       {
	bra	c0eq,`OpaqueDone		;Finished
	ld_p	(uv),v0				;Read source pixel
	addm	v1[0],_WIDXCUR			;Increment Current Width
	cmp	#0,v0[0]			;Transparent Pixel ?
       }
       {
	bra	ne,`OpaqueLoop			;Nope, loop
	addr	_DU,ru				;Next ru
       }
       {
	addr	_DV,rv				;Next rv
	dec	rc0				;Decrement Loop Counter
       }
       {
	bits	#11-1,>>#0,v0[0]		;Isolate Clut Entry
       }
       ;----------------------------------------;bra eq,`transloop
`OpaqueDone:
       {
	st_s	_WIDXCUR,(MPR_WXCLXHYCTY)	;Set Width Counter
	mul	#1,_WIDXCUR,>>#16,_WIDXCUR	;Shift down
	sub	_DV,>>#-1,v2[3]			;Re-Step rv
       }
       {
	st_s	_WIDXTOT,(MPR_TransPix)		;Set #of Transparent Pixels
	mvr	v2[3],rv                        ;Set rv
	sub	v2[0],v2[2]			;Re-Step ru
       }
       {
	mvr	v2[2],ru			;Set ru
	st_s	_WIDXCUR,(rc0)			;Set Inner loop Counter
       }
       ;----------------------------------------;EndTransparentDetect
;* End of Transparent Pixel Detection

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
	rts
       }
       ;--------------------------------;bra c0ne,`loop
       {
	ld_s	(MPR_TransPix),r0	;Return #of Transparent Pixels
	addr	v0[3],ru		;Re-Step ru
       }
       {
	sub	r1,r1			;Clear Translucency Flag
	addr	v1[3],rv		;Re-Step rv
       }
       ;--------------------------------;rts

