
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/
	;; methods for plane object intersections
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
	;; other registers used:
	;; r1 = denominator for plane distance equation
	;; r2 = numerator for plane distance equation
	;; r3 = tolerance for comparisons
	;; v1 = plane normal
	;; v4 = misc variable
	
	.module plane
	.export plane_intersect
	.export plane_normal
	.export water_normal
	.import recip

	denom = r1
	numerator = r2
	
plane_intersect:
{	push	v4
	add	#OFF_PLANE_NORMAL,r0
}
{	ld_sv	(r0),v1
	sub	#(OFF_PLANE_NORMAL-OFF_BASEPT),r0
}
	ld_v	(r0),v4
{	dotp	v1,v3,>>#30,denom
	sub	r0,r0		; default return value is 0
}
	sub_sv	v2,v4,v4

{	neg	denom
	dotp	v1,v4,>>#30,numerator
	pop	v4
}
	rts	le
	neg	numerator
	rts	le,nop
	
	;; now find 1/denominator to calculate point of intersection
{	jsr	recip
	push	v4,rz
}
{	mv_s	numerator,v4[0]		; save numerator
	copy	denom,r0
}
{	copy	denom,v4[1]	; DEBUG: save original denominator
	mv_s	#30,r1		; denominator is a 2.30 number
}
	
	sub	#8,r1		; let recip finish, adjust r1 so r0 is an 8.8 number
{	jmp	lt,nohit	; if r0 is bigger than 1<<30, then assume no intersection
	as	r1,r0		;  now r0 is an 8.24
}
	;; now r0 has 1/denominator
{	mul	v4[0],r0,>>#8,r0	; set r0 = 1/denominator * r1, as an 8.24 number
	pop	v4,rz
}
	nop

{	mul_sv	r0,v3,>>#30,v1	; v3 is a 2.30 normal vector; r0 is an 8.24 scale
	rts
}
	nop
	add_sv	v2,v1		; v1 = raybase + t * raydir

nohit:
{	sub	r0,r0
	rts
}
	nop
	nop
	
	;; find normal for a point on a plane
	;; this is easy, it's constant!
	;; inputs:
	;; r0 == pointer to plane structure
	;; v1 == point of intersection
	;; outputs:
	;; v0 == normal
plane_normal:	
{	add	#OFF_PLANE_NORMAL,r0
	rts
}
	ld_sv	(r0),v0
	nop

	.segment ray2d
	.align.sv
water1:
	.dc.sv fix(0.0,8), fix(0.0,8), fix(7.0,8), 0
	
	.segment ray2c
	;;
	;; find normal for a point on water
	;; this is not quite as easy
	;;
	;; inputs:
	;; r0 == pointer to object
	;; v2 == point of intersection (may be changed)
	;;
	;; outputs:
	;; v0 == normal
water_normal:
	ld_v	water_pos,v1
	push	v3
{	add_sv	v2,v1
	ld_sv	water1,v0
}
{	lsl	#8,v1[1],v3[0]
	push	v1,rz
}
	asr	#9,v3[0]	;; now v3[0] is a signed 8.24 number between -.5 and +.5
	abs	v3[0]		;; now it's between +0 and +.5
{	bra	cc,`positive,nop
	sub	v3[0],>>#3,v0[1]	;; change the normal
}
	;; here v3[0] used to be negative
	add	v3[0],>>#2,v0[1]
`positive:
{	sub	v3[0],>>#3,v2[2]	;; change the point of intersection
	jsr	vector_normalize,nop
}

	pop	v1,rz
	nop
{	mv_v	v3,v0
	rts
}
	pop	v3
	nop
