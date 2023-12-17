
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

;
; pixel gen code for standard solid fat line

aaline1:

	st_s	dma_len,rc0			;init pixgen counter
{
	copy	dma_xpos,curx
	push	v6
}

	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#8,r0

{
	cmp	#0,edge_swap
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
	sub	y1_,dma_ypos,r25				;copy for colour lerp
	add	y1_,r24
	sub	r24,dma_ypos,r24
	asr	#4,delta_y,r0
	mv_s	#$10000,r1
	mul	sineline,r24,>>#28,r24			;get perpendicular distance to line
	mul	sineline,r0,>>#28,r0
	sub	sineline,#0,r23
	cmp	#0,delta_x
;	st_s	#32,acshift
	bra	ne,pixgen
	mul	r2,r0,>>#0,r0
{
	mv_s	r23,r2
	dec	rc0
	copy	cosline,r3
}
//	mv_s	#$40000000,r23
//  TAJ - these 3 lines are for perpendicular lines (same code used in aaline2&3.s):
	sub	curx,x1_,r24
	mv_s	#$10000,r0
	mv_s	#$0000000,r23


pixgen:

	mul	r24,r3,>>#28,r3
{
	push	v6
	abs	r24
	mul	r24,r2,>>#28,r2
}
	add	r3,temp2,r6
{
	mul	r6,r6,>>#32,r6
	add	r25,r2
}
{
	mul	r2,r2,>>#32,r2
	jmp	lt,oxout			;in endpoint 1 zone
	cmp	width,r24
}
	nop
{
	add	r2,r6
	jmp	ge,oxout,nop
}
	mul	hyp,r6,>>#4,r6	
	mv_s	#$3ffffff,r7
	sub	r7,r6,r7
{
	ld_p	(xy),v1			;get linecolour
	jmp	ge,oxout,nop
}
{
	pop	v6
	jmp	c0ne,pixgen
}	
{
//	jmp	wrout
	st_p	v1,(uv)
//	addr	#1,ru
	addr #(1<<16),ru
	addm	r1,temp2,temp2
}
{
	mv_s	r23,r2
	dec	rc0
	subm	r0,r24,r24
	copy	cosline,r3
}
	jmp	wrout, nop



oxout:

	pop	v6
	ld_p	(uv),v1		;usually is uv

{
	jmp	c0ne,pixgen
;	add	#1,>>#-16,curx
	sub	r0,r24
	addm	r1,temp2,temp2
}
{
	st_p	v1,(uv)
//	addr #1,ru
	addr #(1<<16),ru
}
{
	mv_s	r23,r2
	dec	rc0
	copy	cosline,r3
}


