
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

//	_draw_ellipse(environs, paramBlockP, 0, 0);
//	r0 = environment data
//	r1 = pointer to parameter block
//	r2 = unused
//	r3 = unused

; ol_circle.s
;
; draw open or filled translucent antialiased circles
; and simple ellipses


	.include "mrp.i"
;==============================================================
	.segment	data
	.align.v
;==============================================================

	dest:		.dc.s 0
	dmaFlags:	.dc.s 0
	xHiLoClip:	.dc.s 0
	yHiLoClip:	.dc.s 0
	rzinfVar:	.dc.s 0
	object:		.dc.s 0
	view:		.dc.s 0
	mixcache:	.dc.s 0
	genbuf:		.dc.s 0

;==============================================================
	.segment	text
	.align.v
;==============================================================
;===================================
;	Variables
;===================================
// Offset in bytes from start of parameter block

szLong = 4		// size of long

destOf		= 0 * szLong
dmaFlagsOf	= 1 * szLong
xHiLoClipOf	= 2 * szLong
yHiLoClipOf	= 3 * szLong

//dest:		.dc.s	$40000000
//dmaFlags:	.dc.s	$002dc840
//xHiLoClip:	.dc.s	$01670000			;X hi:lo clip
//yHiLoClip:	.dc.s	$00ef0000			;Y hi:lo clip
Gdest		= _FALSE	// global storage flag  
GdmaFlags	= _FALSE	// global storage flag 
GxHiLoClip	= _FALSE	// global storage flag 
GyHiLoClip	= _FALSE	// global storage flag 

;===================================
rzinfOf		= 4 * szLong
//rzinf:		.dc.s	0			;Base MPE
//			.dc.s	$000000f0	;Size of render zones
//			.dc.s	$00000001	;Total number of MPEs
//			.dc.s	0			;to keep vect align
Grzinf		= _FALSE	// global storage flag 
;===================================

objectOf	= 8 * szLong
//object:		.dc.s	$005000a0		;packed 16bit x1:y1
//			.dc.s	$0060e000		;size X:Y (sprite or p-txture) 
									;radius/linewidth (circle)
									;x2:y2	(line)
//			.dc.s	$d7538f01 ;$41D46400=red		;packed colour 1/type
//			.dc.s	$f3393100		;packed colour 2/type

//			.dc.s	$01000080		;packed scales x_:y_ (sprite, circle)
//			.dc.s	$f1002000		;Translucency/border thickness (line)
//			.dc.s	1				;0 = Open 1 = Filled
//			.dc.s	0				;unused
Gobject		= _FALSE	// global storage flag 
szobject	= 8

;===================================
; the VIEW structure is left over from the "old" way of doing things and will
; probably disappear as and when I renovate the code.  There is no need for the
; user to put anything meaningful here.  It is filled by translation from the
; "new" standard structure. 

viewOf		= objectOf + (szobject * szLong)
//view:		.dc.s	0,0,0,0
Gview		= _FALSE

mixcacheOf	= viewOf + (4 * szLong)
//mixcache:	.ds.s	buffsize
Gmixcache	= _FALSE

;============================================

dma__cmdAddrOf		= mixcacheOf + (buffsize * szLong)
//dma__cmd:		.dc.s   0,0,0,0,0,0,0,0

genbufAddrOf		= dma__cmdAddrOf + (1 * szLong)
//buildbuf1:	.ds.s	buffsize
//buildbuf2:	.ds.s	buffsize

;============================================


;==============================================================
;				Register aliases
;==============================================================
clipwindow = v1
clipleft = r4
cliptop = r5						
clipright = r6
clipbottom = r7

xrad_squared = r16
yrad_squared = r20
one_over_xrad_squared = r17
one_over_yrad_squared = r9
xscale = r18
yscale = r19
xrad = r18
yrad = r19			;alt names for xscale and yscale
blend = r8
mixcache_ptr = r10
dstbase = r10
radius = r11
y_ = r21
x_ = r22
flags = r23			;sundry flagz
y_thang = r24
inbuf_offset = r25
outbuf_offset = r26	;for dbl buffering the dma Thangs
xbase = r27
width = r28
packedcol = r31
mask = r29
temp1 = r30
temp2 = r11			;can use once radius is done with

	dmastuff = v3
;	dma_count = r14
	dma_len = r14
	dma_base = r15
	dma_xpos = r12
	dma_ypos = r13


;
; some flag values

	LH_offscreen = 1		;LHS offscreen, do lot read/write DMAs to/from there
	RH_offscreen = 2		;RHS offscreen, see above
	LH_clip = 3				;Enable slice-by-slice clip of LH blits
	RH_clip = 4				;Enable slice-by-slice clip of RH blits

_LH_offscreen = 2
_RH_offscreen = 4
_LH_clip = 8
_RH_clip = 16				;Flags in decimal 

