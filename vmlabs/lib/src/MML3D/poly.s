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

PIXBUF_LEN = 16
	;
	; 3D pipeline -- polygon draw code
	; Version 1.0 for C
	;

	; polygon.s
	;
	; code for drawing polygons
	; the type of the polygon is encoded in the 2nd and 3rd
	; long words of the polygon structure; the second word
	; is the "type", and the third is the "subtype"
	;
	; for now, "type" is set up as follows:
	; low bit: == 1 if this is a cachable texture
	;
	;


	.module	poly_s
	.include "pipeline.i"
	.include "drawregs.i"	

	.export	_drawpoly_init, _drawpoly_end

	;
	; local storage
	;
	_DS_delta1 = polygon_data
	_DS_delta2 = polygon_data + 16
	_DS_step1 = polygon_data + 32
	_DS_step2 = polygon_data + 48
	
	_DS_lbuflen = polygon_data + 64
	_DS_trapfn = polygon_data + 68
	cur_poly = polygon_data + 72
			
	;
	; v3 is reserved for upper level stuff
	;
	_D_VTRI	=	v3	
	_D_A	=	r12
	_D_B	=	r13
	_D_C	=	r14
	_D_T	=	r15

	; _D_VTRI2 is re-used for _D_VDMA and is corrupted by subroutine calls
	_D_VTRI2 =	v1		; (NOTE: do NOT use v0 for D_VTRI2!)
	_D_ay	=	r4
	_D_by	=	r5
	_D_cy	=	r6

	;**********************************************
	;* polygon drawing initialization function
	;* parameters:
	;* r0 == address of drawpoly_init
	;*
	;* output:
	;* r0 == address of polygon draw function
	;* 
	;* sets up _DS_blitblock DMA command block
	;* for doing DMA to the screen
	;* also sets up (xy) base addressing to point to
	;* the internal memory buffers
	;***********************************************

	.align CODEALIGN
	
_drawpoly_init:
	; set up:	
	;* r0 == base of screen
	;* r2 == pixel write mode & flags for DMA
	push	v0
	ld_s	dest_base_addr,r5
	ld_s	dest_dma_flags,r4
	sub	r3,r3			; zero r3
	
	mv_s	#pix_linebuf1,r7	; internal address
	
	;
	; figure out the width of the buffers in pixels
	; each pixel is assumed to be 32 bits (4 bytes),
	; except for pixel type 6 (32 bit Z + 32 bit pixel)
	; which is 64 bits. This assumption is wrong for
	; type 2 (16 bit pixels, no Z), but it doesn't
	; hurt us
	;
	;
	; at the same time, we need to figure out the MPE pixel
	; type based upon the output DMA pixel mode. Here are the
	; possibilities:
	;  DMA pixel mode    MPE pixel mode
	;     1, 3           modes 1,3:  4,8 bit pixels (INVALID)
	;     2              mode 2:  16 bit pixels
	;     4              mode 4:  32 bit pixels
	;     5              mode 5:  16 bit + 16 bit Z
	;     6              mode 6:  32 bpp + 32 bit Z
	;     7              mode 4:  Z only (INVALID)
	;     8              mode 4:  32 bpp -> 16 bpp conversion
	;     9-11           mode 5
	;     13,14          mode 5
	;     12,15          mode 5, Z only (INVALID)
	
	asr	#4,r4,r2		; isolate pixel type
	and	#$f,r2

	; now test various values for the pixel type -- we assume that
	; higher level software has filtered out the INVALID values
{	cmp	#6,r2
	mv_s	#PIXBUF_LEN,r6		; default length
}
	bra	ne,notmode6,nop
{	bra	setpixlen,nop
	asr	#1,r6			; 2 long words per pixel
}
notmode6:

