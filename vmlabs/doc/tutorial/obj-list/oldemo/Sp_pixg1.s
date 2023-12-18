; pixg1 - inner lloop for esprite


; pixel replicate with transparency

	push	v0,rz
	jsr read_dest,nop				;get dest buffer - returns with pixels to read in r5.
	pop	v0,rz

	nop
	mv_s	#bg_pixel,r0
	ld_s	(r0),r6					;transparency value
	nop
	mv_s	#dest_buffer,r4
{
	add	buffer_offset,r4
	st_s	dma_len,rc0
}
	ld_s	(uv),r0
	ld_s	(r5),r1
{
	copy	r0,r2
	addr	tosource[2],rv
}
{
	mv_s	r1,r3
	add	#4,r5
	addr	tosource[0],ru
}
{
	mv_s	#4,r7				;const
	cmp	r2,r6
;	dec	rc0
}	
pg1:
{
	bra	ne,nxpar
	dec	rc0
	ld_s	(uv),r0
	addr	tosource[2],rv
}
{
	ld_s	(r5),r1				;xparency value
	addr	tosource[0],ru
}
	nop
	copy	r3,r2				;only executed if xparent pixel

nxpar:
{
	mv_s	r1,r3
	add	#4,r5
	bra	c0ne,pg1
}
{
	st_s	r2,(r4)
	copy	r0,r2
    jmp out
}
{
;	ld_s	(uv),r0
	cmp	r2,r6					;check for next time around
	addm	r7,r4,r4	
}
    nop