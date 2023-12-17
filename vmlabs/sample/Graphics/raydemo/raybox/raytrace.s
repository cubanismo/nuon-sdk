	;;
	;; ray intersection code
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
	
	iobj = v4[0]		; nearest intersecting object
	mindist = v4[1]		; distance to nearest intersecting object
	curobj = v4[2]		; current object under consideration
	scnptr = v4[3]		; pointer into scene
	ipt = v5		; point of intersection
	lastobj = v6[0]		; last object read

first_intersection:
{	push	v4
	subm	iobj,iobj
	copy	r0,scnptr
}
{	push	v5
	sub	#1,iobj,mindist ; set mindist = -1
}
{	push	v6,rz
	bclr	#31,mindist	; set mindist = $7ffffff
}
	ld_s	(scnptr),curobj
	add	#4,scnptr
objloop:
	copy	curobj,lastobj	; copy and test
	bra	eq,endobjloop,nop
	
	ld_s	(lastobj),r1	; r1 == pointer to intersection function
	copy	lastobj,r0	; parameter for intersection code
	jsr	(r1),nop
	
			; check for intersection with (v2,v3) ray

	ld_s	(scnptr),curobj	; pre-load next object
	add	#4,scnptr
	
	;; if (dist > 0 && dist < mindist)
{	cmp	#0,r0
}
{	bra	le,objloop,nop
	cmp	r0,mindist	; if (mindist - dist <= 0 then distance is too big)
}
	bra	le,objloop,nop
	
{	mv_s	lastobj,iobj
	copy	curobj,lastobj
}
	bra	ne,objloop
	copy	r0,mindist
	mv_v	v1,ipt

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
	lightobj = v4[0]	;; object casting the light
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
	ld_s	(lights),lightobj
	push	v3

{	add	#OFF_LIGHTCOEFF,lightobj,light
	push	v7
}
{	ld_sv	(light),v1		; v1 == lighting coefficients
	add	#OFF_BASEPT-OFF_LIGHTCOEFF,light
}
{	ld_v	(light),v0	; get light position (it will be turned into direction)
	sub	#OFF_BASEPT-OFF_COLOR1,light
}
{	copy	v1[3],kl	; kl = intensity of light (2.30)
	push	v2,rz		; really just to save rz
}

	;; normalize the vector pointing at the light
	;; the vector should point from the point towards the light
	;; so we want to take (light - pt)
	jsr	vector_normalize
	sub_sv	ipt,v0
	nop
	
	;; vector comes back normalized in v3, which is
	;; lightdir
		
{	dotp	normal,lightdir,>>#30,r1        ; r1 = dot product of lightdir and normal (2.30)
	ld_sv	ambient,lightcolor	; initialize light to ambient
}
{	mul	kd,kl,>>acshift,kl	; kl is a 2.30 lighting scale factor
	st_sv	lightdir,lastlight	; save the last light
}
	cmp	#0,r1		; are we pointing towards the light?
{	bra	le,endlight,nop	; no --we're finished with lighting
	mul	r1,kl,>>acshift,kl ; kl is a 2.30 scale factor
}
	nop
	

	;; check for shadows
	;; we do this by calling first_intersection with parameters
	;; r0 == list of shadow objects
	;;  raybase = ipt = v2
	;;  raydir = lightdir = v3

{	jsr	first_intersection
	copy	kl,v1[0]	; get the light's color
	mv_s	kl,v1[1]
}
{	ld_s	shadowobjptr,r0		; get pointer to list of shadow objects
	copy	kl,v1[2]
}
	push	v1		; save scaled color


	;; check for a blocking object
{	pop	v1		; restore scaled color
	cmp	r0,lightobj	; is the light itself the closest object?
}
{	bra	eq,lightok,nop
	cmp	#0,r0		; no object at all found?
}
{	jmp	ne,endlight,nop	
	sub	lightcolor[3],lightcolor[3]	; zero last component of lightcolor
}
	
lightok:
	; add in this light's contribution
	add_sv	v1,lightcolor
	or	#1,<>#-16,lightcolor[3]	; set flag for no shadow
	
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
	finalcolor = v4		; final output color (only 3 components used; 4th is a flag
				; set by diffuse_light for shadow/non-shadow)

	lightcoeff = v5		; lighting coefficients
	kd = lightcoeff[0]     ; diffuse
	ks = lightcoeff[1]     ; specular term -- reflections
	kt = lightcoeff[2]     ; used for water
	kl = lightcoeff[3]     ; intrinsic lighting

	;; NOTE:	diffuse_light assumes v6 is normal
	normal = v6		; object's surface normal
	iobj	= v7[0]		; intersection object
	dirangle = v7[1]	; directional angle (dot product of normal and direction)
	colorfn	= v7[2]		; color function for procedural textures
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
{       push    v3
	cmp	#0,r0
}
;
; first_intersection expects r0,v2,and v3 to be set up the same as they
; were by our caller, so we don't need to shuffle them at all
;
{	jsr	ne,first_intersection,nop	; will be annulled if the branch above is taken
	ld_sv	bgcolor,finalcolor
}

	copy	r0,iobj		; save intersection object, and test to see if it was NULL
{	jmp	eq,retbgcolor,nop
	mv_v	v1,ipt
	add	#OFF_NORMAL_FN,iobj
}
	ld_s	(iobj),r1	; get normal function
	add	#(OFF_LIGHTCOEFF-OFF_NORMAL_FN),iobj
	jsr	(r1)
	ld_sv	(iobj),lightcoeff
	nop

{	mv_v	v0,normal
	sub	#(OFF_LIGHTCOEFF-OFF_COLOR_FN),iobj
}
		
	;; if the surface has intrinsic light, add its lighting coefficient to
	;; each component of the ambient
	;; if the surface does diffuse reflections, calculate diffuse lighting
	
	cmp	#0,kd		; check for diffuse lighting

{	jmp	eq,nodiffuse
	copy	kl,finalcolor[0]	; add intrinsic light
	dotp	normal,v3,>>#32,dirangle ;calculate angle of reflection (4.28)
}
{	sub	finalcolor[1],finalcolor[1]	; intrinsic light must be white
	jsr	diffuse_light		; call the diffuse lighting subroutine if the "jmp"
					; above was annulled
	ld_s	(iobj),colorfn
}
{	sub	finalcolor[2],finalcolor[2]	; add intrinsic light
	subm	finalcolor[3],finalcolor[3]
}
{	mv_s	kd,r0
	add	#OFF_COLOR1-OFF_COLOR_FN,iobj
}


	;; diffuse_light returns a color in v0

	;; finish ambient + diffuse lighting
	;; get surface color
	cmp	#0,colorfn
{	jsr	ne,(colorfn)
	add_sv	v0,finalcolor		; v0[3] contains a flag set by diffuse_color
}
	ld_p	(iobj),v1
	sub	#OFF_COLOR1,iobj,r0
	
	;; surface color is now available in v1
	
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
}

	jsr	vector_normalize		;; NOTE: delay slot for jmp to phong
	sub_sv	v1,raydir	; NOTE: delay slot for jmp to phong
				; sets raydir = (Viewing angle - 2*dirangle*normal)
	mv_v	raydir,v0

{	ld_s	sceneobjptr,r0
	jsr	trace
}
	nop
	mv_v	v3,raydir
	
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
{	add_p	finalcolor,v0
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
;; original code
	mul	v3[2],v3[2],>>#34,v3[2]    ;; >>#30 to make 2.30; >>#34 to make 4.24
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
        ld_sv   lastlight,v0
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


	.include "sphere.s"
	.include "plane.s"
	.include "box.s"
	