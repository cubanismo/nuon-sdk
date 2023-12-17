
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


//	_draw_line1(environs, paramBlockP, 0, 0);
//	r0 = environment data
//	r1 = pointer to parameter block
//	r2 = unused
//	r3 = unused

	.include "mrp.i"

;==============================================================
	.segment	data
	.align.v
;==============================================================

	dest: .dc.s 0
	dmaFlags: .dc.s 0
	xHiLoClip: .dc.s 0
	yHiLoClip: .dc.s 0
	rzinfVar: .dc.s 0
	object: .dc.s 0
	pline_ptr: .dc.s 0
	cs: .dc.s 0
	cinterp: .dc.s 0
	iv0: .dc.s 0
	iv1: .dc.s 0
	pline: .dc.s 0
	trig: .dc.s 0
	max_x: .dc.s 0
	randy: .dc.s 0
	genbuf:	  .dc.s 0

LeftDmaActive = 4


;==============================================================
	.segment	text
	.align.v
;==============================================================
escapes:

; list of routines for escape codes

    .dc.s   setwidth    ;change line width
    .dc.s   line_exit   ;terminate polyline
    .dc.s   line_break  ;polyline discontinuity
    .dc.s   set_col1    ;set main line colour
    .dc.s   set_2col    ;set both main and secondary colour
    .dc.s   setblend    ;change line blend

;===================================
	.export		_draw_line1
	.import		dma__cmd
	.import		odma_wtrd
	.import		odmacmd

;===================================
;	Variables
;===================================
// Offset in bytes from start of parameter block

szLong = 4		// size of long

destOf		= 0 * szLong
dmaFlagsOf	= 1 * szLong
xHiLoClipOf	= 2 * szLong
yHiLoClipOf	= 3 * szLong
//dest:			.dc.s	0			;Address
//dmaFlags:		.dc.s   0			
//xHiLoClip:	.dc.s	0			;X hi:lo clip
//yHiLoClip:	.dc.s	0			;Y hi:lo clip
Gdest		= _FALSE	// global storage flag  
GdmaFlags	= _FALSE	// global storage flag 
GxHiLoClip	= _FALSE	// global storage flag 
GyHiLoClip	= _FALSE	// global storage flag 


rzinfOf		= 4 * szLong
//rzinf:		.dc.s	0
//				.dc.s	0			;Size of render zones
//				.dc.s	0			;Total number of MPEs
//				.dc.s	0			;to keep vect align
Grzinf		= _FALSE	// global storage flag 


objectOf	= 8 * szLong
//object:		.dc.s	0			;x1_:y1_ (or centre position, for polyline) 
//				.dc.s	0     		;x2_:y2_
//				.dc.s	0			;packed colour 1
//				.dc.s	0			;packed colour 2


//				.dc.s	0			;packed scales x:y (polyline)
//				.dc.s	0			;Translucency/endpoint radius (radius in low 8 bits)
//				.dc.s	0			;Rotate angle (polyline)
//				.dc.s 	0			;Address of polyline list in external RAM (0 if not a polyline)
Gobject		= _FALSE	// global storage flag 
szobject	= 8

pline_ptrOf		= objectOf + (szobject * szLong)
csOf			= pline_ptrOf + szLong
cinterpOf		= csOf + (3 * szLong)
//pline_ptr:	.dc.s   0
//cs:			.dc.s   0,0,0
//cinterp:		.dc.s   0,0,0,0			//won't work with cs+4!  WTFIGO??
Gpline_ptr	= _FALSE	// global storage flag 
Gcs			= _FALSE	// global storage flag 
Gcinterp	= _FALSE	// global storage flag 


iv0Of			= cinterpOf + (4 * szLong)
iv1Of			= iv0Of + (4 * szLong)
//iv0:			.dc.s   0,0,0,0
//iv1:			.dc.s   0,0,0,0
Giv0		= _FALSE	// global storage flag 
Giv1		= _FALSE	// global storage flag 


plineOf			= iv1Of + (4 * szLong)
//pline:		.ds.s	_POLYLINE_PTS	//polyline table - 32 longs		
Gpline		= _FALSE	// global storage flag 

trigOf			= plineOf + ((_POLYLINE_PTS + 4 ) * szLong)
								// NOTE: 02 Nov 98 - Added 4 to be able to use new odma_wtrd which works
								// around Other Bus DMA bug
max_xOf			= trigOf + (4 * szLong)
//trig:			.dc.s   0,0,0,0     ;vector for storing trig
//max_x:		.dc.s   0,0,0,0
Gtrig		= _FALSE	// global storage flag 
Gmax_x		= _FALSE	// global storage flag 


randyOf			= max_xOf + (4 * szLong)
//randy:		.ds.s	4
Grandy		= _FALSE	// global storage flag

;============================================

dma__cmdAddrOf		= randyOf + (4 * szLong)
//dma__cmd:		.dc.s   0,0,0,0,0,0,0,0

odmacmdAddrOf		= dma__cmdAddrOf + (1 * szLong)
//odmacmd:		.dc.s   0,0,0,0

genbufAddrOf		= odmacmdAddrOf + (1 * szLong)
//genbuf:		.ds.s   128           

;============================================

_TRUE = 1
_FALSE = 0
B = 0
dma_base_offset = _SHFT_DMA_BUFFSIZE             // This is used by buffoff to toggle the address offset from
                                // dma_base so that it effectively becomes a dual buffer
                                // The rule is: (2*(2^dma_base_offset)) <= sizeof( genbuf[] )


	NumPts	= _POLYLINE_PTS		//Number of Points to dma-read per sweep
	buffsize = _DMA_BUFFSIZE
//	parSizeLongs = 76
	
	BitRead = 13
