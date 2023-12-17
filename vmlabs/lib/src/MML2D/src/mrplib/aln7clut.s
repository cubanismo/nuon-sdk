
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

// This code is used in the inner loop of lin7clut.s
// It starts off using a base_color which is the lesser of color0 & color1 at endpoint1. It then changes the
// color of (xi,yi) based on the ff:
// base_color + sqrt[(xi-x1)^2 + (yi-y1)^2] * abs(color0-colori)/sqrt[(x2-x1)^2 + (y2-y1)^2]
// with the exception, that if the point is at an endpoint (the half-circle with radius==0.5*width added to
// both extremities of the line) then it can only be color0 or color1.

    endpt_flag  = r28
    color0      = r29
    cur_len     = r31   // distance from endpoint1

    colori      = r24    
    color1      = r25

aln7clut:

	push	v6

    // test for the "trailing extra pixel"
    btst    #1,flag_extra_dma       // Is the "trailing extra pixel" bit indicator set?
    bra eq,no_trailing_extra,nop    // No
    sub     #1,dma_len,r25          // Yes. So, don't consider that last pixel
    st_s    r25,rc0
    eor     #$2,flag_extra_dma      //    and unset the trailing-pixel bit indicator
	copy	dma_xpos,curx           //    and then set the start of x for this segment
    bra aln7clut_go,nop

no_trailing_extra:

	st_s	dma_len,rc0			    // init pixgen counter
	copy	dma_xpos,curx

    btst    #0,flag_extra_dma       // Is the "leading extra pixel" bit indicator set?
    bra eq,aln7clut_go,nop          // No
    add     #$10000,dma_xpos,curx   // Yes. Skip the first pixel for this segment
	addr #(1<<16),ru                //    and adjust ru
    dec	rc0
    eor     #$1,flag_extra_dma      //    and unset the leading-pixel bit indicator

aln7clut_go:

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
}
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
	subm	r24,r7,r24
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

	.if(B==0)                 // get color0
	LOAD Giv0, ld_s, iv0, color0, color0
	.else
	mv_s	#iv0,color0        
	ld_s	(color0),color0
	nop
	ld_s	(color0),color0			
	nop
	.endif								

{
	mul	r4,r4,>>#32,r4			;xsquared
	add	temp2,r6
}
{
	mul	r6,r6,>>#32,r6
	add	r25,r2
}
// =================  endpoint 1 ==============================
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
//	mul_p   r15,v7,>>#30,v7
}
// ============================================================

    add r4,r5,cur_len

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
// =================  endpoint 2 ==============================
{
	jmp	ge,ep_2,nop				;in endpoint 2 zone
    abs r14
}
// ============================================================

    mv_s   #0,endpt_flag        // Not at an endpoint

gopixl:

{
    subm r7,y21,r15
}


	.if(B==0)                 // get color1
	LOAD Giv1, ld_s, iv1, color1, color1
	.else
	mv_s	#iv1,color1
	ld_s	(color1),color1
	nop
	ld_s	(color1),color1			
	nop
	.endif

// Is this an endpoint?
    and #3,endpt_flag,r27
    bra eq,not_endpoint,nop
    cmp #1,r27
    bra ne,endpoint2,nop
    mv_s    color0,colori   // at endpoint1
    bra store_color,nop

endpoint2:

    mv_s    color1,colori   // at endpoint2
    bra store_color,nop

not_endpoint:

    push v0

    jsr sqrt
    mv_s cur_len,r0
    push v1

    sub #16,r1          
    ls  r1,r0,cur_len        // in 4.28 format

    pop v1
    pop v0

    mul clutToLen,cur_len,>>#44,cur_len   // >>????

    // test if offset is over the limit
    sub color0,color1,r27
    abs r27
    cmp cur_len,r27
    bra gt,negate_sign,nop
    mv_s color1, colori
    bra store_color,nop

negate_sign:   // should offset be subtracted from color_base?
     
    cmp color0, color1
    bra ge,compute_color,nop
    mv_s #-1,r27
    mul r27,cur_len,>>#0,cur_len   // negate offset
    nop
    mv_s cur_len,colori

compute_color:

    add cur_len,color0,colori  

store_color:

    mul r12,r14,>>#15,r14        ;for next line colour interp
{
    mul r13,r15,>>#15,r15        ;for next line colour interp
}

    lsl #24,colori         // shift so data is in bits 31-24, ready for st_b below

    ld_s ru,r27
    nop
    lsr  #16,r27       // get integer part of ru

// ===========  st_b	colori,(uv) ============
// Since st_b is not yet included in the Nuon instruction set,
// this fragment was adapted from code cheerfully provided by Rick Greicar

// colori = new byte value in ld_b position (i.e. data in bits 31-24 and zero in
//  bits 23-0)

//The code takes five ticks:

{
    ld_b (uv),r28            ; load byte that will be overwritten
    and #3,r27            ; mask byte offset within scalar
}
{
    ld_s (uv),r29            ; get current contents (note: ld_s ignores byte offset)
    lsl #log2(8),r27         ; 0 -> 0, 1 -> 8, 2 -> 16, 3 -> 24
}
    eor colori,r28               ; logical diff of new value with old value
    eor r28,>>r27,r29          ; second diff and shift overwrites old with new value (since XOR is associative)
    st_s r29,(uv)            ; same effect as st_b

// =========================================

{
    add r14,r15
	pop	v6
	jmp	c0ne,pixgen
}	
{   
	jmp	wrout0
	addm	r1,temp2,temp2
	copy	r3,r6
}
{
//	st_pz	v7,(uv)
	addr	#(1<<16),ru
	dec	rc0
	subm	r0,r24,r24
	add	r1,curx
}
    nop

; get here if in endpoint 1 zone
ep_1:
    add r4,r5,cur_len
    mv_s   #1,endpt_flag
    bra     ep_proc,nop

; get here if in endpoint 2 zone
ep_2:
    mv_s   #2,endpt_flag

ep_proc:
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
{
	jmp	c0ne,pixgen
	sub	r0,r24
	addm	r1,temp2,temp2
}
{
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