buffsize = _DMA_ELPSE_BUFFSIZE          ;maximum DMA size
buffmult = 2			// (inbuff or outbuff)/buffsize
szLong = 4

_TRUE = 1
_FALSE = 0
B = 0

;==============================================================
;        macros
;==============================================================

	.include	"macros1.i"


;==============================================================
;	exports & imports

;==============================================================
	.export	_draw_ellipse
	.import	dma__cmd


;==============================================================
    .segment    text
;==============================================================

_draw_ellipse:
	
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

	.if(Gview == _FALSE)
	setParamAddr	viewOf, view
	.endif

	.if(Gmixcache == _FALSE)
	setParamAddr	mixcacheOf, mixcache
	.endif

mrpbuffers:
//	store paramBlockP->dma__cmdAddr in global dma__cmd variable
	add		#dma__cmdAddrOf, r1, r4
	mv_s	#dma__cmd, r5
	ld_io	(r4), r6
	nop
	st_s	r6, (r5)	

//	store paramBlockP->genbufAddr in global genbuf variable
	add		#genbufAddrOf, r1, r4
	mv_s	#genbuf, r5
	ld_io	(r4), r6
	nop
	st_s	r6, (r5)	


;
; Initialise XY and UV
;

_draw_ellipse_go:

//	mv_s	#object,r0
	.if(B==0)
	LOAD	Gobject, ld_v, object, r0, v1
	.else
	mv_s	#object,r0	//LOADIndirectDtram
	ld_s	(r0),r0
	nop
	ld_v	(r0),v1
	nop
	.endif
{
;before	(setbp "circ_inner")
	mv_s	#($10400000|buffsize),r1				;Width = buffer width*2; use ch_norm; pixmap 4
}
	st_s	r1,xyctl
	st_s	r1,uvctl					;Initialise the control regs
	st_s	r1,linpixctl
	st_s	#0,acshift
	st_s	#3,svshift				;Initialise the multiplier defaults
/*	push v4
	push	v7,rz						;save calling address
										// TAJ - NOTE: This is a bug. This push saves registers r28-r30 of v7
										// but not r31 which stores the return address in the "C" program

	push	v6							// TAJ - added this push since caller is in "C" language
	push	v2							;Begin saving registers
	push	v3							;save, save....
	push	v5*/						;Continue saving reggiez...
	mv_s	#$ffff,mask					;init a mask
ox:
{
//	ld_v	(r0),v1						;Fetch x_,y_,rad,width of line
	add	#16,r0
}
{
	ld_v	(r0),v3						;get dest base, radius
}
    nop
//	mv_s	#dest_screen+4,r0
//	mv_s	#dest,r0
	.if(B==0)
	LOAD	Gdest, ld_s, dest, r0, dstbase
	.else
	mv_s	#dest,r0	//LOADIndirectDtram
	ld_s	(r0),r0
	nop
	ld_s	(r0),dstbase
	nop
	.endif

{
//	ld_s	(r0),dstbase
	lsr	#16,r5,radius					;extract radius
}

{
//	ld_s    object+8,packedcol
	asr	#8,r12,xscale					;extract x_-scale to 16:16
}
	and	mask,r12,yscale
	asl	#8,yscale
	lsr	#2,r13,blend					;set xlucency
{
;	mv_s	r6,packedcol				;copy out packed colour
	and	mask,r5,width					;set stroke width
}
{
	mul	radius,xscale,>>#16,xrad		;gen X size in pixels, int
}

; Initialise DMA
;

{
;	mv_spr pc,rz
	jsr	dma_wait						;Ensure that DMA is ready for commands
	mul	radius,yscale,>>#16,yrad		;gen Y size in pixels, int
	asl	#16,mask						;get hi word of mask as FFFF	
}
	mv_s	#0,r3
{
	ld_s	mdmactl,r0				;fetch this on the way
;	asl	#16,temp1,xbase					;set xbase
	and	mask,r4,xbase					;set xbase
}
	nop

	mv_s	#dma__cmd,r1
	ld_s	(r1),r1
	nop
	add		#4,r1
{
//	mv_s	#(dma__cmd+4),r1
	subm	r2,r2,r2						;clear this
	copy	dstbase,r0					;now the vector for dma0 is complete
}
{
;	st_io	v0,(dma_1)					;DMA reg 0 initialised
	st_s	r0,(r1)
	subm	temp1,temp1,temp1				;make 0 so I can use multiplier for r->r move 
;	and mask,temp1,dma_ypos				;set initial DMA_YPOS
	asl	#16,r4,dma_ypos
}
{
	copy	xbase,dma_xpos
	subm	r1,r1,r1					;fracbits for the upcoming recip call
}
{
	mv_s	#buffsize,dma_len			;initialise for size of DMA bursts
	addm	xrad,temp1,xrad_squared		;prepare to calc xradsquared
	sub	xrad,>>#-16,dma_xpos			;point to left edge of draw rectangle
}

	mv_s	#genbuf,dma_base