;
; register aliases

	mline = r7			;Multi line stuff
	firstpoint = r6

	x1_ = r8
	y1_ = r9
	x2_ = r10
   	y2_ = r11			;Line endpoints
	width = r26			;Line thickness
	delta_x = r16
	delta_y	= r17		;Deltas for linedraw
	outercounter = r19	;Outer loop counter
	x21 = r20
	y21 = r21			;Copy of second endpoint

	z1 = r23			;zone 1 counter
	z2 = r25			;zone 2 counter
	sineline = r28		;sin of the angle of the line wrt x-axis
	cosline = r29		;cosin of the angle
	k = r28
	hyp = r18
	curx = r27
	edge_swap = r22			;Miraculously, a register is free

	temp1 = r30
	erad = r29			;Endpoint radius (squared)
	buffoff = r27
	mix = r11
	temp2 = r19

	_ranmsk = r28	;mask for pseudo random seq gen
	_ranseed = r29	;seed for above

	dmastuff = v3
;	dma_count = r14
	dma_len = r14
	dma_base = r15
 	dma_xpos = r12
 	dma_ypos = r13

; clip thangs

	clipwindow = v1
	cliptop = r5
	clipleft = r4
	clipright = r6
	clipbottom = r7

;===================================
;	Macros
;===================================

	.include "macros1.i"

;============================================================

; NOTE: TAJ - 08/12/98 - Used mostly r30 & r31 for temporary storage for transforming ld_* and st_* instructions -
;						 Data will be stored in cache and accessed from external ram.
						 
;============================================================
	.segment text
;============================================================

; draw_line: draw fat neon antialiased line

_draw_line1:
	sub		#16, r31
{	st_v	v7,(r31)	
	sub		#16, r31
}
{	st_v	v6,(r31)	
	sub		#16, r31
}
{	st_v	v5,(r31)	
	sub		#16, r31
}
{	st_v	v4,(r31)	
	sub		#16, r31
}
	st_v	v3,(r31)	
	mv_s	r31,r10
	push	v2, rz

;-----------------------------------------------------------------
; compute addresses of variable labels based on param block address
;-----------------------------------------------------------------
	.if(Gdest == _FALSE)
	setParamAddr	destOf, dest
	.endif

	.if(GdmaFlags == _FALSE)
	setParamAddr	dmaFlagsOf, dmaFlags
	.endif

	.if(GxHiLoClip == _FALSE)
	setParamAddr	xHiLoClipOf, xHiLoClip
	.endif

	.if(GyHiLoClip == _FALSE)
	setParamAddr	yHiLoClipOf, yHiLoClip
	.endif

	.if(Grzinf == _FALSE)
	setParamAddr	rzinfOf, rzinfVar
	.endif

	.if(Gobject == _FALSE)
	setParamAddr	objectOf, object
	.endif

	.if(Gpline_ptr == _FALSE)
	setParamAddr	pline_ptrOf, pline_ptr
	.endif

	.if(Gcs == _FALSE)
	setParamAddr	csOf, cs
	.endif

	.if(Gcinterp == _FALSE)
	setParamAddr	cinterpOf, cinterp
	.endif

	.if(Giv0 == _FALSE)
	setParamAddr	iv0Of, iv0
	.endif

	.if(Giv1 == _FALSE)
	setParamAddr	iv1Of, iv1
	.endif

	.if(Gpline == _FALSE)
	setParamAddr	plineOf, pline
	.endif

	.if(Gtrig == _FALSE)
	setParamAddr	trigOf, trig
	.endif

	.if(Gmax_x == _FALSE)
	setParamAddr	max_xOf, max_x
	.endif

	.if(Grandy == _FALSE)
	setParamAddr	randyOf, randy
	.endif

mrpbuffers:
//	store paramBlockP->dma__cmdAddr in global dma__cmd variable
	add		#dma__cmdAddrOf, r1, r4
	mv_s	#dma__cmd, r5
	ld_io	(r4), r6
	nop
	st_io	r6, (r5)	

//	store paramBlockP->odmacmdAddr in global odmacmd variable
	add		#odmacmdAddrOf, r1, r4
	mv_s	#odmacmd, r5
	ld_io	(r4), r6
	nop
	st_io	r6, (r5)	

//	store paramBlockP->genbufAddr in global genbuf variable
	add		#genbufAddrOf, r1, r4
	mv_s	#genbuf, r5
	ld_s	(r4), r6
	nop
	st_s	r6, (r5)	


; assumes we have a line type object loaded at (object)

draw_line_go:

; check to see if it is polyline.  If it is, load in sine table, get sincos, and
; merge in scales; then store the vector at trig, for use in the routine.
	ld_io	mdmactl,r0
	nop
	jsr	dma_finished,nop		;don't clobber anything that's running!
//	mv_s	#object+28,r0		;this is nonzero if it's gonna be polyline.
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#28,r0

	ld_s	(r0),r1
	nop


	cmp	#0,r1
	bra	eq,notpolyline,nop		;no need to gen a trig vector if not polyline.

; it is polyline....

//	mv_s	#object+16,r0
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#16,r0

{
	ld_s	(r0),r17		;pick up scales
	add	#8,r0
}
	ld_s	(r0),r0			;pick up rotate angle
	jsr	sincos				;get sincos...
	copy r0,r0				;flags need set
	nop
{
	mv_s	r0,r20
	copy	r0,r23
}
{
	mv_s	r1,r22
	sub	r1,#0,r21			;ready for rotation
}

; now figure in the scales...

	lsl	#16,r17,r0			;extract y-scale...
	asr	#8,r17
	asr	#8,r0				;extracted and sign-extended
	mul	r17,r20,>>#16,r20
	mul	r0,r21,>>#16,r21
	mul	r17,r22,>>#16,r22
	mul	r0,r23,>>#16,r23	;merge with the rot8 stuff

; and now write the vector to trig



