	;;
	;; main program for ray tracer
	;;
	;; Copyright (c) 1997-2001 VM Labs, Inc.
	;; All rights reserved.
	;; Confidential and Proprietary Information of VM Labs, Inc.
	;; 
 	;; NOTICE: VM Labs permits you to use, modify, and distribute this file
 	;; in accordance with the terms of the VM Labs license agreement
 	;; accompanying it. If you have received this file from a source other
	;; than VM Labs, then your use, modification, or distribution of it
 	;; requires the prior written permission of VM Labs.

	;; define for how often to sample pixels
	;; if 0, sample at least once per pixel
	;; if nonzero, sample at least once every 2 pixels

SAMPLE_DOUBLE = 1

	;; ray trace parameters
        AOV = 45.0
	
	XSHIFT = 0
	YSHIFT = 0
			
	bilinearMode = 4	; mode for (xy) and (uv) writes -- 32 bpp
        width = 32		; width of sample buffer

	TOLERANCE=0.01		; fudge factor for pixel intersections
	;;RAYDEPTH = 2		; maximum depth for rays
	RAYDEPTH = 3		; maximum depth for rays

dmaFlags = 0
dmaScreen = 0

	.include "raydefs.h"
	.include "rayobj.i"

	.include "raydata.s"

	.segment ray2c
	
	.export _ray_pipe

_ray_pipe:
	
	
;;;
;;; Main Routine
;;;
	.module main
	.export render
	.export vector_normalize
	.import	rsqrtlo
	.import	trace
	.import	traceeye
	.import	scanlineobjptr
	.import	sceneobjptr
        .import usejoyval

	angle_vec = v4
	Xpix = v5[0]
	Ypix = v5[1]
	Scrncenterx = v5[2]
	Scrncentery = v5[3]
	lastsample = v6

	;*******************************************
	;* startup code
	;*
	;* Assumptions:
	;*
	;* Data RAM has already been properly loaded
	;* up.
	;********************************************

render:
	push	v7,rz

        ld_s    dest_dma_flags,r0
	ld_s    dest_base_addr,r1
        st_s    r0,dmabuf
        st_s    r1,dmabuf+4

frameloop:
	;
	; update water values
	;
	ld_v	water_pos,v0
	ld_v	water_vel,v1
	nop
	add	v1[0],v0[0]
	add	v1[1],v0[1]
	add	v1[2],v0[2]
	st_v	v0,water_pos

	;
	; do animation here
	;
	mv_s	#animlist,r8
