; This is the pixel generation function.  It collects *bilerped* pixels from the 8x8 pattern buffer and
; deposits them in the linear destination buffer for output to external RAM.

; This one has bilinear interpolation  plus translucency
; and "proper" (i.e. expensive) transparency.





	push	v0,rz
	jsr read_dest,nop				;returns buffer address in r5
    jsr dma_finished,nop
	pop	v0,rz

{
	st_s	dma_len,rc0
	copy	r5,dest_r
}
	push	v2
	push	v3
	push	v4
	push	v5
	push	v6
	mv_s	#dest_buffer,r0
{
	add	r0,dma_dbase			;dma_dbase *is* buffer_offset!
	ld_s	ru,x

}
{
	sub	#4,dma_dbase
	ld_s	rv,_y
}
	st_s	x,rx
	st_s	_y,ry
	mv_s	#4,four
	mv_s	#bg_pixel-12,mix
	ld_s	(mix),mix


;	sub	zero,zero


; xperimental hackingness


{
	ld_pz	(xy),pixel1			
	addr	#1,rx
}
{
	ld_pz	(xy),pixel2
	addr	#1,ry
}
{
	ld_pz	(dest_r),v5
	cmp	#0,r3
}
	bra	ne,eggnog1				;branch for pixel1
{
	ld_pz	(xy),pixel4
	addr	#-1,rx
}
	cmp	#0,r7
	mv_v	v5,pixel1			;set pixel 1 if needed
	
eggnog1:

{
	ld_pz	(xy),pixel3
	bra	ne,eggnog2				;branch for pixel2
	addr	#-1,ry
}
{
	cmp	#0,r15
	addr	xi,rx
}
{
	addr	yi,ry				;XY set now points at next pixel 
}
	mv_v	v5,pixel2		

eggnog2:

{
	mv_v	pixel1,pixel5				;spare v-reg, free pixel1
	sub_p	pixel1,pixel2
	bra	ne,eggnog3	
}
{
	ld_pz	(xy),pixel1				;got next pix1
	mul_p	ru,pixel2,>>#14,pixel2
	addr	#1,rx
}
	cmp	#0,r11
	mv_v	v5,pixel4

eggnog3:

{
	ld_pz	(xy),pixel2				;got second pixel2
	bra	ne,eggnog4					;branch for original pix4
	addr	#1,ry
	add_p	pixel2,pixel5			;partial result in pix5, pixel2 is free
}
{	
	ld_pz	(dest_r),v5
	add	four,dest_r
}
	cmp	#0,r3						;cmp for *second* pix1
{
	mv_v	v5,pixel3				;*at last* we can start the second half of the bilerp
}
eggnog4:

{
	bra	ne,eggnog5					;branch for second pix1
	sub_p	pixel3,pixel4
}
{
	lsr	#22,r7						;shift any stuff in r7 down to lo 16-bits
	addr	xi,ru
	mul_p	ru,pixel4,>>#14,pixel4
}
{
	st_s	r7,rc1				;so I can test for zero by using c1ne (hack that may not be necessary in beta)
	sub_p	pixel5,pixel3			;start to merge pixel 5 in
}
	ld_pz	(dest_r),pixel1

eggnog5:
{	
	bra	c1ne,eggnog6
	ld_pz	(xy),pixel4
	add_p	pixel4,pixel3	
	addr	#-1,rx
}
{
	mul_p	rv,pixel3,>>#14,pixel3
	sub_p	v5,pixel5				;start to merge xlucent in
	addr	yi,rv
}
	cmp	#0,r15						;transp on pixel4
	ld_pz	(dest_r),pixel2
eggnog6:
{
	bra	ne,eggnog7
	ld_pz	(xy),pixel3
	add_p	pixel3,pixel5			;on the way to blend...
	dec	rc0
}
;{
;    sub_sv  v5,pixel5
;    bra ne,eggnog7
;}
{
	mul_p	mix,pixel5,>>#14,pixel5
	addr	#-1,ry
	add	#4,dma_dbase
}
{
	sub_p	pixel1,pixel2
;    mv_s    #$10101010,r23
}

	ld_pz	(dest_r),pixel4
	nop

eggnog7:
{
	mv_v	pixel1,pixel5
	jmp	c0ne,eggnog3
	add_p	pixel5,v5
	mul_p	ru,pixel2,>>#14,pixel2
	addr	xi,rx
}
{
	st_pz	v5,(dma_dbase)
	addr	yi,ry
}
{
	ld_pz	(xy),pixel1
	cmp	#0,r11						;set flags for re-entry in the loop
	addr	#1,rx
}

	
	pop	v6
	pop	v5
	pop	v4
	pop	v3
    jmp out
	pop	v2
	nop

