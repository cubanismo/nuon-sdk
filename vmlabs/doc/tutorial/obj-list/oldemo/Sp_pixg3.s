; This is the pixel generation function.  It collects *bilerped* pixels from the 8x8 pattern buffer and
; deposits them in the linear destination buffer for output to external RAM.
;
; This version does not read dest before write, and thus has no transparency.  It would be useful for
; maybe generating a smoothed backdrop, or drawing a sprite on an empty screen, or for feedback (but
; the vesion with  fade-to-<colour> would be a better choice for feedback).

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


	.if	alpha
	st_io	dma_len,(rc0)
	ld_io	(ru),x
	ld_io	(rv),_y
	st_io	x,(rx)
	st_io	_y,(ry)
	.else
	st_s	dma_len,rc0
	ld_s	ru,x
	ld_s	rv,_y
	st_s	x,rx
	st_s	_y,ry
	.end
	push	v2
	push	v3
	push	v4
	push	v5
	mv_s	#dest_buffer,dma_dbase

	.if	alpha
	ld_io	(dmactl),r1
	.else
	ld_s	mdmactl,r1
	.end
	nop
dmaw:	btst	#4,r1		;have to dma-wait so as not to ruin the buffer
	bra	ne,dmaw
	.if	alpha
	ld_io	(dmactl),r1
	.else
	ld_s	mdmactl,r1
	.end
	nop

	
thig:
{
 	ld_p	(uv),pixel				;Grab a pixel from the source
	addr	#1,ru					;go to next horiz pixel
	add	buffer_offset,dma_dbase		;allow for d-buffering
}
{
	ld_p	(uv),pixel2				;Get a second pixel
	addr	#1,rv					;go to next vert pixel
}
{
	ld_p	(uv),pixel4				;get a third pixel
	addr	#-1,ru					;go to prev horizontal pixel
	sub	#4,dma_dbase				;point at start of buffer -4
}
{
	ld_p	(uv),pixel3				;get a fourth pixel
	addr	#-1,rv					;go back to original pixel
	sub_sv	pixel,pixel2			;b=b-a
}	
{	
	addm	xi,x,x						;pre increment x
}

bilerp:

; Here is the bilerp part.

{
	mv_v	pixel,pixel5			;save a copy of first pixel, freeing up pixel 1.
	mul_p	ru,pixel2,>>#14,pixel2	;scale according to fractional part of ru
	sub_sv	pixel3,pixel4			;make vector between second 2 pixels
	addr	yi,ry					;Point ry to next y
}
{
	st_s	x,ru					;Can now update ru, finished multiplying with it.
	mul_p	ru,pixel4,>>#14,pixel4	;scale according to fractional part of ru
	sub_sv	pixel3,pixel,pixel3
	addr	xi,rx					;(XY) now points at next pixel 1
}
{
	ld_p	(xy),pixel				;Loading next pixel 1.
	addr	#1,ry					;POinting to next pixel 3.
	add_sv	pixel2,pixel3			;get first intermediate result
	dec	rc0							;Decrementing the loop counter.
}
{
	ld_p	(xy),pixel3				;getting next pixel 3.
	sub_sv	pixel3,pixel4			;get vector to final value
	addm	yi,_y,_y					;Point to next y	
	addr	#-1,ry					;Working over to point to pixel 2.
}
{
	st_s	_y,rv					;Can now update this as finished multiplying.
	mul_p	rv,pixel4,>>#14,pixel4	;scale with fractional part of rv
	add_sv	pixel2,pixel5			;add pix2 to the copy of pix1
	addr	#1,rx					;(xy) now points at pixel 2.
}
{
	jmp	c0ne,bilerp					;start the branch
	ld_p	(xy),pixel2				;load up next pixel2
	addr	#1,ry					;point to next pixel 4
	add	#4,dma_dbase				;Incrementing the output buffer pointer.
}
{
	ld_p	(xy),pixel4				;get next pixel4
	add_sv	pixel4,pixel5			;make final pixel value
	addr	#-1,rx					;start putting these right	
	addm	xi,x,x					;do x inc
}
{
	st_p	pixel5,(dma_dbase)		;Deposit the pixel in the dest buffer
	addr	#-1,ry					;finish putting these right
	sub_sv	pixel,pixel2			;b=b-a
}

	pop	v5
	pop	v4
	pop	v3
	pop	v2
	nop