//	mv_s	#trig,r0
//	st_v	v5,(r0)
	.if(B==0)
	STORE	Gtrig, st_v, trig, v5, r0
	.else
	mv_s	#trig,r0		//STOREIndirectDtram
	ld_s	(r0),r0
	nop
	st_v	v5,(r0)
	.endif

	mv_s	#$a3000000,_ranmsk		;for pseudo random seq gen
	mv_s	#$baabaaaa,_ranseed		;seed - mess with this


notpolyline:	


//	mv_s	#object,r0			;address in local ram 
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
{
	ld_v	(r0),v1			;pick up first vector of info
	add	#16,r0				;point at translucency (mix)
}
	ld_v	(r0),v3			;pick up second vector
	sub	r2,r2				;for r->r xfers
pip:

	mv_s	#$ffff,r1		;mask for extracting stuff

	copy	r15,mline		;move this and test for multiline...

	jmp	eq,line_go			;skip multiline code
	lsr	#2,r13,r31			;extract xlucency value to 2:30
	and	r1,r13,width			;extract width

;polyline comes thru here - pick up the external vectorlist
;-----------------------------------------------
;use other bus
	push	v1
	push	v7
	mv_s	#NumPts, r4
	mv_s	mline,r5		;set external address of poly line object
	mv_s	#pline, r6		;where to read it to
	ld_s	(r6), r6
	nop

	mv_s	#2, r7

{	jsr		odma_wtrd,nop
	ld_io	pcexec, r31
}
;wait for points to be loaded
`loop1:
	ld_io	odmactl, r30
	nop
	bits	#LeftDmaActive, >>#0, r30
	bra	ne, `loop1, nop
;-----------------------------------------------
// use main bus
/*	jsr	dma_finished		;wait for dma safe
	mv_s	mline,r1		;set external address of poly line object
	ld_io	mdmactl,r0	
;    nop
	jsr	dma_read
	mv_s	#pline,r2		;where to read it to
	mv_s	#32,r0			;length in longs
	jsr	dma_finished		;wait for dma complete
	ld_io	mdmactl,r0	
	add #128,mline          ;update external pointer
*/

//  st_s    mline,pline_ptr     ;save external pointer
	
//	add #(NumPts<<2),mline          ;update external pointer,
									; NOTE: r5 has been incremented after odma_wtrd
	.if(B==0)
	STORE	Gpline_ptr, st_s, pline_ptr, r5, mline
	.else
	mv_s	#pline_ptr,mline		//STOREIndirectDtram
	ld_s	(mline),mline
	nop
	st_s	r5,(mline)
	.endif

	pop		v1
	nop
//	mv_s	#pline,mline		;Set mline pointer
	mv_s	#pline,mline		;Set mline pointer
	ld_s	(mline),mline
	nop
	st_io    #NumPts,rc0         ;use counter to trigger loading of longer pline list

	pop		v7
	nop


;*** Multiple line stuff/re-entry point ***

poly_line:

//	mv_s	#object+20,r0
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#20,r0

	ld_s	(r0),width				;get back thickness and width that were mashed
	nop
	lsr	#2,width,r31
	bits	#7,>>#0,width


abreak:

    mv_s    #$80808080,r6
    copy    r6,r5

getpoints:

{	
	ld_s	(mline),r4
;	add	#4,mline
;    dec rc0
}
;    jsr c0eq,loadmore,nop   ;load more polyline data if necessary
    nop
{
    lsr #16,r4,r0
    mv_s    #$8000,r1
}    
;    cmp #0,r4

    cmp r1,r0
{
    jmp eq,do_escape,nop    ;zero means an ESC sequence
;    lsr #16,r4,r0           ;extract y to check for an esc code
}
done_escape:
    
    cmp r6,r5               ;nonzero if previous point collected
    jmp ne,gotpoints,nop
    
; still picking up points, so loop back
{
    add #4,mline
    dec rc0
}
    jsr c0eq,loadmore,nop
    bra getpoints
    mv_s    r4,r5
    nop

gotpoints:
 
; got both points, if we get here

    jmp line_scale
{
    mv_s    r4,r5
    copy    r5,r4
}
    nop
    

; deffo a command...

do_escape:

;{
;    add #4,mline
;    dec rc0
;}
;    jsr c0eq,loadmore,nop   ;load more polyline if needed
;    ld_s    (mline),r4
    bits    #15,>>#0,r4
{
    add #4,mline
    dec rc0
}
    jsr c0eq,loadmore,nop   ;load more polyline if needed

    
; handle escape sequences

{
    lsl #2,r4               ;make word index
    mv_s    #escapes,r0     ;base of escapes jump table
}
    add r0,r4
    ld_s    (r4),r4         ;get escape routine address    
    nop
    jmp (r4),nop            ;jump to escape routine

line_break:

; esc routine for a polyline discontinuity

    jmp abreak,nop
   

set_2col:

; esc routine to set both main and secondary colour

//	mv_s    #object+12,r0
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#12,r0

    ld_s    (mline),r4
    nop
    st_s    r4,(r0)         ;set secondary colour
    
{
    add #4,mline
    dec rc0
}
    jsr c0eq,loadmore,nop
    
; then fall through to set_col1 to set the main colour

set_col1:

; esc routine to set the main line colour

//	mv_s    #object+8,r0
	mv_s	#object,r0

	ld_s	(r0),r0
	nop
	add		#8,r0
//.export _prevent_optimise
//_prevent_optimise:
    ld_s    (mline),r4      ;fetch the colour
    nop
    st_s    r4,(r0)         ;put colour in the object

esc_cont:

; continue after an escape sequence

{
    add #4,mline
    dec rc0
}
    jsr c0eq,loadmore,nop   ;load more polyline if needed
    bra getpoints,nop

esc_cont_break:

; continue after an escape sequence, generating a line break, too

{
    add #4,mline
    dec rc0
}
    jsr c0eq,loadmore,nop   ;load more polyline if needed
    bra poly_line,nop           ;continue