.if 0
	;; mode 2 is illegal, since st_p doesn't work for it	
	cmp	#2,r2
	bra	ne,notmode2,nop
{	bra	setpixlen,nop
	asl	#1,r6			; 2 pixels per long word
}
notmode2:
.endif
	cmp	#4,r2
	bra	eq,setpixlen,nop

notmode4:

	; default MPE mode is mode 5 (16 bpp + 16 bit Z)
	mv_s	#5,r2
	
setpixlen:
	rot	#(32-20),r2
	or	r2,r3
{	or	#1,<>#(32-28),r3	; set chrominance normalization
	st_s	r6,_DS_lbuflen		; save pixel buffer length
}
{	st_s	r7,pixdmacmd+16
	or	r6,r3
}
	st_s	r3,xyctl
	pop	v0
	st_v	v1,pixdmacmd		; set up flags & base address
	st_s	r7,xybase		; set (xybase) to internal address

	; figure out address of "textrap" routine
	mv_s	#textrap - _drawpoly_init,r1
	add	r0,r1
{	rts
	st_s	r1,_DS_trapfn
}
	mv_s	#polygon - _drawpoly_init,r1	; return address of polygon draw routine
	add	r1,r0


	;*******************************************************
	; subroutine for recalculating left side step values
	;
	; INPUTS
	;     r0 = # of lines to draw (difference between top and bottom y values)
	;     r1 = pointer to top point structure
	;     r2 = pointer to bottom point structure
	;     r3 = return address
	;********************************************************

triangle_calcleftside:
	push	v1
; initialize -- get topmost left side values
{	ld_s	(r1),_D_lx
	add	#8,r1		; skip x, y
}
{	ld_s	(r1),_D_v	; load *Z*, but keep it in V temporarily (see below)
	add	#4,r1
}
{	ld_s	(r1),_D_u	; load u
	add	#4,r1
}
{	ld_v	(r1),_D_VI	; load i0,i1,i2, and v components (but v is in _D_z)
	copy	r3, _D_T	; save return address
}
; get lower left side values
{	ld_s	(r2),_D_dlx
	add	#8,r2		; skip x, y
}
{	ld_s	(r2),_D_dv	; load *Z*, but keep it in V temporarily (see below)
	add	#4,r2
}
	ld_s	recip_func,r1	; get address of "recip" function
{	ld_s	(r2),_D_du	; load u
	subm	_D_lx,_D_dlx,_D_dlx
	add	#4,r2
}
{	ld_v	(r2),_D_VdI		; load i0,i1,i2, and v components (but v is in _D_dz)
	jsr	(r1)			; r1 == reciprocal function from above
	sub	r1,r1			; set r1 to 0
}
	subm	_D_u,_D_du,_D_du	; branch delay slots!!!
	add	#16,r1			; indicate that r0 is a 16.16 fixed point number

; now r0 holds 1/r0, and r1 is updated to hold fracbits(r0)

; swap v and z values since we want z to be in the same vector as the
; intensity components; st_p uses them that way

{	mv_s	_D_dv,_D_dz		; note that r0 is unusable here!!!
	copy	_D_dz,_D_dv
}
{	mul	r0,_D_dlx,>>r1,_D_dlx
	mv_s	_D_v,_D_z
	copy	_D_z,_D_v
}
{	mul	r0,_D_du,>>r1,_D_du
	sub	_D_i0,_D_di0
}
{	mul	r0,_D_di0,>>r1,_D_di0
	sub	_D_i1,_D_di1
}
{	mul	r0,_D_di1,>>r1,_D_di1
	sub	_D_i2,_D_di2
}
{	mul	r0,_D_di2,>>r1,_D_di2
	sub	_D_v,_D_dv
}
{	jmp	(_D_T)				; return to caller
	pop	v1
}
{	mul	r0,_D_dv,>>r1,_D_dv
	sub	_D_z,_D_dz
}
{	mul	r0,_D_dz,>>r1,_D_dz		; NOTE: _D_dz will not be usable in the caller
}						; until another tick goes by!!!!!


