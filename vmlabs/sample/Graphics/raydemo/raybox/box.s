/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/	
	;; methods for polyhedron-object intersections
	;;
	;; register usage:
	;; inputs:
	;; r0 = ptr to plane object
	;; v2 = base of ray
	;; v3 = direction of ray
	;;
	;; outputs:
	;; r0 = distance to intersection as an 8.24 number (<= 0 means no intersection)
	;; v1 = point of intersection
	;;

	;; internal register usage
	;; v0 = plane normal
	;; v1 = plane base point
	;; v4 = misc. variables
	;; v5 = misc. variables
	
	.module polyhedron
	.export polyhedron_intersect
	.export polyhedron_normal
	.import recip

	.segment ray2c

	
	denom = v4[0]
	t = v4[1]
	numplanes = v4[2]
	ptr = v4[3]
	
	mindist = v5[0]
	maxdist = v5[1]
	last_norm_ptr = v5[2]
		
polyhedron_intersect:
{	push	v4
	add	#OFF_POLY_NUMPLANES,r0,ptr
}
{	push	v5,rz
	add	#OFF_POLY_LASTNORM,r0,last_norm_ptr
}
{	ld_s	(ptr),numplanes
	add	#OFF_POLY_PLANES-OFF_POLY_NUMPLANES,ptr
}

	sub	mindist,mindist
	mv_s	#$3fffffff,maxdist
	
	;; for each plane do
{	ld_sv	(ptr),v1	;; fetch plane base point
	add	#8,ptr		;; advance pointer
}
{	ld_sv	(ptr),v0	;; fetch plane normal
				;; do NOT advance, we may need to re-read this later
}
planeloop:
	sub_sv	v1,v2,v1	;; v1 == raybase - planebase (8.24 numbers)
	dotp	v0,v1,>>#30,t
	dotp	v0,v3,>>#30,denom  ;; v3 == ray direction
	
	;; we're on the "outside" if t > 0
	cmp	#0,t
	bra	lt,inside,nop
	neg	denom
	bra	le,nohit,nop

outside:
	;; find t/denom
	;; t is 8.24
	;; denom is a 2.30 fixed point number
	jsr	recip
	mv_s	#30,r1
	copy	denom,r0

	;; calculate t * 1/denom
	nop			;; wait for recip
	mul	r0,t,>>r1,t
	nop

	;; no intersection if t > maxdist
{	bra	mvs,nohit,nop
	cmp	maxdist,t
}
	bra	ge,nohit,nop
	
	;; not an interesting intersection if t < mindist
	;; i.e. if t - mindist < 0
	cmp	mindist, t
	bra	lt,nextplane,nop

	;; new minimum distance found
	;; if new mindist (t) > maxdist, i.e. maxdist - t > 0,
	;; then intersection is empty
{	ld_sv	(ptr),v0	;; re-fetch plane normal
	bra	nextplane
}
	copy	t,mindist
	st_sv	v0,(last_norm_ptr)

inside:
	;; we're "inside" the plane, and hence the intersection
	;; with the half-space is either from 0 to t/denom (if
	;; (t/denom > 0) or is from 0 to infinity
	cmp	#0,denom
{	bra	le,nextplane,nop
	neg	t
}
	;; find t/denom
	;; denom is a 2.30 fixed point number
	jsr	recip
	mv_s	#30,r1
	copy	denom,r0

	;; calculate t * 1/denom
	nop			;; wait for recip
	mul	r0,t,>>r1,t
	nop

	;; if t < mindist (so t - mindist < 0), no hit
{	bra	mvs,nextplane,nop	;; skip everything if multiply overflows
	cmp	mindist,t
}
{	bra	lt,nohit,nop
	
	;; if t < maxdist, (so t - maxdist < 0) set t to maxdist
	cmp	maxdist,t		;; if (t - maxdist) >= 0, skip assignment
}
	bra	ge,nextplane,nop
	mv_s	t,maxdist

	;; fall through
nextplane:
	sub	#1,numplanes
{	bra	gt,planeloop
	add	#8,ptr		;; advance plane pointer
}
{	ld_sv	(ptr),v1	;; fetch plane base point
	add	#8,ptr
}
	ld_sv	(ptr),v0	;; fetch normal; do NOT advance pointer

	;; OK, we got a hit here
	;; "mindist" is the distance
	nop
	mv_v	v3,v1
{	copy	mindist,r0
	pop	v5,rz
	mul	mindist,v1[0],>>#30,v1[0]
}
{	mul	r0,v1[1],>>#30,v1[1]
	pop	v4
}
{	rts
	mul	r0,v1[2],>>#30,v1[2]
	add	v2[0],v1[0]
}
	add	v2[1],v1[1]
	add	v2[2],v1[2]
	
nohit:
	pop	v5,rz
	pop	v4
	rts
	sub	r0,r0
	nop
	
	;; find normal for a polyhedron
	;; ASSUMPTION: this is the same as
	;; the normal we found above
	;;
	;; inputs:
	;; r0 == pointer to object structure
	;; v1 == point of intersection
	;; outputs:
	;; v0 == normal
polyhedron_normal:	
{	rts
	add	#OFF_POLY_LASTNORM,r0
}
	ld_sv	(r0),v0
	nop
