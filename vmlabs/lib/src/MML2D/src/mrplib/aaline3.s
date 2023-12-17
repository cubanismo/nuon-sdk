
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

;
; pixel gen code for the full monty - fat antialiased
; translucent lines

aaline3:

	st_s	dma_len,rc0			;init pixgen counter
;	push	v5
{
	push	v6
	copy	dma_xpos,curx
}
{
	push	v7
	sub	y1_,dma_ypos,r25				;copy for colour lerp
}
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#8,r0
{
	btst	#0,edge_swap
//	mv_s	#object+8,r0
}
{
	bra	eq,pgen1
	st_s	#0,rx
}
	st_s	r0,xybase				;colour is here
{
	mv_s	#1,r2
	sub	x1_,curx,r24
	subm	x1_,curx,temp2
}
	mv_s	#-1,r2
	sub	curx,x1_,r24
pgen1:
	mul	delta_y,r24,>>#20,r24
	mv_s	#$10000,r1
	add	y1_,r24
{
	subm	r24,dma_ypos,r24
	asr	#4,delta_y,r0
}
	mul	sineline,r24,>>#28,r24			;get perpendicular distance to line
{
//	mv_s	#randy,r28					// TAJ - moved below to make coherent with LOAD macro
	mul	sineline,r0,>>#28,r0
	sub	sineline,#0,r23
}
{
	mv_s	cosline,r3
	cmp	#0,delta_x
}
//	mv_s	#randy,r28					// TAJ - moved here to make coherent with LOAD macro
/*	.if(B==0)
	LOAD Grandy, ld_v, randy, r28, v7
	.else
	mv_s	#randy,r28	//LOADIndirectDtram
	ld_s	(r28),r28
	nop
	ld_v	(r28),v7
	nop
	.endif
*/
{
//	ld_v	(r28),v7					;get ran# thangs
	bra	ne,pixgo
}

	mul	r2,r0,>>#0,r0
{
	dec	rc0
}

; this stuff is for a pure vertical line

	sub	curx,x1_,r24
	mv_s	#$10000,r0
	mv_s	#$0000000,r23


pixgo:


pixgen:					 
{
	mv_s	r23,r2
	sub	curx,x1_,r4				;x dist to ep1
	mul	r24,r6,>>#28,r6
}
{
	push	v6
	sub	dma_ypos,y1_,r5			;y dist to ep1
	mul	r24,r2,>>#28,r2
}
{
	ld_p	(xy),v7				;get srce-pixel
	mul	r4,r4,>>#32,r4			;xsquared
	add	temp2,r6
}
{
	mul	r6,r6,>>#32,r6
	add	r25,r2
}
{
	mul	r2,r2,>>#32,r2
	jmp	lt,ep_1					;in endpoint 1 zone
	abs	r24
}
{
	sub	r24,width,r24
	mul	r5,r5,>>#32,r5			;ysquared
}
{
	add	r2,r6
	jmp	lt,oxout,nop			;outside line width
}
{
	sub	curx,x21,r4
	mul	hyp,r6,>>#16,r6	
}
{
	mul	r4,r4,>>#32,r4
	mv_s	#$3fff,r7
	sub	dma_ypos,y21,r5
}
{
	mul	r5,r5,>>#32,r5
	sub	r7,r6,r7
}
{
	jmp	ge,ep_1,nop				;in endpoint 2 zone
}

gopixl:

{
	copy	r24,r2
	ld_p	(uv),v6			;get linecolour
}
{
	mul	mix,r2,>>#16,r2
}
	sub_sv	v6,v7
;	mul_p	r2,v7,>>#14,v7
	mul_p	r2,v7,>>#30,v7
	nop
{
	pop	v6
	jmp	c0ne,pixgen
	add_sv	v6,v7
}	
{
	jmp	wrout
	addm	r1,temp2,temp2
	copy	r3,r6
}
{
	st_p	v7,(uv)
;	addr	#1,ru
	addr	#(1<<16),ru
	dec	rc0
	subm	r0,r24,r24
	add	r1,curx
}
	pop	v7
ep_1:

; get here if in endpoint 1 zone

	copy	width,r2
	mul	r2,r2,>>#32,r2
	add	r5,r4				;sum of squares of distance to ep1
	cmp	r4,r2
	bra	lt,oxout
	nop
	jsr	sqrt
	push	v0
{
	push	v1
	copy	r4,r0
}
{
	jmp	gopixl
	pop	v1
	sub	#16,r1
}
{
	pop	v0
	ls	r1,r0,r24
}
	sub	r24,width,r24

oxout:
	pop	v6
	nop
;	mv_s	#$ffffff00,r6
{
	jmp	c0ne,pixgen
	sub	r0,r24
	addm	r1,temp2,temp2
}
{
;	st_s	r6,(uv)		;remove if not test mode
;	addr #1,ru
	addr #(1<<16),ru
	add	r1,curx
}
{
	dec	rc0
	copy	r3,r6
}
	pop	v7
