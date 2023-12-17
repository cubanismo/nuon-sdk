
	.module sphere
	.export sphere_intersect
	.export	sphere_normal
	.import rsqrtlo
	
	;; intersection code for
	;; Merlin ray tracer
	;; Copyright (c) 1997-2001 VM Labs, Inc.
	;; All rights reserved.
	;; Confidential and Proprietary Information of VM Labs, Inc.
	;; 
 	;; NOTICE: VM Labs permits you to use, modify, and distribute this file
 	;; in accordance with the terms of the VM Labs license agreement
 	;; accompanying it. If you have received this file from a source other
	;; than VM Labs, then your use, modification, or distribution of it
 	;; requires the prior written permission of VM Labs.
;
	;;
	;;  spheres
	;;
	;; the sphere object has the following memory layout:
	;; +0  (*intersect) == pointer to intersection function
	;; +4  (*normal)    == pointer to "find normal" function
	;; +8  (*color)     == pointer to texture function
	;; +12 (*void)      == reserved
	;; +16              == kd = diffuse coefficient (2.14)
	;; +18		    == ks = specular coefficient (2.14)
	;; +20              == kt = translucent coefficient (2.14)
	;; +22              == kl = self-illumination factor
	;; +24              == color (small vector)
	;; +32		    == center of sphere (vector of 8.24 numbers)
	;; +48              == radius of sphere (8.24 number)
	;; +52		    == 1/radius (2.30 number)
	;;


	;; sphere intersection code
	;; register usage:
	;; inputs:
	;; r0 = ptr to sphere object
	;; v2 = base of ray
	;; v3 = direction of ray
	;;
	;; outputs:
	;; r0 = distance to intersection as an 8.24 number (<= 0 means no intersection)
	;; v1 = point of intersection
	;;
	;; other registers used:
	;; r1 = discriminant
	;; r2 = temp variable
	;; v4 = various quantities

	raybase = v2
	raydir = v3
	
;;	disc = r0
	temp = r2
	radius = r3
	U = v1

	b = v4[0]
	tolerance=v4[1]
	disc = v4[2]
	
sphere_intersect:
{	add	#OFF_SPH_CENTER,r0 ; skip uninteresting part of structure
	push	v4,rz
}
{	ld_v	(r0),v1		; get center of sphere
	add	#OFF_SPH_RADIUS-OFF_SPH_CENTER,r0
}
{	ld_s	(r0),radius	; get radius of sphere
	add	#4,r0
}
	sub_sv	raybase,v1	  ; set U = center - base of ray
	dotp	raydir,v1,>>#30,disc ; b is an 8.24 number now (raydir was 2.30) 
	mul	radius,radius,>>#32,radius

{	copy	disc,b
	mul	disc,disc,>>#32,disc  ; 8.24*8.24->16.16 (discriminant is a 16.16 number)
}
{	bra	le,no_intersect
	dotp	v1,v1,>>#32,temp  ; 8.24*8.24 -> 16.16 (so shift right by (24+8 == 32)
}
	add	radius,disc
	sub	temp,disc
	bra	le,no_intersect,nop
	
	;; find square root of discriminant
	jsr	rsqrtlo
	mv_s	#16,r1
	copy	disc,r0

	;; currently "disc" is the discriminant as a 16.16 number
	;; "r0" is 1/sqrt(disc) with r1 fractional bits
	;; we want to set disc to sqrt(disc) as an 8.24 number
{	sub	#(24-16),r1		; convert from 16.16 to 8.24
	mv_s	#fix(TOLERANCE,24),tolerance
}
	mul	r0,disc,>>r1,disc
	mv_v	raydir,v1

	;;   disc = b - disc
	sub	disc,b,disc

	mul_sv	disc,v1,>>#30,v1
{	cmp	tolerance,disc
	mv_s	disc,r0
}
	bra	le,no_intersect_rts
	pop	v4,rz
	add_sv	raybase,v1

	rts
	nop
	nop
	
no_intersect:
	pop	v4,rz
	nop
no_intersect_rts:
	rts
	mv_s	#-1,r0
	nop
	
	;; find normal of a sphere
	;;
	;; inputs:
	;; r0 points to sphere structure
	;; v2 == pt on sphere
	;;
	;; outputs:
	;; v0 == normal
	
sphere_normal:
{	push	v3
	add	#OFF_SPH_CENTER,r0
}
	push	v2,rz
	ld_v	(r0),v0		; v0 = center of sphere
	jsr	vector_normalize
	sub_sv	v0,v2,v0	; v0 = (point - center) (vector of 8.24 numbers)
	nop

	pop	v2,rz
	nop
{	mv_v	v3,v0
	rts
}
	pop	v3
	nop
	

