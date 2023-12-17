
/* Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/
	;; ray intersection code
	;;
	;; first_intersection
	;; find the first intersecting object for a ray shot from a point
	;; enter with:
	;; r0 == list of objects to test for
	;; v2 == raybase      (vector of 8.24 numbers)
	;; v3 == raydirection (vector of 2.30 numbers)
	;;
	;; return with:
	;; r0 == pointer to object, or NULL if no object intersects
	;; v1 == point of intersection
	;;
	;; preserves:	v2-v7
	;;
	;; Register usage:

	.module intersect
	.export first_intersection
	.import scene
	.import ambient

	raybase = v2
	raydir = v3
	
	temp = r2
	radius = r3		;; passed by first_intersection!!
	tolerance = radius ;; shared use of registers

	iobj = v4[0]		; nearest intersecting object
	mindist = v4[1]		; distance to nearest intersecting object
	curobj = v4[2]		; current object under consideration
	scnptr = v4[3]		; pointer into scene
	ipt = v5		; point of intersection
	nextobj = v6[0]		; next object
	b = v6[1]
	disc = v6[2]

first_intersection:
{	push	v4
	subm	iobj,iobj,iobj
	copy	r0,scnptr
}
{	push	v5
	sub	#1,iobj,mindist ; set mindist = -1
}
{	push	v6,rz
	bclr	#31,mindist	; set mindist = $7ffffff
	jmp	nohit		; enter loop at bottom
}
	ld_s	(scnptr),nextobj
	add	#4,scnptr

objloop:
{	copy	curobj,r0
	ld_sv	(curobj),v1		; get center of sphere
}
	add	#OFF_SPH_RADIUS-OFF_SPH_CENTER,r0
{	ld_s	(r0),r3		; get radius of sphere (sphere_intersect wants this in r3)
	sub_sv	v2,v1	  ; set v1 = center - base of ray
}

	dotp	raydir,v1,>>#30,disc ; b is an 8.24 number now (raydir was 2.30) 
	mul	radius,radius,>>#32,radius

	copy	disc,b		; sets flags
	jmp	le,nohit
	mul	disc,disc,>>#32,disc  ; 8.24*8.24->16.16 (discriminant is a 16.16 number)
	dotp	v1,v1,>>#32,temp  ; 8.24*8.24 -> 16.16 (so shift right by (24+8 == 32) 

	add	radius,disc
	sub	temp,disc
	jmp	le,nohit
	
	;; find square root of discriminant
	jsr	rsqrtlo
	mv_s	#16,r1
	copy	disc,r0

	
	;; currently "savedisc" is the discriminant as a 16.16 number
	;; "r0" is 1/sqrt(disc) with r1 fractional bits
	;; we want to set disc (r0) to sqrt(disc) as an 8.24 number
{	sub	#(24-16),r1		; convert from 16.16 to 8.24
	mv_s	#fix(TOLERANCE,24),tolerance
}
	mul	r0,disc,>>r1,disc
	mv_v	raydir,v1

	;;   disc = b - disc
	sub	disc,b,disc

	mul_sv	disc,v1,>>#30,v1
	cmp	tolerance,disc	; set flags for caller
{	jmp	le,nohit
	add_sv	raybase,v1
}
	cmp	mindist,disc

	;; do this code if we record a hit
	;; in this case, we have determined that disc (the distance
	;; to the object "curobj") is > 0; we now have
	;; to check that it's < mindist
	jmp	ge,nohit,nop

{	mv_s	curobj,iobj
	copy	disc,mindist
}
	mv_v	v1,ipt

nohit:
	copy	nextobj,curobj
	jmp	ne,objloop
	ld_s	(scnptr),nextobj
	add	#4,scnptr
	

endobjloop:
	mv_v	ipt,v1
	pop	v6,rz
	pop	v5
{	copy	iobj,r0
	rts
}
	pop	v4
	sub	v1[3],v1[3]

	;;
	;; diffuse lighting module
	;;
	;; parameters:
	;; r0 == kd = diffuse lighting coefficient for object being lit
	;; v2 = ipt = point of intersection on surface
	;; v6 = normal = surface normal at ipt
	;;
	;; returns:
	;; v0 == color (and intensity) of light hitting surface
	;; 
	;; ASSUMPTIONS:
	;;  only 1 light
	.module light
	.export diffuse_light
	.import lights
	.import shadowobjptr

	ipt = v2
;;	lightptr = v4[0]	;; no longer used -- free register
	light = v4[1]
	kd = v4[2]
	kl = v4[3]
	lightdir=v3
	normal=v6
	lightcolor = v7
	

diffuse_light:
{	push	v4
	copy	r0,kd
}
	ld_s	(lights),light
	push	v3
	
{	ld_sv	(light),v1		; v1 == lighting coefficients
	add	#8,light
}
{	ld_sv	(light),lightdir	; get light direction
	add	#8,light
}
{	copy	v1[3],kl	; kl = intensity of light (2.30)
	push	v7
}
{	dotp	normal,lightdir,>>#30,r1        ; r1 = dot product of lightdir and normal (2.30)
	ld_sv	ambient,lightcolor	; initialize light to ambient
}
{	mul	kd,kl,>>acshift,kl	; kl is a 2.30 lighting scale factor
}
	cmp	#0,r1		; are we pointing towards the light?
{	jmp	le,endlight	; no --we're finished with lighting
	mul	r1,kl,>>acshift,kl ; kl is a 2.30 scale factor
}
	ld_sv	(light),v1	; get the light's color
	push	v2,rz		; really just to save rz

	;; check for shadows
	;; we do this by calling first_intersection with parameters
	;; r0 == list of shadow objects
	;;  raybase = ipt = v2
	;;  raydir = lightdir = v3

{	mul_sv	kl,v1,>>#30,v1  ; scale the light's color; v1 was 2.30
	jsr	first_intersection
}
	ld_s	shadowobjptr,r0		; get pointer to list of shadow objects
	push	v1		; save scaled color


	;; check for a blocking object
{	pop	v1		; restore scaled color
	cmp	#0,r0		; no object at all found?
}
{	jmp	ne,endlight,nop	
	sub	lightcolor[3],lightcolor[3]	; zero last component of lightcolor
}
	; add in this light's contribution
	add_sv	v1,lightcolor
	or	#1,<>#-16,lightcolor[3]	; set flag for shadow
	
endlight:
	;; we SHOULD saturate components of "lightcolor" to 24 bits
	;; however, for demo purposes we assume no overflow is possible

	; copy lightcolor to v0; use the ALU for this

{	pop	v2,rz		; restore rz
	sub_sv	v0,v0
}
{	add_sv	lightcolor,v0
	pop	v7
}
{	pop	v3
	rts
}
	pop	v4
	nop

	.module raytrace
	.export trace
	.export	traceeye
	.import scene
	.import sceneobjptr
	.import ambient
	.import bgcolor
	.import wateroffset

	;;
	;; trace a ray and find its color
	;;
	;; inputs:
	;;  r0 == pointer to list of objects to test for intersections
	;;  r31 == depth of trace
	;;  v2 == ray base
	;;  v3 == ray direction
	;;
	;; outputs:
	;;  v0 == final color
	;;

	;; register usage
	ipt	= v2		; point of intersection (re-use of input parameter raybase)
	raydir = v3		; direction of ray
	finalcolor = v4		; final output color
	lightcoeff = v5		; lighting coefficients
	kd = lightcoeff[0]     ; diffuse
	ks = lightcoeff[1]     ; specular term -- reflections
	kt = lightcoeff[2]     ; used for water
	kl = lightcoeff[3]     ; intrinsic lighting

	;; NOTE:	diffuse_light assumes v6 is normal
	normal = v6		; object's surface normal
	iobj	= v7[0]		; intersection object
	dirangle = v7[1]	; directional angle (dot product of normal and direction)
	radius	= v7[2]		; radius of sphere
	reserved = v7[3]
	
	;;
	;; traceeye: special entry point for rays originating at the eye
	;;
traceeye:
{	ld_s	scanlineobjptr,r0
	sub_sv	v2,v2		;; ASSUMES eye is at origin
}
trace:
{	push	v4
}
{	push	v5
}
{	push	v7,rz
        sub     #1,r31          ; decrement current depth of trace
}
{       jmp     lt,abortearly
        push    v6
}
        push    v3
;
; first_intersection expects r0,v2,and v3 to be set up the same as they
; were by our caller, so we don't need to shuffle them at all
;
{	jsr	first_intersection,nop	; will be annulled if the branch above is taken
	ld_sv	bgcolor,finalcolor
}

	copy	r0,iobj		; save intersection object, and test to see if it was NULL
{	jmp	eq,retbgcolor,nop
	mv_v	v1,ipt
}
{	ld_sv	(iobj),normal	; get center of sphere
	add	#OFF_SPH_INVRADIUS-OFF_SPH_CENTER,iobj
}
{	ld_s	(iobj),radius	; get 1/radius of sphere
	sub	#(OFF_SPH_INVRADIUS-OFF_LIGHTCOEFF),iobj
}

	;; OK, we have real work to do

{	sub_sv	normal,ipt,normal	; normal = ipt - center
	ld_sv	(iobj),lightcoeff
}
	mul_sv	radius,normal,>>#24,normal	; calculate normal vector
	add	#(OFF_COLOR1-OFF_LIGHTCOEFF),iobj


	;;
	;; perturb normal
	;;
{	cmp	#0,kt
	push	v3
}
	jmp	eq,nobump,nop

	ld_sv	wateroffset,v3
	ld_v	water_mask,v0
	add_sv	ipt,v3
	and	v3[0],v0[0]
	and	v3[1],v0[1]
;;	and	v3[2],v0[2]
	mul_sv	v0,normal,>>#24,normal
	nop

nobump:



	;; normalize the vector
	jsr	vector_normalize
	mv_v	normal,v0
	nop
	
	mv_v	v3,normal
	pop	v3

	;; if the surface has intrinsic light, add its lighting coefficient to
	;; each component of the ambient
	;; if the surface does diffuse reflections, calculate diffuse lighting
	
	cmp	#0,kd		; check for diffuse lighting
{	jmp	eq,nodiffuse
	copy	kl,finalcolor[0]	; add intrinsic light
	dotp	normal,v3,>>#32,dirangle ;calculate angle of reflection (4.28)
}
{	copy	kl,finalcolor[1]	; add intrinsic light
	jsr	diffuse_light		; call the diffuse lighting subroutine if the "jmp"
					; above was annulled
}
{	copy	kl,finalcolor[2]	; add intrinsic light
	mv_s	#0,finalcolor[3]
}
	copy	kd,r0


	;; diffuse_light returns a color in v0

	;; finish ambient + diffuse lighting
	;; get surface color
	
	ld_sv	(iobj),v1
	add_sv	v0,finalcolor		; should set a flag in "finalcolor"

	;; surface color is now available in v0
	
	;; compute lighting * surface color
	mul_p	v1,finalcolor,>>#30,finalcolor
	
nodiffuse:
	;;
	;; now do specular reflections
	;; also, set dirangle == 2*dirangle
	;; NOTES: dirangle is currently a 4.28 number
	;; we want to convert it to 8.24 (for the multiply below)
	;; and double it; that means a right shift by 4, and a left
	;; shift by 1, for a total right shift of 3
	;;
{	cmp	#0,ks
	mul	#1,dirangle,>>#3,dirangle	; asr #3,dirangle
}
	jmp	eq,nospecular,nop
{	jmp	lt,phong
	mul_sv	dirangle,normal,>>#24,v1
	ld_s	sceneobjptr,r0
}
	jsr	trace
	sub_sv	v1,raydir	; raydir = (Viewing angle - 2*dirangle*normal)
	nop
	
	;; here v0 is the reflected color
	mul_sv	ks,v0,>>#30,v0
	nop
	add_p	v0,finalcolor
	
nospecular:
nophong:

abortearly:
		
rettrace:
{	sub_sv	v0,v0
	pop	v3
}
{	add_sv	finalcolor,v0
	pop	v6
}
	pop	v7,rz
	pop	v5
	rts
	pop	v4
	add	#1,r31		; increment current trace depth

;;
;; return the background color corresponding to the viewing angle
;; this just multiplies a "background delta" by the Z component
;; of the viewing angle, and adds it to the standard background color
;;

;; if the Z component of the viewing angle is negative, bounce it off
;; of the (perturbed) water plane
;;
	
retbgcolor:
.if 0
;; original type code
	mul	v3[2],v3[2],>>#32,v3[2]    ;; >>#30 to make 2.30; >>#34 to make 4.24
        ld_sv  deltacolor,v0
        sat    #24,v3[2],v3[2]

{	mul_sv	v3[2],v0,>>#24,v0
        jmp     rettrace
}
	nop
        add_p   v0,finalcolor

.else

;; severe hackery -- treat reflections differently from eye
;; rays
{       cmp     #RAYDEPTH-1,r31           ; check depth of trace
	mul	v3[2],v3[2],>>#32,v3[2]    ;; >>#30 to make 2.30; >>#34 to make 4.24
        mv_s    v3[2],v3[3]             ; save original value
}
{       ld_sv  deltacolor,v0
        bra     ne,reflection
        abs     v3[3]
}
        sat    #24,v3[2],v3[2]

{	mul_sv	v3[2],v0,>>#24,v0
        jmp     rettrace
}
	nop
        add_p   v0,finalcolor

reflection:
{       mul_sv  v3[3],v0,>>#30,v0
        jmp     rettrace
}
        nop
        add_p   v0,finalcolor

.endif

;
; add a phong hilight to a bouncing ball
;
phong:
        ld_sv   thelight,v0
	cmp	#0,finalcolor[3]
        dotp    raydir,v0,>>#30,r0  ; r0 == phong scale factor
	bra	eq,nophong,nop
{       mul     r0,r0,>>#30,r0
        cmp     #0,r0
}
        bra     le,nophong
        mul     r0,r0,>>#30,r0
        mv_s    #fix(1.0,30),r1
        mul     r0,r0,>>#30,r0
        nop

        ;; OK, blend by factor r0 between white and
        ;; current final color
        sub     r0,r1,r1        ; r1 == 1.0 - r0
        mul_sv  r1,finalcolor,>>#30,finalcolor
        bra     nophong
        add     r0,finalcolor[0]
        nop