setwidth:

; set a new line width

  

;	ld_s    object+20,r0    ;get existing width
	mv_s	#object,r30
	ld_s	(r30),r30
	nop
	add		#20,r30
	ld_s	(r30),r0		// r30 contains #object+20
		
    ld_s    (mline),r4      ;get new width  
    lsr #16,r0              ;kill old width
    lsl #16,r0              ;open a hole
    bra esc_cont_break      ;go and continue
    or r0,r4                ;drop in new width
;	st_s    r4,object+20    ;set it
	st_s	r4,(r30)

setblend:

; set a new line blend

;    ld_s   object+20,r0    ;get existing blend
	mv_s	#object,r30
	ld_s	(r30),r30
	nop
	add		#20,r30
	ld_s	(r30),r0		// r30 contains #object+20
		
    ld_s    (mline),r4      ;get new blend  
    bits    #15,>>#0,r0     ;kill old blend
    lsl #16,r4              ;new blend to right place
    bra esc_cont_break      ;go and continue
    or r0,r4                ;drop in new blend
;    st_s    r4,object+20    ;set it
	st_s	r4,(r30)


line_scale:

; For polyline, we are gonna allow rotation and scaling of the line
; segment, since we now have oodles of IRAM :-)


//	mv_s	#object,r0
	mv_s	#object,r0
	ld_s	(r0),r0
	nop

{
	ld_s	(r0),r16		;pick up positional X and Y
	add	#16,r0
}
	nop
//	mv_s	#trig,r1
//	ld_v	(r1),v5			;pick up precalculated trig
	.if(B==0)
	LOAD Gtrig, ld_v, trig, r1, v5
	.else
	mv_s	#trig,r1	//LOADIndirectDtram
	ld_s	(r1),r1
	nop
	ld_v	(r1),v5
	nop
	.endif


bingo:


; now extract co-ords, as per usual...

	sub	r2,r2				;for r->r xfers
{
	mv_s	r4,x1_
	addm r5,r2,y2_			;copy second co-ord pair
	asr	#16,r4,y1_				;extract x1_
}
{
	mv_s	y2_,x2_
	lsl	#16,x1_				;ready for sign extend/extract y1_
}
{
	push	v1				;save the polyline info
	lsl	#16,x2_
}
{
	asr	#16,y2_				;extract x2_
}
	st_io	#0,ru
	st_io	#0,rv
	asr	#16,x1_
	asr	#16,x2_				;complete sign extrension of y co-ords

;	bra	nmath,nop

; now rotate the co-ords...


{
	mv_s	y1_,r1
	copy	x1_,r0
}
	mul	r22,x1_,>>#14,x1_
	mul	r23,y1_,>>#14,y1_
	mul	r20,r0,>>#14,r0
	mul	r21,r1,>>#14,r1
	add	x1_,y1_
	add	r0,r1,x1_
{
	mv_s	y2_,r1
	copy	x2_,r0
}
	mul	r22,x2_,>>#14,x2_
	mul	r23,y2_,>>#14,y2_
	mul	r20,r0,>>#14,r0
	mul	r21,r1,>>#14,r1
	add	x2_,y2_
	add	r0,r1,x2_

    jsr round
{
    mv_s    x1_,r0
    copy    x1_,r1
}
    abs r0
{
    mv_s    r0,x1_
    jsr round
}
{
    mv_s    x2_,r0
    copy    x2_,r1
}
    abs r0
{
    mv_s    r0,x2_
    jsr round
}
{
    mv_s    y1_,r0
    copy    y1_,r1
}
    abs r0
{
    mv_s    r0,y1_
    jsr round
}
{
    mv_s    y2_,r0
    copy    y2_,r1
}
    abs r0
    mv_s    r0,y2_

nmath:

; finally, centre them...

	lsl	#16,r16,r17
	asr	#16,r16
{
	jmp	rejoin			;go rejoin standard linedraw mode
	asr	#16,r17
}	
{
	add	r16,x1_
	addm	r16,x2_,x2_
}
{
	add	r17,y1_
	addm	r17,y2_,y2_
}



; here is standard (single) line draw stuff


line_go:

{
	mv_s	r4,y1_
	addm r5,r2,y2_			;copy second co-ord pair
	asr	#16,r4,x1_				;extract x1_
}
{
	mv_s	y2_,x2_
	lsl	#16,y1_				;ready for sign extend/extract y1_
}
{
	push	v1				;save the polyline info
	lsl	#16,y2_
}
{
	asr	#16,x2_				;extract x2_
}
	st_s	#0,ru
	st_s	#0,rv
	asr	#16,y1_
	asr	#16,y2_				;complete sign extrension of y co-ords

rejoin:

; get endpoints in low-to-high Y order


{
	st_s	#0,acshift		;init this to 0
	cmp	y1_,y2_			;y1_ lower?
	subm	edge_swap,edge_swap,edge_swap
}
{
    mv_s    #0,r3
	bra	ge,y1_less		;yup, do not swap endpoints
	sub	temp1,temp1		;zero this for register move purposes
}
	asl	#1,width,z1		;save a copy of the endpoint radius
	nop
{
	mv_s	x1_,x2_
	copy	x2_,x1_		;swap x
}
{
	mv_s	y1_,y2_
	copy	y2_,y1_		;swap y
}
    add #1,r3           ;nonzero to set up colours in reverse order

y1_less:


; allow no zero delta

    sub y1_,y2_,delta_y
    bra ne,x_val
    sub x1_,x2_,delta_x
    bra ne,x_val,nop
    mv_s    #2,delta_y    
    mv_s    #2,delta_x        

x_val:




;    st_s    r0,cs       ;non0 means to swap colours on interpolated lines

{
	mv_s	x2_,x21
	asl	#16,y2_,y21
}

; get total deltas, set vertical counter, get 1/deltas

