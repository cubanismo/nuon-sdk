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

;
;*************************************
;* The real clipping function
;*************************************
;
;
; this "acts" like a subroutine, but actually is included
; inline in the clip.s module (so it doesn't have to execute
; an RTS)
;
; SEE CLIP.S FOR REGISTER DEFINITIONS AND FOR THE
; "lerp" SUBROUTINE
;
; it's "calling conventions" are:
;
; Inputs:
; r0 == pointer to output polygon
; r1 == pointer to input polygon
; r2 == pointer to clipping plane
;
; Output:
; r0 == number of points in clipped polygon
;

clippoly:
	copy	r1,inpptr
	copy	r0,origoutptr
	ld_sv	(r2),clipvector		; get clipping plane

{	ld_v	(inpptr),v0
	add	#16,inpptr
}
	sub	num_out_pts,num_out_pts		; clear number of output points
{	st_v	v0,(origoutptr)
	add	#16,origoutptr,outptr
}
{	mv_s	r3,num_inp_pts
	asl	#5,r3		; multiply number of points by 32 == sizeof(point)
}
	bra	eq,clipreturn	; if number of input points is 0, bail out
	add	inpptr,r3	; branch delay slot #1: make r3 point at end of points
	sub	#32,r3		; branch delay slot #2: make r3 point at the last point

{	ld_v	(r3),v0				; load the last point in the polygon
	copy	r3,lastinpptr		; set lastinpptr to the last point
}
	nop				; wait for the load

	mv_s	#1<<16,r3			; set last component of vector to "1" for dot product
.if HIPRECISION
	mul	clipvector[0],r0,>>#24,r0
	mul	clipvector[1],r1,>>#24,r1
{	mul	clipvector[2],r2,>>#24,r2
	copy	r0,lastdist
}
{	mul	clipvector[3],r3,>>#24,r3
	add	r1,lastdist
}
	add	r2,lastdist
	add	r3,lastdist
.else
	dotp	v0,clipvector,>>#30,lastdist
.endif

;
; for each point in the polygon:
; see if this point is on the "in" (positive) side of the clipping plane
; if so:
;	if the last point was "out" (negative), output a clip point by
;	   interpolating from curpt to lastpt
;	output the current point
; otherwise:
;   if the last point was "in" (positive), output a clip point by
;		interpolating from lastpt to curpt
;
cliploop:
	ld_v	(inpptr),v0			; get current input point
	nop					; wait for load
	mv_s	#1<<16,r3			; set last vector component to 1
.if HIPRECISION
	mul	clipvector[0],r0,>>#24,r0
	mul	clipvector[1],r1,>>#24,r1
{	mul	clipvector[2],r2,>>#24,r2
	copy	r0,curdist
}
{	mul	clipvector[3],r3,>>#24,r3
	add	r1,curdist
}
	add	r2,curdist
	add	r3,curdist
.else
	dotp	v0,clipvector,>>#30,curdist	; find distance to plane
	nop
	cmp		#0,curdist
.endif
	bra		lt,outside
	cmp		#0,lastdist		; branch delay slot #1
	; code for the "inside" of the polygon
	bra		ge,last_was_in,nop	; branch delay slot #2

	; the code here is executed if the current point is inside the polygon
	; but the last point was not
	; linearly interpolate from the current point to the last point
	; and output the result
	bra	lerp
	ld_io	(pcexec),retaddr		; branch delay slot #1
	nop					; branch delay slot #2
	
last_was_in:
{	ld_v	(inpptr),v0			; copy current input point to output
	add		#16,inpptr
}
{	ld_v	(inpptr),v1
	sub		#16,inpptr
}
{	st_v	v0,(outptr)
	bra		botloop
	add		#16,outptr
}
{	st_v	v1,(outptr)			; branch delay slot #1
	add		#16,outptr
}
	add		#1,num_out_pts		; branch delay slot #2: increment number of output points

outside:
	; code for the "outside" of the polygon
	bra		lt,botloop,nop		; last instruction was "cmp #0,lastdist"
						; if lastdist and curdist are both negative,
						; do nothing
	
	; here we have a point that is outside, but the last point was inside
	; interpolate from last point to current point
{	mv_s	lastdist,curdist		; swap lastdist and curdist
	copy	curdist,lastdist		; (this is because "lerp" wants to round
}						;  towards curdist)
{	mv_s	lastinpptr,inpptr		; swap last and current inpptr
	copy	inpptr,lastinpptr
	bra	lerp
}
	ld_io	(pcexec),retaddr
	nop

; restore lastdist and curdist, and inpptr and lastinpptr
{	mv_s	lastdist,curdist		; swap lastdist and curdist
	copy	curdist,lastdist		; (this is because "lerp" wants to round towards
}									;  curdist)
{	mv_s	lastinpptr,inpptr		; swap last and current inpptr
	copy	inpptr,lastinpptr
}


botloop:
; bottom of clipping loop
	sub		#1,num_inp_pts
{	bra		gt,cliploop
	mv_s	curdist,lastdist
}
	mv_s	inpptr,lastinpptr		; branch delay slot #1
	add	#32,inpptr			; branch delay slot #2

clipreturn:
	add	#12,origoutptr
	st_s	num_out_pts,(origoutptr)	; update number of points in output polygon
	copy	num_out_pts,r0