;*
;* Polygon drawing subroutine
;*
;* parameters: r0 == pointer to polygon struct
;*
;*
;* polygon data structure:
;*  16 byte header:
;*    +0 == reserved, set to 0
;*    +4 == reserved, set to 0
;*    +8 == pointer to texture map
;*   +12 == pointer to number of points
;*
;*
;* register usage:
;* _D_T = number of points
;* _D_A = top point
;* _D_B = right side point
;* _D_C = left side point
;*
	;*
	;* this subroutine works by subdividing the polygon up into
	;* triangles
	;*
	
PT_SIZE	=	32		; 8*4 bytes

	.export polygon
polygon:
	push	v0,rz			; save rz

{	st_s	r0,cur_poly		; save pointer to current polygon  
	add	#12,r0,_D_A		; set _D_A to point to number of points
}
	
	ld_s	_DS_trapfn,_D_trapfn
		
	ld_s	(_D_A),_D_T		; get number of points into _D_T
	add	#4,_D_A			; _D_A points at first point

	sub	#3,_D_T				; three points minimum for a polygon
	bra	lt,polygon_return	; if # of points is <
	add	#PT_SIZE,_D_A,_D_B	; _D_B points at second point
	add	#PT_SIZE,_D_B,_D_C	; _D_C points at third point
	
;
; polygon decomposition loop
;

polygonlp:
	push	v0
	push	_D_VTRI

;**********************************************************
;* triangle draw routine
;* Inputs:
;* _D_A = pointer to point A
;* _D_B = pointer to point B
;* _D_C = pointer to point C
;* _D_Vfns are set up appropriately
;**********************************************************

triangle:
; push volatile registers, save rz
{
	add	#4,_D_A			; point to the Y field
}

; fetch Y values for the 3 points
{	ld_s	(_D_A),_D_ay
	add	#4,_D_B
}
{	ld_s	(_D_B),_D_by
	add	#4,_D_C
}
{	ld_s	(_D_C),_D_cy
	sub	#4,_D_A				; restore _D_A
}
;
; find which point has the smallest Y coordinate, i.e. which
; is topmost
;
	cmp	_D_ay,_D_by
	bra	ge,triangle_testC
	sub	#4,_D_B				; branch delay slot #1
	sub	#4,_D_C				; branch delay slot #2

	cmp	_D_cy,_D_by			; test value of by-cy
	bra	ge,triangle_testC,nop

;
; at this point, B is the topmost point, so re-label them appropriately
;
{	mv_s	_D_A,_D_T
	copy	_D_B,_D_A
}
{	mv_s	_D_C,_D_B
	copy	_D_T,_D_C
}
{	mv_s	_D_ay,_D_T
	bra	triangle_donesort
	copy	_D_by,_D_ay
}
	mv_s	_D_cy,_D_by			; branch delay slot #1
	copy	_D_T,_D_cy			; branch delay slot #2


triangle_testC:
	cmp	_D_ay,_D_cy		; test value of cy-ay
	bra	ge,triangle_donesort,nop

;
; at this point, C is the topmost point, so re-label them appropriately
;
{	mv_s	_D_A,_D_T
	copy	_D_C,_D_A
}
{	mv_s	_D_B,_D_C
	copy	_D_T,_D_B
}
{	mv_s	_D_ay,_D_T
	copy	_D_cy,_D_ay
}
{	mv_s	_D_by,_D_cy
	copy	_D_T,_D_by
}

triangle_donesort:
	
;*
;* calculate values for delta registers
;* the algorithm used comes from Graphics Gems, p. 361
;* ("Scanline Depth Gradient of a Z-Buffered Triangle")
;* This is numerically unstable for very thin triangles,
;* but it will do for now.
;*

