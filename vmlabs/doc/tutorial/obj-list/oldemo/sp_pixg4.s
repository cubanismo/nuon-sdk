; This is the pixel generation function.  It collects *bilerped* pixels from the 8x8 pattern buffer and
; deposits them in the linear destination buffer for output to external RAM.
	;
; This version does not read dest before write, and thus has no transparency. This would be the inner
; loop of choice for smoothed feedback, or tinting any image that does not need transparency.


;	pixel = v0
;	pixel2 = v1
;	pixel3 = v2
;	pixel4 = v3
;	pixel5 = v4
;	xi = tosource[0]
;	yi = tosource[2]
;	x = r20
;	_y = r21
	_dma_dbase = r22
	_mix = r23


	st_s	dma_len,rc0
	ld_s	ru,x
	ld_s	rv,_y
	st_s	x,rx
	st_s	_y,ry
	push	v2
	push	v3
	push	v4
	push	v5
	push	v6
	mv_s	#dest_buffer,_dma_dbase

	ld_s	mdmactl,r1
	nop
dmaw:	btst	#4,r1		;have to dma-wait so as not to ruin the buffer
	bra	ne,dmaw
	ld_s	mdmactl,r1
	nop

	
thig:
{
 	ld_p	(uv),pixel				;Grab a pixel from the source
	addr	#1,ru					;go to next horiz pixel
	add	buffer_offset,_dma_dbase		;allow for d-buffering
}
{
	ld_p	(uv),pixel2				;Get a second pixel
	addr	#1,rv					;go to next vert pixel
}
{
	ld_p	(uv),pixel4				;get a third pixel
	addr	#-1,ru					;go to prev horizontal pixel
	sub	#4,_dma_dbase				;point at start of buffer -4
}
{
	ld_p	(uv),pixel3				;get a fourth pixel
	addr	#-1,rv					;go back to original pixel
	sub_sv	pixel,pixel2			;b=b-a
}	
	nop
	mv_s	#bg_pixel+4,_mix			;tint value is here	
{	
	ld_p	(_mix),v6					;grok tint
	sub	#16,_mix						;point @ mix
}
	ld_s	(_mix),_mix				;get mix
	add	xi,x						;pre increment x

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
	ld_p	(xy),pixel2				;load up next pixel2
	addr	#1,ry					;point to next pixel 4
	sub_sv	v6,pixel5
}
{
	ld_p	(xy),pixel4				;get next pixel4
	add_sv	pixel4,pixel5			;make final pixel value
	addr	#-1,rx					;start putting these right	
	addm	xi,x,x					;do x inc
}
{
	add	#4,_dma_dbase
	mul_sv	_mix,pixel5,>>#14,pixel5	
}
	jmp	c0ne,bilerp					;start the branch
	add_sv	v6,pixel5
{
	st_p	pixel5,(_dma_dbase)		;Deposit the pixel in the dest buffer
	addr	#-1,ry					;finish putting these right
	sub_sv	pixel,pixel2			;b=b-a
}



	pop	v6
	pop	v5
	pop	v4
	pop	v3
	pop	v2
	nop