{
	asl	#16,x21
}
{
	subm		y1_,y2_,delta_y		;get total y delta
	sub	x1_,x2_,delta_x				;get total x delta
}



	bra	ge,neswap
	add	width,x2_,r0					;get max boundary
{
//	mv_s	#max_x,r1				// TAJ - moved below
	lsl	#16,r0						;make it good format for ez checking
}

	sub	width,x2_,r0
	bset	#0,edge_swap
	lsl	#16,r0

neswap:

; new code to support colour interpolation linestyles

    push    v0
    push    v1
    push    v3              ;need reggies

	mv_s	#($10400000|buffsize),r2	
    st_s    r2,linpixctl

//	mv_s    #object+8,r0
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#8,r0

{
    ld_pz    (r0),v1         ;get colour 1
    add #4,r0
}
{
    ld_pz    (r0),v3         ;get colour 2
    cmp #0,r3               ;contains nonzero if colours are to be swapped
}
    jmp eq,no_colour_swap,nop
    mv_v    v1,v3
    ld_pz    (r0),v1
    nop
no_colour_swap:

    sub_sv  v1,v3

;    st_v    v3,iv0
//	mv_s	#iv0,r30
//	st_v	v3,(r30)
	.if(B==0)
	STORE	Giv0, st_v, iv0, v3, r30
	.else
	mv_s	#iv0,r30		//STOREIndirectDtram
	ld_s	(r30),r30
	nop
	st_v	v3,(r30)
	.endif


;    st_v    v1,iv1
//	mv_s	#iv1,r30
//	st_v	v1,(r30)
	.if(B==0)
	STORE	Giv1, st_v, iv1, v1, r30
	.else
	mv_s	#iv1,r30		//STOREIndirectDtram
	ld_s	(r30),r30
	nop
	st_v	v1,(r30)
	.endif
    
    copy    delta_x,r14

    abs r14                 ;force to positive for test
{
    sub r12,r12
    mv_s    #0,r13          ;zero both
}
    cmp r14,delta_y
    jmp gt,y_dominant,nop
    copy    r14,r0
    jsr ne,recip
    sub r1,r1
    nop
    bra cdelta_done
    sub #29,r1
    ls  r1,r0,r12
y_dominant:
    copy    delta_y,r0
    jsr ne,recip
    sub r1,r1
    nop
    sub #29,r1
    ls  r1,r0,r13
 cdelta_done:
;   st_v    v3,cinterp
//	mv_s	#cinterp,r30
//	st_v	v3,(r30)
	.if(B==0)
	STORE	Gcinterp, st_v, cinterp, v3, r30
	.else
	mv_s	#cinterp,r30		//STOREIndirectDtram
	ld_s	(r30),r30
	nop
	st_v	v3,(r30)
	.endif

    pop v3
    pop v1
    pop v0
    nop
    

//	mv_s	#max_x,r1				// TAJ - moved here to make it coherent with STORE macro
	.if(B==0)
	STORE	Gmax_x, st_s, max_x, r0, r1
	.else
	mv_s	#max_x,r1		//STOREIndirectDtram
	ld_s	(r1),r1
	nop
	st_s	r0,(r1)
	.endif
{
//	st_s	r0,(r1)					//store max_x
	cmp	#0,delta_y
}
{
	bra	eq,nrecip1
	mv_s	#1,z2
}
{
	mv_s	#$40000000,r0	
}
{
	mv_s	#0,r1
	jsr	recip						;get 1/dy
}	
	mv_s	delta_y,r0
	sub	#1,z2
	sub	#30,r1						;return 30 bits of frac
	ls	r1,r0

nrecip1:

	mv_s	delta_y,outercounter	;raw scan line count
{
	mv_s	r0,r2					;save 1/dy
	mul	delta_x,r0,>>#14,r0			;get dx/dy as a 16:16 fraction
}
{
	mul	delta_x,delta_x,>>acshift,hyp		;collect x**2 in hyp
	add	delta_y,z2
}
	
{
	mv_s	delta_y,temp1			;save a copy of delta y
	mul	delta_y,delta_y,>>acshift,dma_xpos	;generate y**2 in dma_xpos
}
{
	mv_s	r2,delta_y
}
{
	addm	dma_xpos,hyp,hyp		;hyp contains x**2+y**2
}
{
	mv_s	r0,delta_x
	copy	delta_x,dma_xpos		;using dma_xpos as a temp1
}
{
	mv_s	#0,r1					;no fracbitz
	jsr	rsqrt,nop					;call recip sqrt
	copy	hyp,r0					;prep 4 sqrt
}

	sub	#28,r1						;wanna get frac
	ls	r1,r0,sineline						;r0 contains the llength of the lline, 16:16
	mv_s	sineline,cosline		;the cosine will be useful too
{
	mul	dma_xpos,sineline,>>#0,sineline	;this is sin of the line
	copy	dma_xpos,r0
}
{
	mv_s	#0,r1
	mul	temp1,cosline,>>#0,cosline	;and this is the cosine
	jsr	recip,nop
	abs	r0
}
	sub	#20,r1
	ls	r1,r0
{
	mv_s	r31,mix
	mul	r0,temp1,>>acshift,delta_y		;Y inc per X step 
	copy	width,r0
}
{
	mv_s	#0,r1				;zero fracbits
	jsr	recip,nop				;go get 1/width
}
	sub	#16,r1
	ls	r1,r0
	mul	r0,mix,>>#16,mix		;this is the final mix value	
	cmp	#0,delta_y
	jmp	ne,nzro
	add	width,outercounter
	add	width,outercounter
{
	mv_s	#$10000000,sineline	;this hack fixes inaccuracy that screws up lines with zero slope
	or	#1,<>#-8,delta_y				;purely a cheat hack to prevent anomalies on horizontal lines
}
	btst	#0,edge_swap
	bra	eq,nzro
	nop
	nop
	neg	sineline