; some register re-use
_D_deltaly	=	_D_topy
_D_deltary	=	_D_boty
_D_deltalx	=	_D_lx
_D_deltarx	=	_D_rx
_D_fbits	=	_D_u
_D_fbits2	=	_D_v
	mv_s	#$ffff0000,r1
	and	r1,_D_ay
	and	r1,_D_by
	and	r1,_D_cy
	
{	ld_s	(_D_A),_D_T		; get A's x value (16.16 format)
	sub	_D_ay,_D_by,_D_deltary
}
{	ld_s	(_D_B),_D_deltarx	; get B's x value (16.16 format)
	sub	_D_ay,_D_cy,_D_deltaly
}
{	ld_s	(_D_C),_D_deltalx	; get C's x value (16.16 format)
	msb	_D_deltaly,r0
}
{	subm	_D_T,_D_deltarx
	sub	#30,r0
}

	;;; normalize _D_deltaly and _D_deltarx
	msb	_D_deltarx,r1
	add	r0,r1,r2

	;; _D_deltaly was 16.16; now it is (16+r0).(16-r0)
	;; similarly for _D_deltarx
	;; the final result will have:
	;; (16-r0) + (16-r1) - 30 fractional bits
	
{	mul	_D_deltarx,_D_deltaly,>>r2,_D_deltaly
	add	r1,r0
}
	sub	r0,#32,r0		; now r0 is the exponent for _D_deltaly
	
	;; normalize _D_deltary and _D_deltalx
{	msb	_D_deltary,r1
	subm	_D_T,_D_deltalx
}
	msb	_D_deltalx,r2
	sub	#30,r2
	add	r1,r2,r3
	
{	mul	_D_deltalx,_D_deltary,>>r3,_D_deltary
	add	r2,r1
}
	sub	r1,#32,r1		; now r1 is the exponent for _D_deltary
		
	; now subtract _D_deltary from _D_deltaly
	; figure out which is the bigger exponent
	sub	r1,r0,r2
	bra	ge,`use_r2,nop
{	sub	r0,r1,r0
	mv_s	r0,r1
}
{	as	r0,_D_deltary
	mv_s	#0,r2
}
`use_r2:
{	as	r2,_D_deltaly
	ld_s	recip_func,r2			; pre-load address of reciprocal
}
	sub	_D_deltary,_D_deltaly,r0	; if difference of results <= 0,
	bra	le,triangle_return,nop		; backface cull this triangle

{	jsr	(r2)				; find 1/r0
}
	push	_D_VTRI2
	add	#8,_D_A				; skip over X and Y for point A
						; (the rest of the skips happen below)

; now r0 has the scaling factor for all the delta values
; and r1 has the fractional bits of r0

{	pop	_D_VTRI2
	bra	triangle_alldeltas
}
	add	#8,_D_B		; skip over X and Y for point B
	add	#8,_D_C		; skip over X and Y for point C

;
; subroutine: calculate deltaX, where X is the next value
; pointed to by _D_A, _D_B, and _D_C. This subroutine
; is called as often as necessary. Its inputs are:
; r0 == scaling factor (calculated above, don't mess with
;		it)
; r1 == fractional bits in scaling factor
; r2 == offset to next quantity in structure;
;		(on the last call, make this negative to reset pointers to the
;		beginning)
; r3 == return address
;
; its output is _D_T == calculated quantity

triangle_nextdelta:
{	ld_s	(_D_A),_D_T
	add	r2,_D_A			; move to next quantity
}
{	ld_s	(_D_C),_D_deltalx
	add	r2,_D_C
}
{	ld_s	(_D_B),_D_deltarx
	add	r2,_D_B
}
{	subm	_D_T,_D_deltalx,_D_fbits
	sub	_D_T,_D_deltalx
}
{	subm	_D_T,_D_deltarx,_D_fbits2
	abs	_D_fbits
}
{	subm	_D_T,_D_deltarx,_D_deltarx
	abs	_D_fbits2
}
	or	_D_fbits2,_D_fbits
{	subm	_D_ay,_D_cy,_D_deltaly
	msb	_D_fbits,_D_fbits
}

