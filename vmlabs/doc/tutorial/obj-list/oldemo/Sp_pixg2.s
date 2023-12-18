; This is the pixel generation function.  It collects *bilerped* pixels from the 8x8 pattern buffer and
; deposits them in the linear destination buffer for output to external RAM.

; This one has bilinear interpolation and "rough" transparency - that is, edges are chopped, and
; not blended.



	pixel = v0
	pixel2 = v1
	pixel3 = v2
	pixel4 = v3
	pixel5 = v4
	xi = tosource[0]
	yi = tosource[2]
	x = r20
	_y = r21
	dma_dbase = r22
	four = r25
	zero = r26
;	onepix = r27
	dest_r = r27

;	mv_s	#bg_pixel,r0
;	ld_s	(r0),r1
;	ld_p	(r0),v1
;	ld_p	(r0),v2


	push	v0,rz
	jsr read_dest,nop				;returns buffer address in r5
dmaw:
	ld_s	mdmactl,r0
	nop
	bits	#4,>>#0,r0
	bra	ne,dmaw,nop


	pop	v0,rz
{
	st_s	dma_len,rc0
	copy	r5,dest_r
}
	ld_s	ru,x
	ld_s	rv,_y
	st_s	x,rx
	st_s	_y,ry
	st_s	#0,xyrange
	st_s	#0,uvrange
	push	v2
	push	v3
	push	v4
	push	v5
	push	v6
	mv_s	#dest_buffer,dma_dbase
;	mv_s	#bg_pixel,r0
;	ld_s	(r0),transp
	mv_s	#4,four
	sub	zero,zero
	
thig:
{
 	ld_pz	(uv),pixel				;Grab a pixel from the source
	addr	#1,ru					;go to next horiz pixel
	add	buffer_offset,dma_dbase		;allow for d-buffering
}
{
	ld_pz	(uv),pixel2				;Get a second pixel
	addr	#1,rv					;go to next vert pixel
}
{
	ld_pz	(uv),pixel4				;get a third pixel
	addr	#-1,ru					;go to prev horizontal pixel
	sub	#4,dma_dbase				;point at start of buffer -4
}
	copy	r7,r16
{
	ld_pz	(uv),pixel3				;get a fourth pixel
	addr	#-1,rv					;go back to original pixel
	sub_p	pixel,pixel2			;b=b-a
}	
{	
	sub	#4,dest_r
	addm	xi,x,x						;pre increment x
}

bilerp:

;{
;    mv_s    #4,four
;    sub zero,zero
;}

{
	addm	four,dest_r,dest_r
	add	r11,r16
}
	add	r3,r16
	add	r15,r16
{
	mv_v	pixel,pixel5			;save a copy of first pixel, freeing up pixel 1.
	jmp	eq,do_xparent2				;go to special transparency case
	mul_p	ru,pixel2,>>#14,pixel2	;scale according to fractional part of ru
	sub_p	pixel3,pixel4			;make vector between second 2 pixels
	addr	yi,ry					;Point ry to next y
}
{
	st_s	x,ru					;Can now update ru, finished multiplying with it.
	mul_p	ru,pixel4,>>#14,pixel4	;scale according to fractional part of ru
	sub_p	pixel3,pixel,pixel3
	addr	xi,rx					;(XY) now points at next pixel 1
}
{
	ld_pz	(xy),pixel				;Loading next pixel 1.
	addr	#1,ry					;POinting to next pixel 3.
	add_p	pixel2,pixel3			;get first intermediate result
	dec	rc0							;Decrementing the loop counter.
}
{
	ld_pz	(xy),pixel3				;getting next pixel 3.
	sub_p	pixel3,pixel4			;get vector to final value
	addm	yi,_y,_y					;Point to next y	
	addr	#-1,ry					;Working over to point to pixel 2.
}
{
	st_s	_y,rv					;Can now update this as finished multiplying.
	mul_p	rv,pixel4,>>#14,pixel4	;scale with fractional part of rv
	add_p	pixel2,pixel5			;add pix2 to the copy of pix1
	addr	#1,rx					;(xy) now points at pixel 2.
}
{							   
	jmp	c0ne,bilerp					;start the branch
	ld_pz	(xy),pixel2				;load up next pixel2
	addr	#1,ry					;point to next pixel 4
	add	#4,dma_dbase				;Incrementing the output buffer pointer.
}
{
	ld_pz	(xy),pixel4				;get next pixel4
	add_p	pixel4,pixel5			;make final pixel value
	addr	#-1,rx					;start putting these right	
	addm	xi,x,x					;do x inc
}
{
	st_p	pixel5,(dma_dbase)		;Deposit the pixel in the dest buffer
	addr	#-1,ry					;finish putting these right
	sub_p	pixel,pixel2			;b=b-a
	addm	r7,zero,r16
}
xxx:

	pop	v6
	pop	v5
	pop	v4
{
	jmp	out
	pop	v3
}
	pop	v2
	nop

do_xparent:

{
	mv_v	pixel,pixel5			;save a copy of first pixel, freeing up pixel 1.
	jmp	eq,do_xparent2				;go to special transparency case
	mul_p	ru,pixel2,>>#14,pixel2	;scale according to fractional part of ru
	sub_p	pixel3,pixel4			;make vector between second 2 pixels
	addr	yi,ry					;Point ry to next y
}


do_xparent0:

{
	st_s	x,ru					;Can now update ru, finished multiplying with it.
	mul_p	ru,pixel4,>>#14,pixel4	;scale according to fractional part of ru
	sub_p	pixel3,pixel,pixel3
	addr	xi,rx					;(XY) now points at next pixel 1
}

do_xparent1:

; special-case code for transparent pixels

{
	ld_pz	(xy),pixel				;Loading next pixel 1.
	addr	#1,ry					;POinting to next pixel 3.
	add_p	pixel2,pixel3			;get first intermediate result
	dec	rc0							;Decrementing the loop counter.
}

do_xparent2:

{
	ld_pz	(xy),pixel3				;getting next pixel 3.
;	sub_p	pixel3,pixel4			;get vector to final value
	addm	yi,_y,_y					;Point to next y	
	addr	#-1,ry					;Working over to point to pixel 2.
}
{
	st_s	_y,rv					;Can now update this as finished multiplying.
;	mul_p	rv,pixel4,>>#14,pixel4	;scale with fractional part of rv
;	add_p	pixel2,pixel5			;add pix2 to the copy of pix1
	addr	#1,rx					;(xy) now points at pixel 2.
}
	ld_s	(dest_r),r16
;	mv_s	#$ffffff00,r16
{
	ld_pz	(xy),pixel2				;load up next pixel2
	addr	#1,ry					;point to next pixel 4
    add	#4,dma_dbase				;Incrementing the output buffer pointer.
	jmp	c0ne,bilerp					;start the branch
}
{
	jmp	xxx							;in case last pixel is also xparent
	ld_pz	(xy),pixel4				;get next pixel4
;	add_p	pixel4,pixel5			;make final pixel value
	addr	#-1,rx					;start putting these right	
	addm	xi,x,x					;do x inc
}
{
	st_s	r16,(dma_dbase)		;Deposit the pixel in the dest buffer
	addr	#-1,ry					;finish putting these right
	sub_p	pixel,pixel2			;b=b-a
	addm	r7,zero,r16
}
	nop