//	mv_s	#inbuf,dma_base
	ld_s	(dma_base),dma_base
	nop
{
//	mv_s	#genbuf,dma_base			;initial output buffer base
	addm	yrad,temp1,yrad_squared	;prep for calc 1/(yrad^2)
	sub	yrad,>>#-16,dma_ypos		;point to top of draw rectangle
}
{
;	st_s	packedcol,(dma_base)	;Put packed colour into build_buf
	mul	xrad_squared,xrad_squared	;compute xrad_squared
	sub	temp2,temp2					;clear temp2
}
{
	st_s	#0,rv					;init v index 0	(srce strip index)
	mul	yrad_squared,yrad_squared	;compute yrad_squared
	add	yrad,>>#-16,temp2			;get y_-radius ready for clipping
}
{
	push	v6						;carry on saving the regset...
;	subm	r1,r1,r1				;there are zero fracbits
	jsr	recip						;call recip
	copy	xrad_squared,r0			;prep to call recip
}
{
	push	v7						;finished preserving the register file
	subm	inbuf_offset,inbuf_offset,inbuf_offset	;init to 0
	sub	yrad,temp1,y_					;init Y to be -yrad
}
	nop
	nop
{
	st_s	dma_base,xybase		;set initial base of xy
	subm	outbuf_offset,outbuf_offset,outbuf_offset	;init to 0
	sub	#28,r1						;want recip result with 30 bits of frac
}
{
	mv_s	#0,r1					;again, zero fracbits
	addm	yrad_squared,temp1,r0	;move yrad_squared to r0
;	jsr	recip						;call recip for 1/yr^2
	ls	r1,r0,one_over_xrad_squared	;calculation completed for 1/xr^2
}
	jsr	recip						;call recip for 1/yr^2 // TAJ - moved here to fix ERROR: packet too large
{
	st_s	#0,ry					;init y_ index 0	(dest strip index)
	asl	#1,temp2					;this is y_-radius in 16:16
}
//	mv_s	#object+24,flags
	mv_s	#object,flags
	ld_s	(flags),flags
	nop
	add		#24,flags
	ld_io	(flags),flags				;force filled mode
	nop

	.if(B==0)
	LOAD	Gview, ld_v, view, r4, clipwindow
	.else
	mv_s	#view,r4	//LOADIndirectDtram
	ld_s	(r4),r4
	nop
	ld_v	(r4),clipwindow
	nop
	.endif
{
//	ld_v	view,clipwindow			;pick up the view window info
	addm	yrad,temp1,r2			;copy yrad to r2
	sub	#28,r1						;30 bitza frac please dude
}
{
	addm r2,r2,temp1					;make 2x yrad (entire height of circle)	
	ls	r1,r0,one_over_yrad_squared	;got 1/yr^2 - cheerz Bob
}

; okay, set up the "old" View param block with the new values.

//  ld_s    dest_screen+8,r2
//  ld_s    dest_screen+12,r3
	.if(B==0)
	LOAD	GxHiLoClip, ld_s, xHiLoClip, r2, r2
	.else
	mv_s	#xHiLoClip,r2	//LOADIndirectDtram
	ld_s	(r2),r2
	nop
	ld_s	(r2),r2
	nop
	.endif
//  ld_s    xHiLoClip,r2

	.if(B==0)
	LOAD GyHiLoClip, ld_s, yHiLoClip, r3, r3	
	.else
	mv_s	#yHiLoClip,r3	//LOADIndirectDtram
	ld_s	(r3),r3
	nop
	ld_s	(r3),r3
	nop
	.endif
//  ld_s    yHiLoClip,r3

    lsl #16,r2,r0
    lsl #16,r3,r1
    

;	mv_s	#rzinf-8,r0
;	lsl	#16,slice_count,r1
;	ld_s	(r0),r2				;X stuff	
	
;	lsl	#16,r3
;	lsl	#16,r2,r0
;	mv_s	#view,r4
;	st_v	v0,(r4)

//  st_v    v0,view
	.if(B==0)
	STORE	Gview, st_v, view, v0, r4
	.else
	mv_s	#view,r4		//STOREIndirectDtram
	ld_s	(r4),r4
	nop
	st_v	v0,(r4)
	.endif

	mv_v	v0,v1
	
; and now just let the old clipping do its thang.	

	mv_s	#0,outbuf_offset
	mv_s	#0,inbuf_offset
	st_s	dma_base,xybase		;set initial base of xy