{	mul	_D_deltarx,_D_deltaly,>>_D_fbits,_D_deltaly
	sub	_D_ay,_D_by,_D_deltary
}
{	mul	_D_deltalx,_D_deltary,>>_D_fbits,_D_deltary
	sub	#16,_D_fbits
}
{	jmp	(r3)
	sub	_D_fbits,r1,_D_fbits			; wait for multiply to finish
}
	sub	_D_deltary,_D_deltaly,_D_T
	mul	r0,_D_T,>>_D_fbits,_D_T

;;; NOTE: _D_T isn't going to be ready until 1 tick *after* the subroutine finishes

triangle_alldeltas:
; first calculate deltaZ
{	bra	triangle_nextdelta
	mv_s	#4,r2
}
	ld_io	pcexec,r3
	nop

	bra	triangle_nextdelta
{	copy	_D_T,_D_dz		; branch delay slot, executed before subroutine call
	ld_io	pcexec,r3
}
	nop

	bra	triangle_nextdelta
{	copy	_D_T,_D_du		; branch delay slot, executed before subroutine call
	ld_io	pcexec,r3
}
	nop

	bra	triangle_nextdelta
{	copy	_D_T,_D_di0		; branch delay slot, executed before subroutine call
	ld_io	pcexec,r3
}
	nop

	bra	triangle_nextdelta
{	copy	_D_T,_D_di1		; branch delay slot, executed before subroutine call
	ld_io	pcexec,r3
}
	nop

{	mv_s	#-28,r2			; move _D_A,_D_B,_D_C back to the start of the
	bra	triangle_nextdelta
}
{	copy	_D_T,_D_di2		; branch delay slot, executed before subroutine call
	ld_io	pcexec,r3
}
	nop


	mv_s	_D_T,_D_dv		; get the final delta result

	;; finished now with delta calculations
	;; now call the per-polygon pixel initialization
	;; function
	ld_s	pixel_func,r0
	ld_s	cur_poly,r1
	jsr	(r0)
	push	_D_VTRI2
	nop

	pop	_D_VTRI2
	copy	r0,_D_pixelfn
	
	
;*
;* Two cases now:
;*		 A			  A
;*	(I)	C    if by < cy, or (II)   B otherwise
;*	   	  B			 C
;*
{	cmp	_D_cy,_D_by		; if (by-cy <= 0) goto CASEII
	st_v	_D_VdX,_DS_delta1	; save first set of delta values
}
{	bra		le,triangle_CASEII
}
	ld_s	recip_func,r1		; pre-load address of reciprocal function
	st_v	_D_VdI,_DS_delta2	; save second set of deltas




;CASEI:
; find reciprocal of by-ay as a 4.28 bit number
{
	push	_D_VTRI2		; save ay,by,cy
	jsr	(r1)			; loaded with recip function address above
}
	mv_s	#16,r1			; 16.16 input to recip
	sub	_D_ay,_D_by,r0		; branch delay slot, always executed

;
; right side goes from A to B, always
;
	pop		_D_VTRI2
	ld_s	(_D_A),_D_rx		; load up right X value
{	ld_s	(_D_B),_D_drx		; and prepare to calculate the step
; r0 now contains the slope; convert it to 4.28 format
	sub		#28,r1
}
	as		r1,r0				; now r0 is the 4.28 slope

;
; first trapezoid: left side goes from A to C
; (calculation of right step value interleaved with setup for
; left side calculations)
;

{	mv_s	_D_ay,_D_topy
	sub	_D_rx,_D_drx
}
{	mul	r0,_D_drx,>>#28,_D_drx
	sub	_D_ay,_D_cy,r0	; now r0 == # of lines to draw
}
	bra	le,triangle_skipdraw1	; if # of lines to draw is <= 0, skip the draw
	mv_s	_D_cy,_D_boty		; branch delay slot, always executed
	nop