animloop:
	ld_s	(r8),r0
	add	#4,r8
	cmp	#0,r0
{	bra	eq,`endanimloop,nop
	add	#OFF_MOVE_FN,r0
}
	ld_s	(r0),r1
	sub	#OFF_MOVE_FN,r0

	jsr	(r1),nop

	bra	animloop,nop	
`endanimloop:

	;;
	;; other initialization
	;;
	ld_v	INITIALIZE_1,v0
	ld_v	ANGLE_VEC,angle_vec

	;; initialize xy registers
	st_io	r0,xybase
	st_io	r1,xyctl
	st_io	r2,acshift

	ld_v	INITIALIZE_2,v0
	sub	angle_vec[3],angle_vec[3]	; zero angle_vec[3]
	st_io	r0,uvbase
	st_io	r1,uvctl
	st_io	r2,uvrange
	
	;;
	;; main loop:	step over every pixel, tracing rays and putting the
	;; result out
	;;

	st_io	angle_vec[3],rx		; initialize rx and ry to 0
	st_io	angle_vec[3],ry

	mv_s	#RAYDEPTH,r31

	mv_s	angle_vec[0],Scrncenterx
	mv_s	angle_vec[2],Scrncentery

	; initialize Ypix to the MPE number
;;	mv_s	#0,Ypix
	ld_s	cur_mpe,Ypix
	
	;;
	;; code for starting a new line
	;;
newline:

	sub	Xpix,Xpix

	asl	#(ANGLE_PREC+YSHIFT),Ypix,angle_vec[2]
	sub	angle_vec[2],Scrncentery,angle_vec[2]

	;;
	;; figure out which objects intersect this scan line
	;; the plane in which the scan line intersection points
	;; the plane has normal vector (0, angle_vec.z, -angle_vec.y)
	;;
{	jsr	vector_normalize
}
	sub_sv	v0,v0
{	mv_s	angle_vec[2],v0[1]
	sub	angle_vec[1],#0,v0[2]
}

	;; now v3 has the plane's normal vector
	;; loop through all objects, finding which ones
	;; intersect this plane
	;; if the object does intersect the plane, put it on
	;; the candidate list
	;; we can use v0-v2 as scratch registers

	distance = v0[0]
	tempptr = v0[1]
	objcount = v0[2]
	;; v1 is used as a vector...
	sceneptr = v2[0]
	candidateptr = v2[1]
	curobj = v2[2]
	radius = v2[3]

{	ld_s	sceneobjptr,sceneptr
}
	ld_s	scanlineobjptr,candidateptr

	;;
	;; KLUDGE: the first object in the list is assumed to be
	;; the ground plane, and can only be intersected by
	;; eye rays that point down (have a -ve Z component)
	;;
	cmp	#0,v3[2]
	bra	lt,objloop,nop
	add	#4,sceneptr		;; skip ground plane
objloop:
	ld_s	(sceneptr),curobj
	add	#4,sceneptr
	copy	curobj,tempptr
{	jmp	eq,endobjloop,nop
	add	#OFF_SPH_CENTER,tempptr
}
	ld_v	(tempptr),v1	; get center of object (8.24)
	add	#(OFF_SPH_RADIUS-OFF_SPH_CENTER),tempptr

	dotp	v3,v1,>>#30,distance	; find (signed) distance of center to plane
{	ld_s	(tempptr),radius
	dotp	angle_vec,v1,>>#30,tempptr  ; see if vector points away from sphere
}
	abs	distance		; make it an absolute distance
	sub	radius,distance		; subtract the radius
	jmp	ge,objloop,nop		; if >= 0, the plane does not hit the sphere
	cmp	#0,tempptr		; check for angle between view vector and point
	jmp	lt,objloop,nop

	jmp	objloop
	st_s	curobj,(candidateptr)	; otherwise, the sphere is a candidate
	add	#4,candidateptr		; for eye ray intersections on this scan line


endobjloop:
{	st_s	curobj,(candidateptr)
}

	;; here's where the X stepping happens
	;;

pixloop:
{        mv_s    #fix(ASPECT_RATIO,30),r0
	 asl	#(ANGLE_PREC+XSHIFT),Xpix,angle_vec[0]
}
	sub	Scrncenterx,angle_vec[0],angle_vec[0]
{	jsr	vector_normalize
        mul     r0,angle_vec[0],>>#30,angle_vec[0]
}
        nop
	mv_v	angle_vec,v0

       ;; we return here from vector_normalize with v3
       ;; containing the ray direction

{       jsr     traceeye,nop
}

	;; now v0 has the sample's color
	;; if X > 0, then interpolate between this
	;; sample and the last to produce two pixels;
	;; interpolate_samples takes the following
	;; parameters:
	;; v0 == current sample
	;; v1 == last sample
	;; v2 == last viewing angle
	;; v3 == current viewing angle
	;;
	;; it returns:
	;; v0 == pixel color



{	cmp	#0,Xpix
	mv_v	lastsample,v1		; v1 == last sample
}
{	jmp	eq,next_x,nop
	mv_v	v0,lastsample
}

{	jsr	interpolate_samples,nop
	ld_v	last_ray_direction,v2
}

.if SAMPLE_DOUBLE
	;; we can actually draw two pixels at a time here,
	;; recovering the two samples as v0+v1 and v0-v1

{	jsr	plotpixel
	push	v0
}
	push	v1
	add_sv	v1,v0	; v0 = (A+C)/2, v1 = (A-C)/2, so A = v0+v1

	pop	v1
{	pop	v0
	jsr	plotpixel
}
	add	#1,Xpix
	sub_sv	v1,v0	; v0 = (A+C)/2, v1 = (A-C)/2, so C = v0-v1

.else

	jsr	plotpixel,nop

.endif

next_x:
	cmp	#SCRNWIDTH,Xpix
	jmp	lt,pixloop
	st_v	v3,last_ray_direction
	add	#1,Xpix


endofline:
	;
	; increment Ypix by the number of MPEs
	;
	ld_s	total_mpes,r0
	nop
	add	r0,Ypix
	cmp	#SCRNHEIGHT,Ypix
	jmp	lt,newline,nop

	;; we're all done!
end:
{	nop
}
	pop	v7,rz
	nop
	rts
	nop
	nop

	;;
	;; interpolate_samples:
	;; given: two samples A and C and two viewing angles
	;; if the samples are "close enough" in value,
	;; or if we've reached maximum depth, then produce
	;; the pixel (A+C)/2
	;; otherwise, take a sample B midway between A and C
	;; and call interpolate_samples recursively to get
	;; X = interpolate_samples(A,B) and Y = interpolate_samples(B,C)
	;; and return (X+Y)/2
	;; parameters:
	;; v0 == current sample (C)
	;; v1 == last sample (A)
	;; v2 == last viewing angle (for A)
	;; v3 == current viewing angle (for C)
	;;
	;; r28 == depth of recursion
	;; r29 == 1/128 in 2.30 notation, same as 1/2 in 8.24 notation
	;; returns: v0 == interpolated sample
	;;
	;; if the recursion went more than 1 step, then the last two
	;; interpolated values can be recovered as
	;; v0 - v1
	;; v0 + v1

interpolate_samples:
	mv_s	#2+SAMPLE_DOUBLE,r28	; max. depth of recursion
do_interpolate:
{	sub_sv	v0,v1			; v1 = difference between samples
}
{	dotp	v1,v1,>>#30,r30		; calculate sample distance
	sub	#1,r28			; decrement recursion depth
	mv_s	#fix(1.0/512.0,30),r29	; r29 == 1/512 in 2.30 notation
}
{	jmp	le,use_current_samples
}
	cmp	r29,r30
{	asl	#2,r29			; convert r29 to 1/2 in 8.24 notation (1/128 in 2.30 notation)
	jmp	gt,need_new_sample,nop
}
use_current_samples:
	mul_sv	r29,v1,>>#24,v1		; v1 == (last-this)/2
	rts
	add_sv	v1,v0
	add	#1,r28

need_new_sample:
	push	v4
{	push	v6,rz
	add_sv	v0,v1			; restore sample A
}
	push	v3			; save viewing angle for C
	push	v0			; save sample C

{	push	v2			; save viewing angle for A
	sub_sv	v3,v2
}

	;; FIXME? we really ought to normalize the average
	;; vector. However, it's pretty close to normal
	;; already, so maybe we can get away without this...

{	mul_sv	r29,v2,>>#24,v2
	jsr	traceeye
}
	push	v1			; save sample A
	add_sv	v2,v3


	;; now v0 is the midpoint sample B
	;; and v3 is the viewing angle for B
{	pop	v1			; get sample A
}
{	pop	v2			; get viewing angle for A
	jsr	do_interpolate
}
	push	v3			; save midpoint viewing angle
	push	v0			; save midpoint sample B

	mv_v	v0,v4			; save first return value X

	pop	v1			; retrieve midpoint viewing sample B
{	pop	v2			; retrive midpoint viewing angle
	jsr	do_interpolate
}
	pop	v0			; retrieve sample C
	pop	v3			; retrieve viewing angle for C



	;; at this point, v4 has the first interpolated sample, X
	;; and v0 has the new interpolated sample, Y
{	sub_sv	v0,v4,v1		; set v1 = X - Y
	pop	v6,rz
}
{	pop	v4
	mul_sv	r29,v1,>>#24,v1		; v1 == (last-this)/2
}
	rts
	add_sv	v1,v0
	add	#1,r28


	;;
	;; function to normalize the vector in v0
	;; returns:	v3 (!)
	
vector_normalize:
{	mv_v	v0,v3
	mul	r0,r0,>>acshift,r0
}
	mul	r1,r1,>>acshift,r1
{	mul	r2,r2,>>acshift,r2
	ld_io	rz,v3[3]
}
{	jsr	rsqrtlo
	add	r1,r0
}
	ld_io	acshift,r1	; smaller than mv_s #30,r1
	add	r2,r0		; now r0 == length of vector, squared

	st_io	v3[3],rz
	;; number of fraction bits comes back in r1
	;; now multiply v2 by these
	mul	r0,v3[0],>>r1,v3[0]
{	mul	r0,v3[1],>>r1,v3[1]
	rts
}
	mul	r0,v3[2],>>r1,v3[2]
	sub	v3[3],v3[3]	; clear out last component of vector
	

	;; to plot a pixel, we store it in a buffer, and
	;; every fourth pixel send it out with DMA

	;; note that when we enter this routine, the
	;; first pixel on the scan line will have X coordinate 1
	;;

;;NUMPIXELS = 4
NUMPIXELS = 8

plotpixel:
{	and	#(NUMPIXELS-1),Xpix,v1[0]	; check X value
	st_p	v0,(xy)
	addr	#1<<16,rx
}
	rts	ne,nop		; we send data at X=4, X=8, etc..

{	addr	#(-NUMPIXELS)<<16,rx
	sub	#NUMPIXELS,Xpix,r0
}
	or	#NUMPIXELS,<>#-16,r0

	;; fall through to DMA routine


	;*******************************************
	;* DMA some pixels to the screen
	;*

	mv_s	#dmabuf,r1

	;* wait for DMA to go idle
wv:
	ld_io	mdmactl,r2
	nop
	bits	#4,>>#0,r2
	bra	ne,wv,nop

	; reset DMA (x,y) pointers
	copy	Ypix,r2
{	or	#1,<>#-16,r2

	;
	; start new DMA
	;
	st_s	r0,dmaxptr
	rts
}
	st_s	r2,dmayptr
	st_s	r1,mdmacptr


	
	.include	"raytrace.s"
	.include	"move.s"
	.include	"logo.s"
			
	.module
	.include	"rsqrtlo.s"

	.segment ray2d
	.include	"reciplut.i"

	.segment ray2c
	.include	"reciplo.s"
	
EndRayCode:
	