;
; do y_ clipping
;

	mv_s	temp1,r2
{
	st_s	#0,rx					;zero rx - (xy) now points at the stored packed colour value
	addm dma_ypos,temp2,temp2		;make upper Y extent for clip	
	asl	#17,xrad,temp1				;made X diameter
}
{
	addm	dma_xpos,temp1,temp1		;upper X extent
	cmp	clipbottom,dma_ypos			;Is top of circle past bottom edge of window? 
}
{

	jmp	gt,trivial_exit				;Indeed it is, so bugger off.
	cmp	cliptop,temp2				;Is bottom of circle above top edge of window?
}
{
	jmp	lt,trivial_exit				;Yeah - again, bugger off,
	cmp clipright,dma_xpos			;LH edge of circle past RH edgr?
}
	nop
{
	jmp	gt,trivial_exit
	cmp	clipleft,temp1				;RH edge past LH clip edge?
}
{
	jmp	lt,trivial_exit
	sub xrad,>>#-16,temp1
}

; if we get past here at least some of the circle lies in the visible
; clip zone

{
	subm clipbottom,temp2,temp2		;Get bottom clip amount, if any
	sub	dma_ypos,cliptop,r1			;Get top clip amount, if any
}
	nop
{
	bra	le,noTopClip				;if less or equal, top is okay
	asr	#16,r1,r3					;take the int part of any clip amount
}
	asr	#16,temp2					;fetch the int part of any bottom clip
	nop
{
	subm	r3,r2,r2				;Reduce height of outer loop by clip amount
	copy	cliptop,dma_ypos		;make stuff start at top clip edge
}
	add		r3,y_					;update initial y_ to account for clip

noTopClip:

	cmp	#0,temp2					;check sign of bottom clip amount
	bra	le,noBottomClip				;if it is -ve, there's none
	nop								;Ugh
	nop
	sub	temp2,r2					;Reduce size of outer loop by clip amount

noBottomClip:	

;	add	#1,r2						;to avoid fuckups if yrad is 0	
{
	cmp	#0,r2						;check final result of yclip
}
{
	mv_s	#buffsize,dma_len
	jmp	le,trivial_exit,nop			;go away if negative or zero
	cmp	temp1,clipleft				;where is centre axis?  
}

;	x_-clipping.. set various clip flags

{
	bra	le,cxflags1					;centre axis is onscreen if true
}
	nop
	nop
;	bset	#LH_offscreen,flags		;no LHS DMA, centre axis is off to the left
	or	#1,<>#-LH_offscreen,flags
cxflags1:

	sub	dma_len,>>#-16,temp1			;special case - right clip must occur
	cmp	temp1,clipleft				;if centre is within 1 DMA buffer length of the edge 
{
	bra	lt,cxflagsa
	add	dma_len,>>#-16,temp1
}
	nop
	nop
;	bset	#RH_clip,flags
	or	#1,<>#-RH_clip,flags
cxflagsa:

{
	cmp	dma_xpos,clipleft			;check for left edge onscreen
}

	bra	le,cxflags2
	nop
	nop
;	bset	#LH_clip,flags			;enable LH clip against LH edge
	or	#1,<>#-LH_clip,flags
cxflags2:
	cmp	temp1,clipright				;check RHS status...
	bra	gt,cxflags3
	add	xrad,>>#-16,temp1			;make extreme RH edge...
	nop
;	bset	#RH_offscreen,flags
	or	#1,<>#-RH_offscreen,flags
cxflags3:
	cmp	temp1,clipright
	bra	gt,cxflags4
	nop
	nop
;	bset 	#RH_clip,flags
	or	#1,<>#-RH_clip,flags
cxflags4:

{
	st_s	r2,rc1				;initialise Y count
	subm	r1,r1,r1				;zero bits of prec for recip
	jsr	recip,nop					;call recip for width
	copy width,r0					;make width the argument for recip
}
{
;	ld_p	(xy),v1					;Convert packed colour value to a colour vector
	sub	#28,r1						;get result to 28 bits of frac
}
	ls	r1,r0						;make result 28 bits of frac

    cmp #$3fffffff,blend            // max alpha value?
    bra eq,set_max_blend_flag,nop

{
	mul	r0,blend,>>#28,blend		;this is now blend/width
//	sub	temp1,temp1					;need this 0 for loops
    bra before_circ_outer
}
    nop
    nop

set_max_blend_flag:

	mul	r0,blend,>>#28,blend		;this is now blend/width
    nop
    bset #31,blend                  // flag that this is max alpha (max opaque) - used in circ_inner

before_circ_outer:

	sub	temp1,temp1					;need this 0 for loops

    	
;
; Initialise is complete - this code is outer loop code
;

circ_outer:

