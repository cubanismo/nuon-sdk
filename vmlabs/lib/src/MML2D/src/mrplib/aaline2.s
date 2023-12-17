
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

;
; pixel gen code for standard solid fat line w/rounded ends
aaline2:

	st_io	dma_len,(rc0)			;init pixgen counter
;	push	v5
{
	copy	dma_xpos,curx
	push	v6
}
{
//	mv_s	#object+8,r0
}
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#8,r0

	btst	#0,edge_swap
{
	bra	eq,pgen1
	st_s	#0,rx
}
{
	st_s	r0,xybase				;colour is here
	sub	y1_,dma_ypos,r25				;copy for colour lerp
}
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
 	mul	sineline,r0,>>#28,r0
	sub	sineline,#0,r23
}
	cmp	#0,delta_x
	bra	ne,pixgen
	mul	r2,r0,>>#0,r0
{
	dec	rc0
	copy	cosline,r3
}
	sub	curx,x1_,r24
	mv_s	#$10000,r0
	mv_s	#$0000000,r23




pixgen:


{
	mv_s	r23,r2
	sub	curx,x1_,r4				;x dist to ep1
	mul	r24,r3,>>#28,r3
}
{
	push	v6
	sub	dma_ypos,y1_,r5			;y dist to ep1
	mul	r24,r2,>>#28,r2
}
{
	mul	r4,r4,>>#32,r4			;xsquared
	add	r3,temp2,r6
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
	cmp	width,r24
	mul	r5,r5,>>#32,r5			;ysquared
}
{
	add	r2,r6
	jmp	ge,oxout,nop			;outside line width
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
	ld_s	(xy),r2			;get linecolour
	jmp	ge,ep_1,nop				;in endpoint 2 zone (was ge)
}
{
	pop	v6
	jmp	c0ne,pixgen
}	
{
	jmp	wrout
	addm	r1,temp2,temp2
	copy	cosline,r3
}
{
;	mv_s	r23,r2
	st_s	r2,(uv)
;	addr	#1,ru
	addr	#(1<<16),ru
	dec	rc0
	subm	r0,r24,r24
	add	r1,curx
}
;	pop	v5
	nop
ep_1:

; get here if in endpoint 1 zone

;	jmp	oxout,nop
	copy	width,r2
	mul	r2,r2,>>#32,r2
	add	r5,r4				;sum of squares of distance to ep1
	cmp	r4,r2
	bra	ge,oxin
	ld_s	(xy),r2
	nop

oxout:

	ld_s	(uv),r2		;usually is uv
;	mv_s	#$ff00ff00,r2
oxin:
	pop	v6
	nop
{
	jmp	c0ne,pixgen
	sub	r0,r24
	addm	r1,temp2,temp2
}
{
	st_s	r2,(uv)
;	addr #1,ru
	addr	#(1<<16),ru
	add	r1,curx
}
{
;	mv_s	r23,r2
	dec	rc0
	copy	cosline,r3
}
;	pop	v5