nzro:
	cmp	#0,delta_x
	jmp	ne,nzro2,nop
{
	mv_s	#$10000000,cosline
}
nzro2:



x_posit:

;
; got scanline deltas, got origin point, set up to do our thang

	asl	#16,width
	asl	#16,x1_,dma_xpos
{
	mv_s	hyp,r0
	jsr	recip					;get 1/h^2
	asl	#16,y1_,dma_ypos				;set up initial dma positions
}
	mv_s	#0,r1				;getting 1/hsquared
	nop
	sub	#30,r1
	ls	r1,r0,hyp			;this is 1/hsquared as a 2:30 number

; offset edges according to the angle of the line

	mv_s	sineline,r1
	copy	cosline,r0
;	abs	r0
	abs	r1

	mul	width,r0,>>#27,r0		;was 27
	mul	width,r1,>>#27,r1		;was 27
	nop
	add	r0,r1,r2
	lsr	#1,r2
    add #1,>>#-16,r2            ;take ceil


	btst	#0,edge_swap
	bra	eq,std_orient
	nop
	nop

	add	r2,dma_xpos,x2_
	bra	nesw
;    add width,dma_xpos,x2_
    sub width,dma_ypos
;	sub	r2,dma_ypos
	sub	r0,x2_,dma_xpos


std_orient:

	sub	width,dma_xpos
	sub	width,dma_ypos
	add	r0,dma_xpos,x2_
nesw:

    
	lsr	#16,r1,z1
	lsr	#16,r0
    add #1,z1
;
; primary position to 16:16

	asl	#16,x1_
	asl	#16,y1_	
	
;
; set up dma and xy_ctl


	jsr	dma_wait					;wait for DMA able to accept cmds
	ld_io	mdmactl,r0
	nop
//	mv_s	#(dma__cmd+4),r1
	mv_s	#dma__cmd,r1
	ld_io	(r1),r1
	nop
	add		#4,r1


//	mv_s	#dest,r0				;address of dest screen ptr in param block
//	ld_s	(r0),r0					;(I know, I know, I should make it relative to a specified base - later)
//	nop
	.if(B==0)
	LOAD	Gdest, ld_s, dest, r0, r0
	.else
	mv_s	#dest,r0	//LOADIndirectDtram
	ld_s	(r0),r0
	nop
	ld_s	(r0),r0
	nop
	.endif

	st_s	r0,(r1)

	mv_s	#($10400000|buffsize),r2			;Width = cacheSize; use ch_norm; pixmap 4	
	st_io	r2,(xyctl)
	st_io	r2,(uvctl)

//	mv_s	#genbuf,dma_base
	mv_s	#genbuf,dma_base
	ld_s	(dma_base),dma_base
	nop

	mv_s	dma_base,r0
	st_io	r0,uvbase			;set up XY
	st_io	#0,ry
	st_io	#0,rv
	jsr	update_edges
	nop
	nop

; Multi-MPE stuff setup and outer loop is here

mpe_num = r4				;Stuff for multi-MPE slicing up.
slice_size = r5
total_mpes = r6
slice_count = r7
y__lo = r0
y__hi = r1
chunk_size = r2
slice_offset = r3

mmpe0:

//	mv_s	#rzinf,r0			;point at render zone info
//	ld_v	(r0),v1				;get split width and MPE-#
	.if(B==0)
	LOAD Grzinf, ld_v, rzinfVar, r0, v1
	.else
	mv_s	#rzinfVar,r0	//LOADIndirectDtram
	ld_s	(r0),r0
	nop
	ld_v	(r0),v1
	nop
	.endif
		
//	sub	#4,r0					;point at Y clip info
	.if(B==0)
	LOAD GyHiLoClip, ld_s, yHiLoClip, r0, r0	
	.else
	mv_s	#yHiLoClip,r0	//LOADIndirectDtram
	ld_s	(r0),r0
	nop
	ld_s	(r0),r0
	nop
	.endif

{
	sub	slice_count,slice_count
//	ld_s	(r0),r0				;get Y clipsize.
}	
	mul	slice_size,total_mpes,>>acshift,chunk_size	;Chunk size
{
	lsr	#16,r0,r1				;extract Y hi
	mul	slice_size,mpe_num,>>acshift,slice_offset	;Offset to start of our slice
}
	bits	#15,>>#0,r0			;extract Y lo

mmpe:

	push	v0
	push	v1


; Sort out stuff for multiple MPEs.

	push	v6
	mul	chunk_size,slice_count,>>#0,slice_count		;Get to the zone
	mv_s	dma_ypos,r25
	add	slice_offset,slice_count					;This is the start line.
	add	slice_size,slice_count,r26					;This is the end line
	asr	#16,r25
	add	outercounter,r25,r27						;r25=bottom, r27=top of unclipped line.
	add	#1,r27

; clip the render zone to the clip window
; skip zone if it is above the clip window, reduce size in case of RZ split by clip window

	cmp	r0,r26
	jmp	lt,NextZone
	cmp	slice_count,r0
	jmp	lt,not_split,nop
	mv_s	r0,slice_count

not_split:

; finish if slice is beyond the clip zone, again reduce size if RZ split by window

	cmp	r1,slice_count
	jmp	ge,TotallyDone
	sub	r1,r26,r2
	jmp	le,not_split2,nop
	sub	r2,r26		

not_split2:
	
;reject stuff that is out of band

	cmp	r27,slice_count						;check topofslice>max?
	jmp	ge,TotallyDone						;if it is, don't do anymore sprite
	cmp	r26,r25
	jmp	ge,NextZone							;reject current slice totally below min
	
