/*
 * Title	INNER0E4.S
 * Description	MPR Inner Loop 0E4
 * Version	1.0
 * Start Date	11/11/98
 * Last Update	11/11/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn0E4
	.origin		mprinnerbase

	.export _inn0E4_start, _inn0E4_size

	;* Bit	Value	Description
	;* 0	0	GRB Texture
	;* 1	0	DIRECT
	;* 2	1	GRB Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture On
	;* 6	1	Black Transparent
	;* 7	1	Color On
	;* 8    0       No Alpha

	;* Setup	3+9 cycles
	;* Per Pixel	3+4 cycles
	;* Exit		2 cycles
MPR_inn0E4:
;* Transparent Pixel Detection
       {
	sub_sv	v1,v1				;Clear v1
	mv_s	#0xFFFF0000,_WIDXTOT		;#of Transparent Pixel -1
       }
       {
	bset	#16,v1[0]                       ;v1[0] One in 16.16
	subm	_DZ,_Z				;Re-Step Z
       }

       ;Pre-Read 1st Pixel
       {
	ld_p	(uv),v0				;Read source pixel
	addr	_DU,ru				;Next ru
	mul	#2,_DU,>>acshift,v2[0]		;v2[0] 2*_DU
	copy	v1[0],v1[1]			;v1[1] One in 16.16
       }
       {
	bra	`TransLoop
	addr	_DV,rv				;Next rv
	copy	v1[0],v1[2]			;v1[2] One in 16.16
       }
       {
	dotp	v0,v1,>>#32,v0[3]  		;Check Color values
	sub_sv	_DGRBA,_GRBA			;Re-Step GRBA
       }
       {
	sub	_WIDXCUR,_WIDXCUR		;Initially Assume Nothing
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
	mv_s	_WIDXTOT,r0			;r0 #of Transparent Pixels
	addr	v2[3],rv			;Re-Step rv
	sub	r1,r1				;Clear Translucency Flag
       }

`TransLoop:
       {
	bra	c0eq,`AllTrans			;Done (nothing to render)
	ld_p	(uv),v0				;Read source pixel
	cmp	#0,v0[3]			;Transparent Pixel ?
       }
       {
	bra	eq,`TransLoop			;Nope, loop
	addr	_DU,ru				;Next ru
	add_sv	_DGRBA,_GRBA			;Update GRBA
	addm	_DZ,_Z				;Update Z
       }
       {
	dotp	v0,v1,>>#32,v0[3]  		;Check Color values
	add	v1[0],_WIDXTOT			;Decrement TOT Width
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
	cmp	#0,v0[3]			;Transparent Pixel ?
       }
       {
	bra	ne,`OpaqueLoop			;Nope, loop
	addr	_DU,ru				;Next ru
       }
       {
	addr	_DV,rv				;Next rv
	dec	rc0				;Decrement Loop Counter
	dotp	v0,v1,>>#32,v0[3]  		;Check Color values
       }
       {
	nop					;Delay slot
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
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	sub_sv	v2,v2			;Clear v2
       }
       {
	addr	_DV,rv			;Next V
	bset	#29,v2[1]		;1/2 in 2.30 format
	dec	rc0			;Decrease Loop Counter
       }
       {
	mul_p	_GRBA,v0,>>#30,v3	;Multiply GRB
	mv_s	v2[1],v2[2]		;1/2 in 2.30 format
	add_p	_DGRBA,_GRBA		;Next _GRBA
       }
`loop:
       {
	bra	c0ne,`loop		;Loop
	ld_p	(uv),v0			;Read Pixel
	addr	_DU,ru			;Next U
	copy	_Z,v1[3]		;Insert Z Value
       }
       {
	addr	_DV,rv 			;Next V
	dec	rc0			;Decrease Loop Counter
	addm	_DZ,_Z			;Next Z
	sub_p	v2,v3,v1		;CHNORM
       }
       {
	mul_p	_GRBA,v0,>>#30,v3	;Multiply GRB
	add_p	_DGRBA,_GRBA		;Next _GRBA
	st_pz	v1,(xy)			;Store New Pixel
	addr	#1<<16,rx		;Next Pixel
       }
       ;--------------------------------;bra c0ne,`loop
       {
	rts				;Done
	sub	_DU,#0,v2[3]		;v2[3] -_DU
       }
       {
	addr	v2[3],ru 		;Re-Step ru
	sub	_DV,#0,v2[3]		;v2[3] -_DU
	ld_s	(MPR_TransPix),r0	;Return #of Transparent Pixels
       }
       {
	addr	v2[3],rv 		;Re-Step ru
	sub_p	_DGRBA,_GRBA		;Re-Step _GRBA
	subm	r1,r1			;Clear Translucency Flag
       }
       ;--------------------------------;rts

