
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


; pixel gen code for the full monty - fat antialiased
; translucent lines

// This code is used in the inner loop of lin3clut.s

aln3clut:
	push	v6

    btst    #1,flag_extra_dma       // Is the "trailing extra pixel" bit indicator set?
    bra eq,no_trailing_extra,nop    // No
    sub     #1,dma_len,r25          // Yes. So, don't consider that last pixel
    st_s    r25,rc0
    eor     #$2,flag_extra_dma      //    and unset the trailing-pixel bit indicator
	copy	dma_xpos,curx           //    and then set the start of x for this segment
    bra aln3clut_go,nop

no_trailing_extra:

	st_s	dma_len,rc0			    // init pixgen counter
	copy	dma_xpos,curx

    btst    #0,flag_extra_dma       // Is the "leading extra pixel" bit indicator set?
    bra eq,aln3clut_go,nop          // No
    add     #$10000,dma_xpos,curx   // Yes. Skip the first pixel for this segment
	addr #(1<<16),ru                //    and adjust ru
    dec	rc0
    eor     #$1,flag_extra_dma      //    and unset the leading-pixel bit indicator


aln3clut_go:

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
}
{
	ld_s (r0),r31				// get color
}
	bra	eq,pgen1
    lsr #8,r31                // shift out blending value in first byte of color
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
{
	mv_s	cosline,r3
	cmp	#0,delta_x
}
{
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
    push    v6
	sub	dma_ypos,y1_,r5			;y dist to ep1
	mul	r24,r2,>>#28,r2
}
{
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
    sub r24,width,r24
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

//  compute right color index: BaseColorIndex + clutToWidth*(Perpendicular Distance to Line)

    sub r24,width,r2
    mul clutToWidth,r2,>>#28,r2 // shift out fractional part of clutToWidth (>>28)
    nop
    add #$8000,r2      // round off the integer part
    lsr #16,r2
    nop
    add r31,r2         // add BaseColorIndex

    lsl #24,r2         // shift so data is in bits 31-24, ready for st_b below

    ld_s ru,r26
    nop
    lsr  #16,r26       // get integer part of ru

// ===========  st_b	r2,(uv) ============
// Since st_b is not yet included in the Nuon instruction set,
// this fragment was adapted from code cheerfully provided by Rick Greicar

//r2 = new byte value in ld_b position (i.e. data in bits 31-24 and zero in
//  bits 23-0)

//The code takes five ticks:

{
    ld_b (uv),r28            ; load byte that will be overwritten
    and #3,r26            ; mask byte offset within scalar
}
{
    ld_s (uv),r29            ; get current contents (note: ld_s ignores byte offset)
    lsl #log2(8),r26         ; 0 -> 0, 1 -> 8, 2 -> 16, 3 -> 24
}
    eor r2,r28               ; logical diff of new value with old value
    eor r28,>>r26,r29          ; second diff and shift overwrites old with new value (since XOR is associative)
    st_s r29,(uv)            ; same effect as st_b

// =========================================

{
    pop v6
	jmp	c0ne,pixgen
}	
{
	jmp	wrout
	addm	r1,temp2,temp2
	copy	r3,r6
}
{
//	st_s	r29,(uv)
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
	bra	lt,oxout            // if distance from first endpoint is greater than width, then don't write pixel
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
{
	jmp	c0ne,pixgen
	sub	r0,r24
	addm	r1,temp2,temp2
}
{
	addr #(1<<16),ru
	add	r1,curx
}
{
	dec	rc0
	copy	r3,r6
}
	pop	v7