{	bra	triangle_calcleftside
	mv_s	_D_A,r1			; parameters for calcleftside:
	copy	_D_C,r2			; r1 = top left, r2 = bottom left
}
	ld_io	pcexec,r3
;;	nop

	jsr	(_D_trapfn)
	nop
	nop

triangle_skipdraw1:
;
; second trapezoid: left side goes from C to B
;
	sub	_D_cy,_D_by,r0		; set r0 = # of lines
	bra	le,triangle_return
{	mv_s	_D_cy,_D_topy
	copy	_D_by,_D_boty
}
{					; this is a branch delay slot for the previous branch
	bra	triangle_calcleftside	; so THIS branch will be skipped if the above one is taken

	mv_s	_D_C,r1			; r1 = top left
	copy	_D_B,r2			; r2 = bottom left
}
	ld_io	pcexec,r3
	nop


	jsr	(_D_trapfn)		; actually draw the trapezoid
	nop
	nop

	bra	triangle_return,nop

;
;
;
;

triangle_CASEII:
	sub	_D_ay,_D_cy,r0		; r0 = # of lines on left side
{	bra	le,triangle_return,nop	; if # of lines is <= 0, skip this entirely
	mv_s	_D_A,r1			; r1 = top left point
	copy	_D_C,r2			; r2 = bottom left point
}

{	bra	triangle_calcleftside	; calculate step values for left hand side
	mv_s	_D_ay,_D_topy
	copy	_D_by,_D_boty
}
	ld_io	pcexec,r3		; get return address
	nop

;
; calculate right side step values for top trapezoid
;
{	sub	_D_topy,_D_boty,r0	; r0 = # of lines on right side
	ld_s	recip_func,r1		; pre-load reciprocal function address
}
{	ld_s	(_D_A),_D_rx
	bra	le,triangle_skipdraw3	; if # of lines is <= 0, don't draw trapezoid
}
	ld_s	(_D_B),_D_drx
	nop

{	push	_D_VTRI2		; save ay,by,cy
	jsr	(r1)			; r1 == address of reciprocal function
}
	mv_s	#16,r1			; set up for a 16.16 number
	sub	_D_rx,_D_drx		; branch delay slot: find difference in rightx


; r0 now has the reciprocal of the # of lines
; and r1 has the fracbits for it
{	pop	_D_VTRI2
	jsr	(_D_trapfn)				; draw the trapezoid
}
	mul	r0,_D_drx,>>r1,_D_drx
	nop

triangle_skipdraw3:
;
; calculate right side step values for bottom trapezoid
;
{	ld_s	(_D_B),_D_rx
	copy	_D_by,_D_topy
}
	sub	_D_by,_D_cy,r0			; r0 = # of lines to draw
{	bra	le,triangle_return		; if # of lines is <= 0, quit
	ld_s	recip_func,r1			; pre-load reciprocal function address
}
	ld_s	(_D_C),_D_drx
	copy	_D_cy,_D_boty


{	push	_D_VTRI2		; save ay,by,cy
	jsr	(r1)			; find reciprocal of # of lines
}
	mv_s	#16,r1			; branch delay slot
	sub	_D_rx,_D_drx		; branch delay slot: calculate delta right x



	pop	_D_VTRI2
        nop
; r0 now has the reciprocal of the # of lines
; r1 has its fracbits
{	jsr	(_D_trapfn)		; draw the trapezoid
}
	mul	r0,_D_drx,>>r1,_D_drx	; branch delay slot
	nop

triangle_return:

	pop	_D_VTRI
	pop	v0			; wait for pop of _D_VTRI to complete

	sub	#1,_D_T
	bra	ge,polygonlp
	mv_s	_D_C,_D_B		; current left side becomes new right side
	add	#PT_SIZE,_D_C		; and move to the next right side


