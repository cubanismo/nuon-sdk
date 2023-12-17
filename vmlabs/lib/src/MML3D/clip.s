/*
 * Copyright (C) 1995-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

;; set to 1 for 32 bit clip distance calculation
HIPRECISION = 1

;
; minimum Z valuie
;

MIN_Z = 4

	;
	; 3D pipeline -- clipping code
	; Version 1.0 for C
	;
	; local storage required:
	;	standard amount
	; stack required:
	;	LOTS!!!
	;

	;
	; this module contains both the "calcclip" routine
	; (which calculates clipping codes for a vertex)
	; and the "clip" routine (which actually does
	; clipping of a polygon to the viewing frustum)
	;

	.module calcclip
	.include "pipeline.i"
	.export	_calcclip_init, _calcclip_end
	
	;
	; local storage
	;
	; for the clipping planes: 
	;     NUMCLIPS small vectors at 2 longs each
	;
	
	NUMCLIPS = 5
	.export clipplanes
	clipplanes = clip_data
	
	.align CODEALIGN
;************************************************************************
;* _calcclip_init: calculate clipping planes for camera
;* Inputs:
;*      r0 == pointer to ourselves
;* Outputs:
;*	r0 == pointer to calcclip function
;*
;* Working variables:
;*	r0 = pointer to output clipping planes
;*	r1 = pointer to camera structure
;*	r2 = number of clipping planes (either 5 or 6)
;*
;* Output:
;*	area pointed to by r0 is overwritten by the clipping planes
;*  appropriate for this camera
;*	each clipping plane is a small vector P such that P*(x,y,z,1) >= 0 iff
;*  (x,y,z) is on the visible side of the plane.
;*  the clipping planes are calculated in the order
;*     z >= 1
;*     x >= 0
;*     x < width
;*     y >= 0
;*     y < height
;*     z < back
;*
;* It is important that the z>=1 clipping plane come first, since if a polygon
;* needs clipping against this plane, it is very likely that the resulting
;* (clipped) polygon will have to be clipped against all other planes.
;*
;************************************************************************

outptr	=	r0
numplanes =	r1
temp0  =        r2
	
; v1 holds the plane being built
Vplane	=	v1
planex	=	r4
planey	=	r5
planez	=	r6
planed	=	r7

; v2 and v3 hold miscellaneous stuff
; v2 need not be saved; v3 must be
Vmisc1	=	v2
miny	=	r8	; 16.16 values
maxy	=	r9
minx	=	r10
maxx	=	r11

Vmisc2	=	v3
xcenter	=	r12
ycenter	=	r13
focald	=	r14
maxz	=	r15


	
_calcclip_init:
	rts
	mv_s	#calcclip-_calcclip_init,r1
	add	r1,r0

	;************************************************************************
	;*
	;* calcclip: calculate outcodes for clipping test
	;* Inputs:
	;*	r0 = pointer to vertex to check
	;*
	;* Output:
	;*	r0 = outcode bits; bit N will be set if the vertex lies on the negative side of
	;*		the Nth clipping plane (starting at 0)
	;*
	;* Each clipping plane consists of 4 words, (px,py,pz,pd), where (px,py,pz) are
	;* 16.0 fixed point numbers, and pd is a 16.0 fixed point number. The plane's
	;* equation is px*X + py*Y + pz*Z + pd = 0.
	;*
	;* Internal register usage:
	;*      r1 = pointer to current clipping plane to load
	;*	r2 = number of clipping planes
	;*
	;* v1 = holds current clipping plane
	;* v2 = holds vertex (X,Y,Z,1)
	;*
	;************************************************************************
calcclip:
	;
	; initialize counters, etc.
	;
	mv_s	#clipplanes + NUMCLIPS*8,r1
{	st_s	#NUMCLIPS,rc0	; save count of planes to check
	sub	r2,r2		; zero r2
}
{	push	v2
}
	ld_v	(r0),v2		; load input vertex
{	sub	#8,r1			; move back 1 clipping plane
}
{	mv_s	#(1<<16),r11		; set last element of v2 to a constant 1 (in 16.16 format)
	sub	r0,r0			; zero output codes
}

; loop over input planes
	ld_sv	(r1),v1			; load clipping plane
	add	#31,r2			; set r2 to 31, and wait for ld_sv to complete

{	dotp	v1,v2,>>#30,r3
	dec	rc0
	sub	#8,r1			; move back 1 clipping plane
}
_cliplp:
{	ld_sv	(r1),v1			; load the next clipping plane
	bra	c0ne,_cliplp
	sub	#8,r1			; move back 1 clipping plane
}
	asl	#1,r0
{	dotp	v1,v2,>>#30,r3
	dec	rc0
	or	r3,>>r2,r0		; branch delay slot #1
}

_endcliplp:
{	pop	v2
	rts	nop
}
	
_calcclip_end:


;****************************************************************************
;****************************************************************************

	; doclip module: clips a polygon against all clipping planes
	; inputs: r0 == pointer to polygon
	;         r1 == "or" of all clipping planes
	;
	; stack used:
	
	.module doclip
	.include "pipeline.i"
	.import clipplanes
	.export _doclip_init, _doclip_end

; registers used: v0-v6

; v0-v2 don't have to be saved
num_inp_pts	=	r8			; number of input points
num_out_pts	=	r9			; number of output points
lastdist	=	r10			; distance of last point to plane
curdist		=	r11			; distance of current point to plane

; v3 - v6 do need to be saved

; registers for top level loop
regs1		=	v3
orclips		=	regs1[0]		; OR of all clip codes
polyptr		=	regs1[1]		; pointer to input polygon
altpoly		=	regs1[2]		; pointer to output polygon
tempptr		=	regs1[3]		; temporary pointer
	
regs2		=	v4
inpptr		=	regs2[0]		; current pointer for input points
origoutptr	=	regs2[1]		; points to the start of the output polygon
outptr		=	regs2[2]		; points to the current location of output
lastinpptr	=	regs2[3]		; points to the previous input point

clipvector	=	v5

regs3		=	v6			; some free registers
retaddr		=	regs3[0]		; return address for "lerp"
ratio		=	regs3[1]		; ratio for linear interpolation
recipfunc	=	regs3[2]		; address of reciprocal function
notsaved	=	regs3[3]		; not saved in the subroutine


	; local data storage
old_sp	=	doclip_data
origpoly =	doclip_data + 4

	.align CODEALIGN
_doclip_init:
	rts
	mv_s	#doclip-_doclip_init,r1
	add	r1,r0

doclip:
	push	clipvector
	push	regs1
	push	regs2
	push	regs3,rz
	
{	copy	r0,polyptr	; save original pointer
	ld_s	recip_func,recipfunc
}
{	copy	r1,orclips	; save "OR" of clipping codes
	ld_s	extra_data_ptr,altpoly
}
	; allocate enough space on the stack for a polygon
	; we provide room for 9 points; this is enough for a triangle clipped
	; against every one of 6 clipping planes, or a quadrilateral clipped
	; against 5 planes (no back plane provided)
	; each point is two vectors (8 longs)
	; so storage required is up to: 4 + 9*8 == 76 longs

	st_s	polyptr,origpoly
	;; NOTE: we assume that "altpoly" is on a vector boundary
	
	;
	; first: check for clipping against z >= 1; if that plane needs clipping,
	; all the others may, too (even if their clip codes are not explicitly set)
	;
	btst	#0,orclips
{	bra	eq,docliploop,nop
	mv_s	#clipplanes,tempptr	; initialize tempptr to point to first clipping plane
}
	
	mv_s	#$1f,orclips		; set all planes to be clipped

	; for each clipping plane, see if the corresponding bit in "orclips" is
	; set; if it is, clip against that plane

docliploop:
	btst	#0,orclips
	bra	eq,notthisplane,nop
	mv_s	altpoly,r0			; parameter: output polygon
	copy	polyptr,r1			; parameter: input polygon
	mv_s	tempptr,r2			; parameter: ptr to plane to clip against

	.include "doclip.i"	; "subroutine" that does the actual clipping

	; now that we're done clipping, swap pointers so the new output polygon
	; (the properly clipped one) becomes input next time we clip
{	mv_s	polyptr,altpoly
	copy	altpoly,polyptr
}

notthisplane:
	lsr	#1,orclips		; move flags to next plane
{	bra	ne,docliploop,nop	; if there are more planes needing clipping, orclips will be nonzero
	add	#8,tempptr		; move to next plane
}


	; now we're done clipping -- see if the polygon needs to be
	; copied back to its original place
	ld_s	origpoly,r0
	nop
	cmp	polyptr,r0
	bra	eq,nocopy,nop

	; copy the whole polygon from "polyptr" to "origpoly" (== altpoly)
	ld_v	(polyptr),v0
	add	#16,polyptr
{	st_v	v0,(altpoly)
	add	#16,altpoly
}
	; now the number of points is in r3
	; each point is 2 vectors
	st_io	r3,rc1

copy_loop:	
{	ld_v	(polyptr),v0
	add	#16,polyptr
	dec	rc1
}
{	ld_v	(polyptr),clipvector
	add	#16,polyptr
	bra	c1ne,copy_loop
}
{	st_v	v0,(altpoly)
	add	#16,altpoly
}
{	st_v	clipvector,(altpoly)
	add	#16,altpoly
}

nocopy:
	; return from the subroutine
	pop	regs3,rz
	pop	regs2
{	pop	regs1
	rts
}
	pop	clipvector
	nop


;******************************************
;* Subroutine: linearly interpolate between
;* the points given by inpptr and lastinpptr
;* (rounding towards inpptr)
;* It is assumed that lastdist < 0 and curdist >= 0
;*
;* Output is written to outptr
;*
;* the scaling ratio is abs(curdist)/(abs(curdist)+abs(lastdist))
;* i.e. curdist/(curdist-lastdist)
;*

lerp:
	jsr	(recipfunc)
	mv_s	#16,r1			; assume 16.16 numbers (it's going to be a ratio,
	sub	lastdist,curdist,r0	; so it doesn't matter)


	sub	#(30-16),r1		; wait for recip to finish
	mul	curdist,r0,>>r1,r0	; find the ratio (it will have 30 fracbits)
{	ld_v	(lastinpptr),v1
	add	#16,lastinpptr
}
{	ld_v	(inpptr),v0
	copy	r0,ratio
}
	add	#16,inpptr

; do the linear interpolation
; vector subtract sub_v v0,v1
; NOTE: acshift == 30
	
	sub	r0,r4
{	mul	ratio,r4,>>acshift,r4
	sub	r1,r5
}
{	mul	ratio,r5,>>acshift,r5
	sub	r2,r6
}
{	mul	ratio,r6,>>acshift,r6
	sub	r3,r7
}
{	mul	ratio,r7,>>acshift,r7
	add	r4,r0
}
	add	r5,r1
{	addm	r6,r2,r2
	add	r7,r3
}
{	st_v	v0,(outptr)
	add	#16,outptr
}
{	ld_v	(lastinpptr),v1
	sub	#16,lastinpptr
}
	ld_v	(inpptr),v0
	sub	#16,inpptr

	sub	r0,r4
{	mul	ratio,r4,>>acshift,r4
	sub	r1,r5
}
{	mul	ratio,r5,>>acshift,r5
	sub	r2,r6
}
{	mul	ratio,r6,>>acshift,r6
	sub	r3,r7
}
{	mul	ratio,r7,>>acshift,r7
	add	r4,r0
}
{	add	r5,r1
}
{	addm	r6,r2,r2
	jmp	(retaddr)
	add	r7,r3
}
{	st_v	v0,(outptr)			; branch delay slot #1
	add	#16,outptr
}
	add	#1,num_out_pts		; branch delay slot #2


_doclip_end:
	