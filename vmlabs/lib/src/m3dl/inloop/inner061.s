/*
 * Title	INNER061.S
 * Description	MPR Inner Loop 061
 * Version	1.0
 * Start Date	11/11/98
 * Last Update	11/11/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	inn061
	.origin		mprinnerbase

	.export _inn061_start, _inn061_size

	;* Bit	Value	Description
	;* 0	1	YCC Texture
	;* 1	0	DIRECT
	;* 2	0	YCC Screen
	;* 3	0	Affine
	;* 4	0	Point Sampled
	;* 5	1	Texture ON
	;* 6	1	Black Transparent
	;* 7	0	Color Off
	;* 8    0       No Alpha

	;* Setup	1+9 cycles
	;* Per Pixel	3+4 cycles
	;* Exit		1 cycle
MPR_inn061:
;* Transparent Pixel Detection
       {
	sub_sv	v1,v1				;Clear v1
	mv_s	#0xFFFF0000,_WIDXTOT		;#of Transparent Pixel -1
       }
       {
	bra	`TransLoop
	bset	#16,v1[0]                       ;v1[0] One in 16.16
       }

       ;Pre-Read 1st Pixel
       {
	ld_p	(uv),v0				;Read source pixel
	addr	_DU,ru				;Next ru
	mul	#2,_DU,>>acshift,v2[0]		;v2[0] 2*_DU
       }
       {
	sub	_WIDXCUR,_WIDXCUR		;Initially Assume Nothing
	addr	_DV,rv				;Next rv
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
	cmp	#0,v0[0]			;Transparent Pixel ?
       }
       {
	bra	eq,`TransLoop			;Nope, loop
	addr	_DU,ru				;Next ru
       }
       {
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
	ld_s	(MPR_TransPix),r0	;Return #of Transparent Pixels
	sub	r1,r1 			;Clear Translucency Flag
       }
       ;--------------------------------;rts