;okay, there is some stuff in the band.  Find out how much to chop off the bottom..

	sub	r27,r26								;This will be +ve if end line is inside the slice.
	bra	lt,gotchop1							;Otherwise it is the # of lines to chop
	sub	r25,slice_count						;This will be -ve if the start line is inside the slice.
	mv_s	#0,r25							;default for next conditional
	mv_s	#0,r26							;chop zero if it's in the slice

gotchop1:

	bra	lt,gotchop2
	mv_s	r25,r0
	mv_s	r26,r1
	sub	slice_count,r1								;shorten
	mv_s	slice_count,r0

gotchop2:


	pop	v6
	push  v3				;save existing dma-info	
{
	mv_s	r23,r4			;get these in a vector to save
	copy	r25,r5
}
{
	mv_s	r19,r6
	copy	r10,r7
}
	push	v1
	st_s	#0,acshift
    	
; okay, r0 is the # lines to trim from the bottom, r1 the number to trim from the top.


	sub	r0,z1
    sub r3,r3
;    add #1,z1
{
	mv_s	r0,r2
	jmp	ge,ncl_1,nop
	sub	r0,z2	
}
	mul	delta_x,z1,>>acshift,r3					;edge 1 clip value
ncl_1:
	jmp	ge,ncl_2,nop			;was gt
	add	z2,r2
	copy	sineline,r30
	mul	width,r30,>>#27,r30
               
    
	cmp	#0,edge_swap
	jmp	ne,ncl_11,nop
{
	jmp	ncl_2,nop
	add	r30,x2_
}	
ncl_11:
	add	r30,dma_xpos
ncl_2:
	mul	delta_x,r2,>>#0,r2
	cmp	#0,edge_swap
	jmp	ne,reverse_order,nop
{
	jmp	ncl_3,nop
	subm	r3,dma_xpos,dma_xpos
	add	r2,x2_
}
reverse_order:
{
	subm	r3,x2_,x2_
	add	r2,dma_xpos
}
ncl_3:
{
	add	r0,>>#-16,dma_ypos
}
    copy    x2_,r0
    bra ge,ceil1
    abs r0
    add #1,>>#-16,r0
    neg r0
ceil1:
    copy    r0,x2_    

ntopclp:

	add	r1,outercounter
	st_s	#0,rx
{
	st_s	#0,ry					;just a hack before lin_ctl is implemented
	sub	buffoff,buffoff
}	

aal_outer:

	push	dmastuff				;preserve dmastuff
	push	v4						
	push 	v5
	push	v2

; hclip

//	mv_s	#(xHiLoClip),r31
//	ld_s	(r31),r0
//  nop
	.if(B==0)
	LOAD	GxHiLoClip, ld_s, xHiLoClip, r0, r0
	.else
	mv_s	#xHiLoClip,r0	//LOADIndirectDtram
	ld_s	(r0),r0
	nop
	ld_s	(r0),r0
	nop
	.endif

    asr #16,r0,r1
    bits    #15,>>#0,r0
    lsl #16,r1
    lsl #16,r0  
	cmp	r0,x2_
	jmp	lt,aal_done,nop
	cmp	dma_xpos,r1
	jmp	le,aal_done,nop			;obviously crap cases
	cmp	r0,dma_xpos
	jmp	ge,hcl_1,nop
    mv_s    r0,dma_xpos
hcl_1:
	cmp	x2_,r1
	jmp	gt,hcl_2,nop
	mv_s	r1,x2_
hcl_2:


{
	mv_s	#buffsize,dma_len		;set length of pixel strip
	sub	dma_xpos,x2_,r24		;set total length of x-span
}

	mv_s	#genbuf,dma_base
{
	ld_s	(dma_base),dma_base
	jmp	le,aal_done
}
	asr	#16,r24				;make x span length an integer
	st_s	#0,ru
	mv_s	#$ffff0000,r0
	and	r0,dma_xpos		


aal_inner:

{
	mv_s	#buffsize,dma_len		;set length of pixel strip
	sub	#buffsize,r24			;dec total width
}
	mv_s	#31,r0
{
	st_s	#0,rx					;init rx to 0
	bra	ge,notrunc					;>0, no need to truncate
}
	st_s	r0,acshift
	nop

	add	r24,dma_len			;adjust length
	add	#1,dma_len

notrunc:

;
; read in next bufferful of source pixels

//	mv_s	#genbuf,dma_base
	mv_s	#genbuf,dma_base
	ld_s	(dma_base),dma_base
	nop

	add	buffoff,dma_base
	mv_s	dma_base,r0
	st_s	r0,xybase
	st_s	r0,uvbase
	jsr	dma_finished			;change to dma_finished if there are problems with tearing
	ld_io	mdmactl,r0
	nop


	
; 	mv_s	#(dmaFlags|$2000),r1				;Dest DMA type - read pixles 
                                                                                                                                    
//	ld_s	dmaFlags, r1
//	nop
	.if(B==0)
	LOAD	GdmaFlags, ld_s, dmaFlags, r1, r1
	.else
	mv_s	#dmaFlags,r1	//LOADIndirectDtram
	ld_s	(r1),r1
	nop
	ld_s	(r1),r1
	nop
	.endif


	bset	#BitRead, r1

	jsr	dma_go					;wait for DMA available

	ld_io	mdmactl,r0
	st_s	#0,ru

	jsr	dma_finished			;change to dma_finished if there are problems with tearing
	ld_io	mdmactl,r0
	nop

	.include  "aaline1.s"	

;
; write out filled pixel buffer

wrout:

	pop	v6
	nop

dmastrip:


//	mv_s	#genbuf,dma_base
	mv_s	#genbuf,dma_base
	ld_s	(dma_base),dma_base
	nop

	add	buffoff,dma_base

	.if(B==0)
	LOAD	GdmaFlags, ld_s, dmaFlags, r1, r1
	.else
	mv_s	#dmaFlags,r1	//LOADIndirectDtram
	ld_s	(r1),r1
	nop
	ld_s	(r1),r1
	nop
	.endif
	jsr		dma_go					;wait for DMA available

	ld_io	mdmactl,r0				;get dma status on the way
	st_io	#0,ru

