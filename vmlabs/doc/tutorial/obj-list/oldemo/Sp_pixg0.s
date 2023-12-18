; pixg0 - inner lloop for esprite


; simplest case, pixel replicate with no xparency

	ld_s	mdmactl,r1
	nop
dmaw0:	bits	#4,>>#0,r1		;have to dma-wait so as not to ruin the buffer
{
	bra	ne,dmaw0
	mv_s	#dest_buffer,r4
}
	ld_s	mdmactl,r1
	nop


	st_s	dma_len,rc0
{
	add	buffer_offset,r4
	ld_s	(uv),r0
}
	nop
{
	mv_s	#4,r7				;const
	cmp	r2,r6
	dec	rc0
	addr	tosource[0],ru
}	

pg0:
{
	st_s	r0,(r4)	
	bra	c0ne,pg0
	dec	rc0
	add	r7,r4
	addr	tosource[2],rv
}
{
    jmp out
	ld_s	(uv),r0
	addr	tosource[0],ru
}
	nop
    nop