polygon_return:
	pop		v0,rz
	nop
	rts
	nop
	nop


;*****************************************
;* non-antialiased trapezoid draw routine
;*****************************************

textrap:
{	push	v3
}

;******* BUG FIX: we must wait for DMA to be finished before starting a new
;******* line
;******* the double-buffer test below would take care of this if we kept ry and the
;        buffer address up to date across calls to textrap; since we don't, though,
;        we need to wait here
bugfix0:
        ld_io   mdmactl,v3[0]		; get DMA control registers
	nop				; wait for ld_io to finish
        bits    #4,>>#0,v3[0]		; check for dma completed
        bra     ne,bugfix0,nop	; not completed yet, keep waiting

	push	v1,rz
{	st_v	_D_VdX,_DS_step1		; save step values
	asr	#16,_D_boty
}
{	st_v	_D_VdI,_DS_step2
	copy	_D_topy,_D_dmay			; save Y location counter
}
; calculate number of lines to render
{	mv_s	#(pix_linebuf2-pix_linebuf1),_D_temp1	; this slot happens to be free
	asr	#16,_D_topy
}
{	mv_s	#(1<<16),_D_dmaylen
	sub	_D_topy,_D_boty			; now "boty" has count of lines to render
}
{
	bra	le,textrap_endouterlp		; if <= 0 lines to render, bail out
	st_s	#0,ry				; start on buffer 0
	subm	_D_topy,_D_topy,_D_topy		; zero _D_topy
}
	ld_s	_DS_lbuflen,_D_maxdmalen	; set max. dma length
{	st_s	_D_boty,rc0			; rc0 is outer loop counter (# of lines)
	subm	_D_boty,_D_boty,_D_boty		; zero _D_boty
}


;
; some constants:
; from now on in the code:
; _D_topy contains the address of the internal buffer (and is called _D_intbuf)
; _D_boty contains the amount (either +1 or -1) to add to ry to go to the
;		next line; this is a 16.16 number
; _D_temp1 contains the amount to add to _D_dmaint to get the start of the
;		line buffer

_D_intbuf	=	_D_topy

{
	mv_s	#pix_linebuf1,_D_intbuf
	add	#1,>>#-16,_D_boty
}
	mv_s	_D_rx,_D_linelen

; calculate number of pixels in this line
{	ld_v	_DS_delta1,_D_VdX			; load delta values for inner loop
	asr	#16,_D_linelen
}
	asr	#16,_D_lx,_D_temp0

textrap_outerlp:
	sub	_D_temp0,_D_linelen			; set linelen = count of pixels to render
{	ld_v	_DS_delta2,_D_VdI			; load delta values for inner loop
	bra	le,textrap_endinnerlp		; if linelen <= 0, skip inner loop
}
; branch delay slots; set up registers for inner loop
	push	_D_VI						; save intensity, we're going to muck with it
	copy	_D_lx,_D_dmax


	push	_D_VX					; save u and v registers, they'll be modified
							; across the scan line

textrap_dmalp:

; at this point _D_linelen has the number of pixels to write for this line
; set _D_dmaxlen to the lesser of this and _D_maxdmalen
; simultaneously, load up r0 with the DMA control register, so that
; we can test how many DMA's are still outstanding
{	ld_io	mdmactl,r0
	cmp	_D_linelen,_D_maxdmalen
}
{	bra	ge,textrap_start
	st_io	#0,rx
}
	st_s	_D_linelen,rc1
	copy	_D_linelen,_D_dmaxlen

{	st_s	_D_maxdmalen,rc1
	copy	_D_maxdmalen,_D_dmaxlen
}

textrap_start:
;
; DOUBLE BUFFERING: we have to make sure that at most 1 DMA is active;
; otherwise, as we create a new buffer of pixels we may end up trashing
; a buffer that DMA is using.
; we loaded up r0 with the mdmactl register earlier, now we check to make sure
; there are only 0 or 1 transfers in progress
; while we're at it, we'll also make sure the "pending" bit is clear. This will
; guarantee that we can write out a DMA command later on, since pending won't
; be set again until after the next DMA. There is a slight inefficiency here,
; because in theory we could prepare the buffer for DMA before pending drops
; (pending only prevents us from writing the DMA control registers), but in
; practice if there are only 0 or 1 DMAs in progress pending is almost certain
; to be clear, and doing the test here will save us having to do it later after
; building the pixel strip.
; the pending bit is bit 5, active bits are 0 and 1. So if pending is
; set, (dmactl&31) will be >= 16; otherwise, (dmactl&15) will be the number
; of active DMAs

	bits	#4,>>#0,r0		; get number of DMAs pending
.if 0
{	cmp	#2, r0			; pending clear and < 2 dmas active?
	ld_io	mdmactl,r0		; (pre-load next mdmactl value just in case)
}
	bra	ge,textrap_start,nop	; no -- keep waiting
.else
{	cmp	#0, r0			; pending clear and < 2 dmas active?
	ld_io	mdmactl,r0		; (pre-load next mdmactl value just in case)
}
	bra	ne,textrap_start,nop	; no -- keep waiting
.endif

{
	push	_D_Vtemp		; allow pixel generating function to use temporary register
	jsr	(_D_pixelfn)		; call pixel generation function to generate a strip of pixels
}
	asl	#16,_D_dmaxlen		; convert dmaxlen to a 16.16 number for st_sv
	nop


; now DMA out the (partial) line we just built
{
	pop	_D_Vtemp
}

; we know that pending is clear (we checked it above)

	st_s	_D_intbuf,pixdmacmd+16		; set internal transfer address
{	st_sv	_D_Vdma,pixdmacmd+8
	subm	r0,r0,r0			; clear r0
	asr	#16,_D_dmaxlen                  ; EXECUTE ONLY ONCE
}
	
{
	st_io	#pixdmacmd,mdmacptr			; fire up the DMA
	addr	_D_boty,ry			; toggle Y value: EXECUTE ONLY ONCE
	sub	_D_dmaxlen,_D_linelen,_D_linelen ; decrement count of pixels remaining
}
{	bra	gt,textrap_dmalp		; if pixels remaining on line > 0, continue DMA loop
	add	_D_dmaxlen,>>#-16,_D_dmax	; update X value for DMA
}
{	add	_D_temp1,_D_intbuf,_D_intbuf	; toggle source buffer
	subm	_D_boty,r0,_D_boty		; and update increment for Y
}
	neg	_D_temp1			; and toggle update value for intbuf


	pop	_D_VX				; restore u and v
textrap_endinnerlp:
	ld_v	_DS_step1,_D_VdX		; recover step values from RAM
{	ld_v	_DS_step2,_D_VdI		; recover step values from RAM
	add	#1,>>#-16,_D_dmay
}
{	pop	_D_VI
	addm	_D_drx,_D_rx,_D_linelen
	dec	rc0
	add	_D_drx,_D_rx
}
{
	addm	_D_dlx,_D_lx,_D_lx
	asr	#16,_D_linelen			; prepare for top of loop calculation of pixels per line
}
{	asr	#16,_D_lx,_D_temp0			; prepare temp0 for top of loop calculation of pixels per line
	addm	_D_dv,_D_v,_D_v
	bra	c0ne,textrap_outerlp
}
{	ld_v	_DS_delta1,_D_VdX			; load delta values for inner loop
	addm	_D_du,_D_u,_D_u
	add	_D_di0,_D_i0
}
{	addm	_D_di1,_D_i1,_D_i1
	add	_D_dz,_D_z
}

textrap_endouterlp:
{
	pop	v1,rz
}
	pop	v3
	rts
	ld_v	_DS_step1,_D_VdX	; make sure the step values are what the main code expects
	nop

_drawpoly_end:
	
