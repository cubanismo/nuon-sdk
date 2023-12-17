
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

;
; pixel gen code for fat antialiased
; translucent lines with colour interpolation

aaline5:

	st_s	dma_len,rc0			;init pixgen counter
{
	push	v6
	copy	dma_xpos,curx
}
{
	push	v7
	sub	y1_,dma_ypos,r25				;copy for colour lerp
}
    push    v5                      ; free up regs for colour lerp
{
    push    v3
    copy    dma_ypos,r7            ;keep a whole vector for colour lerp
}
{
	btst	#0,edge_swap
;	mv_s	#object+8,r0
;	mv_s	#iv,r0
}
;    ld_v   cinterp,v3
//	mv_s	#cinterp,r30
//	ld_v	(r30),v3			
//	nop								;8/16/98 -TAJ- added this nop to take care of possible MPE Dcache freeze bug
	.if(B==0)
	LOAD Gcinterp, ld_v, cinterp, r12, v3
	.else
	mv_s	#cinterp,r12
	ld_s	(r12),r12
	nop
	ld_v	(r12),v3			
	nop
	.endif								

{
	bra	eq,pgen1
	st_s	#0,rx
}
{
;	st_s	r0,xybase				;colour is here
    copy    r25,r15                 ;Y dist to ep2
}
{
	mv_s	#1,r2
	sub	x1_,curx,r24
	subm	x1_,curx,temp2
}
	mv_s	#-1,r2
	sub	curx,x1_,r24
pgen1:
{
	mul	delta_y,r24,>>#20,r24
}
	mv_s	#$10000,r1
{
    mv_s    r24,r14                 ;raw distances are now in r14/r15
	add	y1_,r24
}
{
;	subm	r24,dma_ypos,r24
	subm	r24,r7,r24
	asr	#4,delta_y,r0
}
	mul	sineline,r24,>>#28,r24			;get perpendicular distance to line
{
;	mv_s	#randy,r28
	mul	sineline,r0,>>#28,r0
	sub	sineline,#0,r23
}
{
	mv_s	cosline,r3
	cmp	#0,delta_x
}
{
;	ld_v	(r28),v7					;get ran# thangs
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

;    ld_s   cs,r22
//	mv_s	#cs,r30
//	ld_s	(r30),r22
	.if(B==0)
	LOAD Gcs, ld_s, cs, r22, r22
	.else
	mv_s	#cs,r22
	ld_s	(r22),r22
	nop
	ld_s	(r22),r22			
	nop
	.endif								
{
    sub curx,x21,r14
    subm r7,y21,r15
}    
    abs r14
    abs r15
    mul r12,r14,>>#15,r14
    mul r13,r15,>>#15,r15
    nop
    add r14,r15


pixgen:					 

{
	mv_s	r23,r2
	sub	curx,x1_,r4				;x dist to ep1
	mul	r24,r6,>>#28,r6
}
{
	push	v6
	sub	r7,y1_,r5			;y dist to ep1
	mul	r24,r2,>>#28,r2
}
;{
;	ld_v	iv0,v7			;get colour increment
//	mv_s	#iv0,r27
	.if(B==0)
	LOAD Giv0, ld_v, iv0, r28, v7
	.else
	mv_s	#iv0,r28
	ld_s	(r28),r28
	nop
	ld_v	(r28),v7			
	nop
	.endif								
{
//	ld_v	(r27),v7
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
;	mul_p   r15,v7,>>#14,v7
	mul_p   r15,v7,>>#30,v7
}
{
	mv_s	#$3fff,r2
	sub	curx,x21,r4
	mul	hyp,r6,>>#16,r6	
}
{
    mv_s    r4,r14
	mul	r4,r4,>>#32,r4
	sub	r7,y21,r5
}
{
	mul	r5,r5,>>#32,r5
	sub	r2,r6,r2
}
{
	jmp	ge,ep_1,nop				;in endpoint 2 zone
    abs r14
}

gopixl:

{
//	ld_v	(r31),v6
    copy    r24,r2
    subm r7,y21,r15
}

;{
;   ld_v    iv1,v6
	.if(B==0)
	LOAD Giv1, ld_v, iv1, r24, v6
	.else
	mv_s	#iv1,r24
	ld_s	(r24),r24
	nop
	ld_v	(r24),v6			
	nop
	.endif
									
//	mv_s	#iv1,r31
    mul r12,r14,>>#15,r14        ;for next line colour interp
{
    add_sv  v6,v7
    mul r13,r15,>>#15,r15        ;for next line colour interp
	ld_p	(uv),v6			;get pixel at dest
}
{
	mul	mix,r2,>>#16,r2
}
	sub_sv	v6,v7
;	mul_p	r2,v7,>>#14,v7
	mul_p	r2,v7,>>#30,v7
{
    mv_s    #$2000000,r27
    add r14,r15
}
{
	pop	v6
	jmp	c0ne,pixgen
	add_sv	v6,v7
}	
{   
	jmp	wrout0
	addm	r1,temp2,temp2
	copy	r3,r6
}
{
	st_pz	v7,(uv)
;	addr	#1,ru
	addr	#(1<<16),ru
	dec	rc0
	subm	r0,r24,r24
	add	r1,curx
}
    nop

ep_1:

; get here if in endpoint 1 zone

	copy	width,r2
{
	mul	r2,r2,>>#32,r2      ;was 32
	sub	curx,x21,r14
}
	add	r5,r4				;sum of squares of distance to ep1
	cmp	r4,r2
	bra	lt,oxout
	abs r14
{
	jsr	sqrt
;    mv_s    #0,r1
}
{
	push	v0
    sub r1,r1
}    
{
	push	v1
	copy	r4,r0
}
{
	jmp	gopixl
	pop	v1
	sub	#16,r1              ;was 16
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
	addr	#(1<<16),ru
	add	r1,curx
}
{
	dec	rc0
	copy	r3,r6
}
wrout0:
    pop v3
    pop v5
	pop	v7