{
	mv_s	#$10000,r1				;1.0 in 16:16
	mul	y_,y_,>>acshift,r0			;make ysquared
}
	mv_s	#buffsize,dma_len		;init dma_len
	mul	one_over_yrad_squared,r0,>>#12,r0	;make y_^2/YRAD^2
	nop								;wait for mul result
{
	mv_s r0,y_thang					;copy result for use in inner loop
	sub	r0,r1,r0					;make 1-(y_^2/YRAD^2) in r0
}
	.if(Gmixcache==_FALSE)
	mv_s	#mixcache,mixcache_ptr
	ld_s	(mixcache_ptr),mixcache_ptr
	nop
	.else
	mv_s	#mixcache,mixcache_ptr
	.endif
{
//	mv_s	#mixcache,mixcache_ptr	;init the mix cache
	mul	xrad_squared,r0,>>#16,r0	;make (1-(y_^2/YRAD^2))*XRAD^2 as integer
}
{
;	mv_spr	pc,rz
	jsr	sqrt,nop					;call sqrt
	sub	r1,r1						;no bits of input frac to sqrt
}	
	nop
{
	addm	xbase,temp1,dma_xpos		;set dma_xpos to centre of circle
	as	r1,r0					;got the integer sqrt result
}
{	
	sub r0,temp1,x_					;make X for this line
;	add	#1,r4,r5					;make copy for inner loop count
}
{
	jmp	eq,nothing_thisline,nop		;if X is zero don't have anything ][ do
	st_io	r0,(rc0)				;init inner loop count
	sub	r0,>>#-16,dma_xpos			;make *actual* dma_xpos
}

;
; Load in destination pixels to their working buffers
;

loadbuffs:

;	mv_s	#1,flags

	push	v7
{
	push	v3						;save basic DMA state
;	mv_spr	pc,rz
;	jmp	dma_wait					;wait for any pending dma to complete
}
{
;	ld_io	(dma_stat),r0			;get dma_stat on the way
	sub	r1,r1
}

	mv_s	#genbuf,dma_base
	ld_s	(dma_base),dma_base
	nop
{
//	mv_s	#inbuf1,dma_base		;point at inbuf
	asl	#1,x_,r2						;get -2x the xwidth in pixels
}
//	mv_s	#dest_screen,r1
//	mv_s	#dmaFlags,r1
	.if(B==0)
	LOAD	GdmaFlags, ld_s, dmaFlags, r1, r1
	.else
	mv_s	#dmaFlags,r1	//LOADIndirectDtram
	ld_s	(r1),r1
	nop
	ld_s	(r1),r1
	nop
	.endif

{
//	ld_s	(r1),r1                 ;get dest dma nature
	addm	inbuf_offset,dma_base,dma_base		;point to DMA dest position
}

	st_s	dma_base,uvbase		;set srce base...
	bset	#13,r1
{
	asl	#2,dma_len,r3				;gonna use this to point at RHS buffer
	jsr	lft_dma
}
{
	addm	dma_len,r2,r2			;this is now -(hdistance to RHS dma slice)	
}
	nop
{
	ld_s	mdmactl,r0			;get stat on the way
;	jsr	dma_wait					;go read buffsize pixels from RHS of dest, if it may be onscreen
	addm	r3,dma_base,dma_base	;point at RHS-buffer
	neg	r2							;make this positive
}
	jsr	dma_wait					;go read buffsize pixels from RHS of dest, if it may be onscreen
									// TAJ - moved here to fix ERROR: packet too large
{
	add	r2,>>#-16,dma_xpos			;point to start of RHS of dest
}
	nop
//	mv_s	#dest_screen,r1
//	mv_s	#dmaFlags,r1
	.if(B==0)
	LOAD	GdmaFlags, ld_s, dmaFlags, r1, r1
	.else
	mv_s	#dmaFlags,r1	//LOADIndirectDtram
	ld_s	(r1),r1
	nop
	ld_s	(r1),r1
	nop
	.endif

{
; 	mv_s	#$2ce040,r1				;Dest DMA type                                                                                                                                     
//	ld_s	(r1),r1
	jsr rght_dma
}
	nop
	bset	#13,r1
{
	pop	v3							;retrieve default dma stuff
//	cmp	#0,inbuf_offset				;check state of the offset
}
{
	st_s	#0,ru					;POint to start of read buffer
//	bra	ne,sinoff0					;if nonzero, go set to zero
}
{
	st_s	#0,rx					;Point to start of write-buffer
//	sub	inbuf_offset,inbuf_offset	;do it on the way
}
//	nop
//	add #buffsize*8,inbuf_offset ;switch buffer pointers
//	add	#(buffsize*buffmult*szLong),inbuf_offset	;switch buffer pointers

sinoff0:


	pop	v7
    nop
//	jsr	dma_finished,nop			;Force DMA to complete for debug




;
; Circle draw inner loop code.  Assumes that LHS buffer is filled, RHS could be still loading
;

circ_inner:

{
	mv_s	#$10000,r2				;get 1.0 in 16.16
	mul	x_,x_,>>acshift,r0			;Start to get current x_-squared.
	asl	#1,width,r1					;Get width*2.
}
{
	push	v1						;save clip info
	sub	r1,r2						;make inner limit
}						
	mv_s	#object,r1
	ld_s	(r1),r1
	nop
	add		#8,r1
//	mv_s	#object+8,r1

