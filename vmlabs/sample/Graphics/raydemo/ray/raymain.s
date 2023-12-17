	
/* Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/
	;; main program for ray tracer
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

	.include "merlin.i"
	.include "raydefs.h"
	.include "rayobj.i"

	.include "raydata.s"

	.segment rayc
	
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
        .import mousesphere

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
	st_sv   v0,wateroffset

	;
	; do animation here
	;

	jsr	do_anim
	mv_s	#s1pos,r0
	mv_s	#s1vel,r1

	jsr	do_anim
	mv_s	#s2pos,r0
	mv_s	#s2vel,r1
	
	ld_v	s1pos,v0
	ld_v	s2pos,v1
	st_sv	v0,s1
	st_sv	v1,s2

        ; update ball position
        ; look for the joystick driver
        ld_s    usejoyval,r0
        ld_sv   mousesphere,v1
        copy    r0,r1
        asl     #24,r1
        asl     #16,r0
;;        asr     #7,r0,v1[0]
;;        asr     #7,r1,v1[1]

        add     r0,>>#8,v1[0]
        add     r1,>>#8,v1[1]

        ; move up or down based on button states
        ld_s    usejoyval,r0
        sub     r1,r1
        btst    #(14+16),r0      ; check for A button
        bra     eq,notDown,nop
        mv_s    #-0x000f0000,r1
        bra     doneButton,nop
notDown:
        btst    #(3+16),r0      ; check for B button
        bra     eq,notUp,nop
        mv_s    #0x000f0000,r1
        bra     doneButton,nop
notUp:
        btst    #(13+16),r0      ; check for Start button
        bra     eq,doneButton,nop
        sub_sv  v1,v1
        mv_s    #$07f80000,v1[1]

doneButton:
        add     r1,v1[2]        ; update Z coordinate

        st_sv   v1,mousesphere

{	ld_v	INITIALIZE,v0
}
	ld_v	ANGLE_VEC,angle_vec

;;; ASSUME STACK IS ALREADY SET UP
;;;	st_io	r0,sp

	st_io	r1,xybase
	st_io	r2,xyctl
	st_io	r3,acshift

	;;
	;; main loop:	step over every pixel, tracing rays and putting the
	;; result out
	;;

	sub	angle_vec[3],angle_vec[3]
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

objloop:
	ld_s	(sceneptr),curobj
	add	#4,sceneptr
	copy	curobj,tempptr
	jmp	eq,endobjloop,nop

	ld_sv	(tempptr),v1	; get center of object (8.24)
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
{        mv_s    #fix(ASPECT_RATIO,28),r0
	 asl	#(ANGLE_PREC+XSHIFT),Xpix,angle_vec[0]
}
	sub	Scrncenterx,angle_vec[0],angle_vec[0]
{	jsr	vector_normalize
        mul     r0,angle_vec[0],>>#28,angle_vec[0]
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

;;;	mul_sv	r29,v1,>>#24,v1	; adjust delta to bias towards edges

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
	;; every fourth pixel send it to coldfire

	;; note that no YCrCb->RGB conversion is necessary for
	;; the alpha hardware
	;; ALSO note that coldfire assumes the pixels will be
	;; received in scan-line order
	;;
	;; finally, note that when we enter this routine, the
	;; first pixel on the scan line will have X coordinate 1
	;;

;;NUMPIXELS = 4
NUMPIXELS = 8

plotpixel:
	mv_s	#(NUMPIXELS-1),v1[0]
{	and	Xpix,v1[0]	; check X value
	st_p	v0,(xy)
	addr	#(1<<16),rx
}
	rts	ne,nop		; we send data at X=4, X=8, etc..

	addr	#(-NUMPIXELS)<<16,rx

	sub	#NUMPIXELS,Xpix,r0
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
	or	#1,<>#-16,r2

	;
	; start new DMA
	;
	st_s	r0,dmaxptr
	st_s	r2,dmayptr
	st_s	r1,mdmacptr

.if 1
        ; PARANOIA CODE
	; wait for that DMA to finish

wv2:
	ld_io	mdmactl,r0
	nop
	bits	#4,>>#0,r0
	bra	ne,wv2,nop
.endif

	rts
	nop
	nop

	
	;
	; animation code
	; Entered with: r0 == ptr to object
	;               r1 == ptr to object velocity

	animposptr = r0
	animvelptr = r1
	animmaxptr = r2
	animminptr = r3

	animpos = r4
	animvel = r5
	animmax = r6
	animmin = r7
	
do_anim:
	mv_s	#maxvals,animmaxptr
	mv_s	#minvals,animminptr

	; for each coordinate do:
	st_io	#3,rc0
animlp:
	ld_s	(animposptr),animpos
	ld_s	(animvelptr),animvel
{	ld_s	(animmaxptr),animmax
	add	#4,animmaxptr
}
{	ld_s	(animminptr),animmin
	add	#4,animminptr
}
	add	animvel,animpos
	cmp	animpos,animmax
	bra	ge,askip1,nop
	neg	animvel
	copy	animmax,animpos
askip1:
	cmp	animpos,animmin
	bra	lt,askip2,nop
	neg	animvel
	copy	animmin,animpos
askip2:
	dec	rc0
	bra	c0ne,animlp
{	st_s	animpos,(animposptr)
	add	#4,animposptr
}
{	st_s	animvel,(animvelptr)
	add	#4,animvelptr
}	
	rts
	nop
	nop
	
	.include	"raytrace.s"
	
	.module
	.include	"rsqrtlo.s"

EndRayCode:
	