{
	add		dma_len,>>#-16,dma_xpos		;update dma's xpos
}
	eor		#1,<>#-dma_base_offset,buffoff			;flip buffer offset
 
nolode:

;
; loop for this scanline

	btst	#31,r24			;did diameter go negative?
	jmp	eq,aal_inner				;if no carry on
	nop
	nop
;
; loop for the llength of the lline

aal_done:

	pop	v2
	pop	v5
	pop	v4							;retrieve....
{
	pop	dmastuff					;retrieve...
	jsr	update_edges				;go step edges...
}
	nop
	add	#1,>>#-16,dma_ypos			;step over scanlines
	
	sub	#1,outercounter				;count for height of innerzone

	jmp	ge,aal_outer,nop			;if outerzone not yet traversed, loop away...

; if we get here, we're done.

endline:

; pop off stuff from multi-MPE mode, restore...

	pop	v1
	pop	v3
	nop
{
	mv_s	r7,r10
	copy	r4,r23
}
{
	mv_s	r6,r19
	copy	r5,r25
}

nz:

	pop	v1
	pop	v0				;get back multi-mode stuff

	cmp	#0,total_mpes
	jmp	ne,mmpe
	bra sxit
	add	#1,slice_count
	nop
	


sxit:		

	pop	v1				;Saved polyline flags here.
	nop
	cmp	#0,mline		;Multiline mode?
{
	bra	eq,line_exit,nop	;Nope.
}		
	jmp	poly_line,nop	;Nope, go do next line segment
	nop

line_exit:		  
snard:
	st_s	#0,acshift		;TAJ 10/2/98 - restore this to 0 to fix the sqrt bug in the sample code
	pop		v2, rz
	nop
	mv_s	r10, r31
{	ld_v	(r31),v3
	add		#16,r31
}
{	ld_v	(r31),v4
	add		#16,r31
}
{	ld_v	(r31),v5
	add		#16,r31
}
{	ld_v	(r31),v6
	add		#16,r31 
}
	ld_v	(r31),v7
	nop
	add		#16,r31
//	rts t,nop
	rts
	nop
	nop


TotallyDone:
	pop	v6
	jmp	sxit
	pop	v1
	pop	v0


NextZone:

	pop	v6
	jmp	nz,nop


;
; update_edges - incs edge pointers according to state of z1 and z2


update_edges:

	.if(B==0)
	LOAD Gmax_x, ld_s, max_x, r0, r1
	.else
	mv_s	#max_x,r0	//LOADIndirectDtram
	ld_s	(r0),r0
	nop
	ld_s	(r0),r1
	nop
	.endif
{
//	mv_s	#max_x,r0
	btst	#0,edge_swap
}

{
//	ld_s	(r0),r1
	bra	ne,swapped_edges,nop
}
	cmp	#0,z1
{
	bra	ge,nads1,nop
	sub	#1,z1
}
	add	delta_x,dma_xpos

nads1:

	add	delta_x,x2_
	cmp	r1,x2_
	rts	lt							;was rts ne
	rts
	nop
	copy	r1,x2_
nads2:
	rts t,nop	

swapped_edges:

	cmp	#0,z1
{
	bra	ge,nads3,nop
	sub	#1,z1
}
	add	delta_x,x2_

nads3:

	add	delta_x,dma_xpos
	cmp	r1,dma_xpos
	rts	gt	
	rts
	nop
	copy	r1,dma_xpos
nads0:
	rts t,nop	


loadmore:

; load another 64-long chunk of polyobject

    push    v1,rz
	push	v7
/* -------------- Other Bus Code --------------------------- */
	mv_s	#NumPts, r4
    st_s    r4,rc0         ;use counter to trigger loading of longer pline list

	;set external address of poly line object
	.if(B==0)
	LOAD	Gpline_ptr, ld_s, pline_ptr, r5, r5
	.else
	mv_s	#pline_ptr,r5		//LOADIndirectDtram
	ld_s	(r5),r5
	nop
	ld_s	(r5),r5
	nop
	.endif

	mv_s	#pline, r6		;where to read it to
	ld_s	(r6), r6
	nop

	mv_s	#2, r7

{	jsr		odma_wtrd,nop
	ld_io	pcexec, r31
}
	nop
//	add #(NumPts<<2),r5			;update external pointer, NOTE: r5 has been incremented after odma_wtrd
	mv_s	#pline_ptr,r30		;set external address of poly line object
	ld_s	(r30), r30
	nop
	st_s	r5, (r30)
	
;wait for points to be loaded
`loop1:
	ld_io	(odmactl), r30
	nop
	bits	#LeftDmaActive, >>#0, r30
	bra	ne, `loop1, nop
	
	
/* -------------- Main Bus Code --------------------------- */
/*    jsr dma_finished            ;wait for no pending DMA
    ld_s    mdmactl,r0
    nop
    
    mv_s   #64,r0

    st_s    r0,rc0

{
    jsr dma_read
    mv_s    #pline,r2
}
    ld_s   pline_ptr,r1
    nop
;    ld_s    object,r31
;    mv_s    #0,r31

    jsr dma_finished
{
    ld_io    mdmactl,r0
//  add #256,r1
	add #(_DMA_BUFFSIZE*4),r1
}
    st_s    r1,pline_ptr
-----------------------------------------------------------*/
	pop v7
    pop v1,rz 
    nop
    mv_s    #pline,mline
	ld_s	(mline),mline
    rts
    nop
    nop


round:

; make a 16-bit integer by proper rounding

{
    mv_s    r0,r2    
    lsr #16,r0
}
    bits    #0,>>#15,r2    
{
    btst    #31,r1
    addm r2,r0,r0
}
    rts eq
    rts
    nop
    neg r0