{
;	ld_v	circol,v1				;get the dest colour
	ld_p	(r1),v1
	mul	one_over_xrad_squared,r0,>>#12,r0	;get (x_^2/XR^2) to 16:16
}
	nop
	push	v6						;free up a vector reg.
{
	ld_p	(uv),v6					;Fetch first srce-pixel
	addm	y_thang,r0,r0			;get (x_^2/XR^2)+(y_^2/YRAD^2)
;	addr #1,ru
	addr #(1<<16),ru
	btst	#0,flags				;Check to skip boundary conditional
}
{
	bra	ne,skipcond					;If solid, skip the conditional
	sub	r0,r2						;make position
}
	jmp	ge,escape0					;If > innermost limit,bugger off
	nop
	bra	notsolid					;Branch if not a filled circle

skipcond:

	add width,r2					;check width
{
	bra le,notsolid					;if -ve, still on the outside edge
	abs	r2							;make this positive
}
	nop								;damn, an extra nop for filled pixels
	nop
	sub	r2,r2						;make filled pixels maximum intensity



notsolid:

{
	subm	r2,width,r2				;make it largest at the centre
	sub_sv	v6,v1					;make vector towards full brightness 
}
	mul	blend,r2,>>acshift,r2		;make final blend value
	nop                             ;await mul unit

    btst #31,blend                  // max opaque?
    bra  ne,go_compute_pix_value,nop // yes

	mul_p	r2,v1,>>svshift,v1		;generate scaled vector
    								
go_compute_pix_value:

{
	st_s	r2,(mixcache_ptr)		;save for RHS generation
//	mul_p	r2,v1,>>svshift,v1		;generate scaled vector
	add	#4,mixcache_ptr				;update mixcache pointer
}
	add	#1,x_						;well, it's gotta be done
{
	pop	v6							;restore v6
	dec	rc0
	add_sv v6,v1					;generate final pixel
}
{
	st_p	v1,(xy)					;write to dest buffer
;	addr	#1,rx					;bump x_ 
	addr	#(1<<16),rx				;bump x_ 
	jmp	c0eq,escape					;if rc0 = 0	lleave inner loop
	sub	#1,dma_len					;dec dma width ctr	
}
{
	pop	v1							;restore clip info
	jmp	ne,circ_inner				;if not eq to 0, iterate s'more
}
	nop
{
	jsr	dma_lr						;do dma left, gen right, init dma right
	sub	r1,r1						;so I can move with an add next tick
}
{
	add	#buffsize,r1				;to set correct dma_len
}
	nop
{
	jmp	loadbuffs,nop					;go and load nxt pair of buffers
}

escape:
	
;
; dma flush
;

{
	jsr	dma_lr						;do dma left, gen right, init dma right
	sub	r1,r1						;so I can move with an add next tick
}
{
	add	#buffsize,r1				;to set correct dma_len
}
	nop

;
; dec ctrs and loop
;

nothing_thisline:

	dec	rc1							;dec outer loop counter
{
	jmp	c1ne,circ_outer				;loop for all scanlines
	add	#1,>>#-16,dma_ypos			;update dma_ypos
}
	add	#1,y_						;ypdate	y_
	nop	

;
; finish and return
;

trivial_exit:

; hook in the rest of the multiple MPE hack

;NextZone:
;
;	pop	v1
;	pop v0			;get stacked stuff off
;	pop	v2
;	pop	v3
;	pop	v5
;	pop	v7
;	cmp	#0,total_mpes
;	jmp	ne,mmpe
;	jmp	xxx			;Ugh.
;	add	#1,slice_count
;	nop

TotallyDone:

;	pop	v1
;	pop v0			;get stacked stuff off
;	pop	v2
;	pop	v3
;	pop	v5
;	pop	v7


xxx:
// init to 0 all control registers which were used.

	st_s	#0,xyctl
	st_s	#0,uvctl					
	st_s	#0,linpixctl
	st_s	#0,acshift
	st_s	#0,svshift

	pop	v7
	pop	v6

// return to caller
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
	rts
	nop
	nop

/*	pop	v5
	pop	v3
	pop	v2

	pop v6
	pop v7,rz
	nop
	rts
	pop v4 
	nop*/
	
escape0:

{
	pop	v6
	jmp	escape
}
	pop	v1
	nop

dma_lr:

;
; This starts the LHS DMA going, and while it is happening,
; uses the RHS source buffer and the mixcache to generate the RHS pixels,
; then it DMA's em out as well.  r1 contains buffsize.
;


{
	push	v7,rz					;save current coz going down 2 levels
	addm	dma_len,r1,r30			;generate position in rh buffer
}	
{
;	ld_io	(dma_stat),r0
;	mv_spr	pc,rz
;	jmp	dma_wait					;wait for DMA to be ready - we know RHS load has finished here
	mv_s	dma_len,r3				;Gonna use this to gen the RHS buffer start addy
	sub	dma_len,r1,dma_len		;make correct dma size
}			
//	mv_s	#dest_screen,r1	
//	mv_s	#dmaFlags,r1
	.if(B==0)
	LOAD	GdmaFlags, ld_s, dmaFlags, r1, r1
	.else
	mv_s	#dmaFlags,r1	//LOADIndirectDtram
	ld_s	(r1),r1
	nop
	ld_s	(r1),r1
	nop
	.endif

{
;	mv_s	#$160806,r2				;to set forwards-DMA-mode
	jmp	le,eeek						;avoid zero llength dmas
; 	mv_s	#$2cc040,r1				;Dest DMA type                                                                                                                                     
//	ld_s	(r1),r1
	asl	#16,r30						;for st_io to rx a (*shift is +1 coz of mipmap bit set)
}
{
	st_s	r30,rx					;gotta set this to start of RH buffer
;	sub	#1,r1						;need length-1 for clip
}
{
	st_s	r30,ru					;set to start of RH buffer
}
{
;	st_io	r2,(dma_flags)			;set DMA to write mode
;	mv_spr	pc,rz
	jsr	lft_dma						;does LH dma, clipping if necessary
	sub	#4,mixcache_ptr				;predecrement this buffer ptr
}
{
;	st_io	dmastuff,(dma_2)		;write filled dma buffer
	copy	dma_len,r2				;save this to use as a ctr
}
	nop
	mv_s	#object,r0
	ld_s	(r0),r0
	nop
	add		#8,r0
//	mv_s	#object+8,r0
{
	push	dmastuff				;save it while I fuck about with it
	copy	xbase,dma_xpos			;restore this to ctr of circle
}
{
	push	v6						;and I'll be needin' a vector...
	sub	x_,>>#-16,dma_xpos			;point at innermost pixel of RHS
}
blap:
{
;	ld_v	circol,v1				;get th' colour...	
	ld_p	(r0),v1
	asl	#2,r3						;make this point @ longz
}
	nop

gen_rhs:
{
	ld_p	(uv),v6					;Get a srce-pixel.
;	addr	#1,ru					;Move index.
	addr	#(1<<16),ru					;Move index.
}
{
	ld_io	(mixcache_ptr),r0		;Get the cached mix-value.
	sub	#4,mixcache_ptr				;POint at the next one.
}
	nop
{
	push 	v1						;Cheaper than reloading it..
	sub_sv	v6,v1					;Vector towards full mix.
}

    btst #31,blend                  // max opaque?
    bra  ne,go_compute_pix_value1,nop // yes
	mul_p	r0,v1,>>svshift,v1		;Generate the trans mix...

go_compute_pix_value1:

{
//	mul_p	r0,v1,>>svshift,v1		;Generate the trans mix...
	sub	#1,r2						;Dec the counter
}
//	nop								;Wait for mul result.
{
	pop v1							;Restore colour
	bra	ne,gen_rhs					;Loopback conditional
	add_sv	v1,v6					;Calc final pixel value
}

{
	st_p	v6,(xy)					;Write to dest buffr
;	addr	#1,rx					;Update index
	addr	#(1<<16),rx					;Update index
}		
	nop
;
; now the RHS buffer is full of pixels - dma the little buggers out...
;

{
	pop	v6							;can have this back now...
	add	r3,dma_base
}
	nop


	.if(B==0)
	LOAD	GdmaFlags, ld_s, dmaFlags, r1, r1
	.else
	mv_s	#dmaFlags,r1	//LOADIndirectDtram
	ld_s	(r1),r1
	nop
	ld_s	(r1),r1
	nop
	.endif

{
//	mv_s	#dest_screen,r1
//	mv_s	#dmaFlags,r1
;	ld_io	(dma_stat),r0
;	mv_spr	pc,rz
;	jmp	dma_wait,nop				;check DMA free
//	add	#(buffsize*4),dma_base		;finish pointing this @ RHS pixels
	add	#(buffsize*szLong),dma_base		;finish pointing this @ RHS pixels
}
{
//	ld_s	(r1),r1
; 	mv_s	#$2cc040,r1				;Dest DMA type                                                                                                                                     
	jsr	rght_dma,nop
}
{
	ld_s	mdmactl,r0
;	mv_spr	pc,rz
//	jsr	dma_finished,nop
}

;	st_io	dmastuff,(dma_2)		;write out RHS-pixels
	pop	dmastuff					;getback original state



;
; now update everythang and return
;

eeek:

	nop

zaphod:

	mv_s	#object,r1
	ld_s	(r1),r1
	nop
	add		#8,r1
//	mv_s	#object+8,r1
{
;	ld_v	circol,v1
	ld_p	(r1),v1
	add	#4,mixcache_ptr
}
{
	add	dma_len,>>#-16,dma_xpos		;move dma_xpos along	
}

	.if(Gmixcache==_FALSE)
	mv_s	#mixcache,mixcache_ptr
	ld_s	(mixcache_ptr),mixcache_ptr
	nop
	.else
	mv_s	#mixcache,mixcache_ptr
	.endif
{
	cmp	#0,outbuf_offset			;do swap outbuffer pointer
//	mv_s	#mixcache,mixcache_ptr
}
	mv_s	#genbuf,r0
//	mv_s	#inbuf,r0
	ld_s	(r0),r0
	nop

	bra	ne,soutoff0					;if nonzero, make it zero
{
//	mv_s	#genbuf,r0			;gonna use this to set bases..
	sub	outbuf_offset,outbuf_offset	;clear it
}
	nop
//	add	#buffsize*8,outbuf_offset	;switch buffer pointers
//	add	#(buffsize*buffmult*szLong),outbuf_offset	;switch buffer pointers


soutoff0:

{
	pop	v7,rz						;restore rz
	add	outbuf_offset,r0,dma_base	;point at new base
}
	nop
{
	st_s	dma_base,xybase		;set new output base
	rts
;	add	#1,x_						;restore x_ to its true value
}
	mv_s	#buffsize,dma_len
	nop

rght_dma:

;
; do a dma op for the RH side clipping if necessary


	.if(B==0)
	LOAD	Gview, ld_v, view, r4, clipwindow
	.else
	mv_s	#view,r4	//LOADIndirectDtram
	ld_s	(r4),r4
	nop
	ld_v	(r4),clipwindow
	nop
	.endif
{
	mv_s	#(_RH_clip|_LH_offscreen),r28
	and	#(_RH_offscreen),flags,r0	;simplest case...
}
{
	rts	ne							
	and	r28,flags,r0		;other cases that clipping might be needed
}
{
//	ld_v	view,clipwindow			;pick up the view window info
	bra	ne,clipme					;go do clip if flagged
	copy	dma_xpos,r0				;would need this if clipping
}
{
;	rts	(rz)						;else return
	add	dma_len,>>#-16,r0				;r1 has the buffer size already in it.
}

	jmp	dma_go
	ld_s	mdmactl,r0
	nop
;	st_io	dmastuff,(dma_2)		;having triggered the dma.


lft_dma:

;
; do a dma op on the LH half of the circle - clipping if necessary

;	mv_s	#1,flags
	.if(B==0)
	LOAD	Gview, ld_v, view, r4, clipwindow
	.else
	mv_s	#view,r4	//LOADIndirectDtram
	ld_s	(r4),r4
	nop
	ld_v	(r4),clipwindow
	nop
	.endif
    
    and	#(_LH_offscreen),flags,r0	;simplest case...
{
	rts	ne							
	and	#(_LH_clip|_RH_offscreen),flags,r0		;other cases that clipping might be needed
}
{
//	ld_v	view,clipwindow			;pick up the view window info
	bra	ne,clipme					;go do clip if flagged
	copy	dma_xpos,r0				;would need this if clipping
}
kosher:
{
	add	dma_len,>>#-16,r0				;r1 has the buffer size already in it.
}
	
	jmp	dma_go
	ld_s	mdmactl,r0
	nop

clipme:

; this dma strip goes from (dma_xpos) to r0

	sub	clipleft,r0,r28
{
	rts	le						;Reject if RH of span is still offscreen
	sub	clipright,dma_xpos,r29		;check RH side
}
{
	rts	ge						;Reject if LH of span is offscreen
	sub	dma_len,>>#-16,r28						;Will be <0 if clipping needed on the LH side of the span
}

{
	bra	le,lh_dma_clip
	add	dma_len,>>#-16,r29
}		

{
	bra	le,kosher					;if negative, this is fine...
	asr	#16,r28
}
	nop

	sub	dma_len,>>#-16,r29
	abs	r29

{
	push	dmastuff				;cos clipping may piss about with it
	asr	#16,r29,dma_len	;n	
}

    bra eq,pope,nop         ;Traps 0-len DMAs that were happening on RHS-clip

nonkosher:
	
	push	v0,rz
{
;	mv_spr	pc,rz
	jsr	dma_go
}
	ld_s	mdmactl,r0
	nop
	pop	v0,rz	
	nop
pope:

{
;	st_io	dmastuff,(dma_2)		;Blit for a modified linea pixelz
	rts
}
	pop	dmastuff
	nop

lh_dma_clip:


{
	push	dmastuff
	bra	nonkosher
	addm	r28,dma_len,dma_len
	asl	#2,r28
}
{
	mv_s	clipleft,dma_xpos
	sub	r28,dma_base
}
	nop
dma:

{
;	mv_spr	pc,rz
	jsr	dma_go
}
	ld_s	mdmactl,r0
	nop

;{
;	st_io	dmastuff,(dma_2)
;	rts	(rz)
;}
;	nop



; here are the includes for circledraw    

//	.include	"sqrt.s"        ;square roots
//	.include	"recip.s"       ;reciprocals
