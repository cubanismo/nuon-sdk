	
/*  Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/
	;; scene control file for raytracer
	;; 
	;;
;; set to 1 for RGB colors (you
;; *don't* want to do this!)
	
RGB=0

	;; lights for the scene
	;; the light structure consists of three small vectors:
	;; the first are the lighting coefficients (only kl matters)
	;; the second is the direction of the light
	;; the third is the light's color
	;; then comes a scalar giving the object (if any) associated
	;; with this light

	.align.sv
	;; ambient light
ambient:
	.dc.sv	fix(0.17,14), fix(0.17,14), fix(0.17,14), 0

l1:
	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(0.99,14), 0, 0, fix(0.75,14)

thelight:
.if 1
	;; light direction (TOWARDS the light)
	.dc.sv	fix(0.1641527,14), fix(-0.54717566,14), fix(0.8207635,14),0
.else
	.dc.sv	fix(0.5,14), fix(0.0,14),fix(0.866,14),0
.endif
	;; light color
	.dc.sv	fix(1.0,14), fix(1.0,14), fix(1.0,14), 0

	;; associated object, and 1 reserved long
	.dc.s	0xdeadbeef, 0

;; size of spheres: must be > 0.5
;;BALLSIZE = 0.8
BALLSIZE = 0.75

	;; a diffuse sphere
	.align.v
s1:
	;; center of sphere (for animation)
;;	.dc.sv	fix(0.25,8), fix(4.0,8), fix(0.5,8), 0
	.dc.sv	fix(1.0,8), fix(5.5,8), fix(0.0,8), 0

	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(1.0,14), fix(0.0,14), 0, 0

	.dc.sv	fix(0.8,14), 0, 0, 0
	.dc.sv	fix(0.8,14), 0, 0, 0

	;; radius of sphere
	.dc.s	fix(BALLSIZE, 24)

	;; 1/radius of sphere
	.dc.s	fix(1.0/BALLSIZE, 30)



	;; the second bouncing ball sphere
	.align.v
s2:
	;; center of sphere
;;	.dc.sv	fix(-1.25,8), fix(5.5,8), fix(0.75,8), 0
	.dc.sv	fix(-1.0,8), fix(6.0,8), fix(0.6,8), 0

	;; lighting coefficients:	kd, ks, kt, kl
;;	.dc.sv	fix(0.99,14), fix(-0.5,14), 0, 0
        .dc.sv  fix(0.6,14), fix(-0.5,14), 0, 0

	;; basic color
	.dc.sv	fix(0.7,14), fix(0.5,14), fix(0.0,14), 0
	;; alternate color
	.dc.sv	fix(0.7,14), fix(0.5,14), fix(0.0,14), 0

	;; radius of sphere
	.dc.s	fix(BALLSIZE, 24)

	;; 1/radius of sphere
	.dc.s	fix(1.0/BALLSIZE, 30)


	;; a reflective sphere
	.align.v
mousesphere:
	;; center of sphere (for animation)
	.dc.sv	fix(0.0,8), fix(8.0,8), fix(-0.2,8), 0

	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(0.0,14), fix(0.65,14), 0, 0

	;; color1
	.dc.sv	fix(0.0,14), fix(0.0,14), fix(0.0,14), 0

	;; color2
	.dc.sv	fix(0.0,14), fix(0.0,14), fix(0.0,14), 0

	;; radius of sphere
	.dc.s	fix(BALLSIZE, 24)

	;; 1/radius of sphere
	.dc.s	fix(1.0/BALLSIZE, 30)

	;; a big sphere to simulate the ground plane
	.align.v
p1:
	;; center of sphere
;;	.dc.sv	fix(0.0,8), fix(0.0,8), fix(-101.25,8), 0
	.dc.sv	fix(0.0,8), fix(0.0,8), fix(-100.75,8), 0

	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(0.0,14), fix(0.5,14), fix(1.0,14), 0

.if RGB
	;; basic color
	.dc.sv	fix(0.7,14), fix(0.1,14), fix(0.1,14), 0
	;; alternate color
	.dc.sv	fix(0.9,14), fix(0.9,14), fix(0.9,14), 0
.else
	;; basic color
	.dc.sv	fix(0.7,14), fix(0.1,14), fix(0.1,14), 0
	;; alternate color
	.dc.sv	fix(0.9,14), fix(0.9,14), fix(0.9,14), 0
.endif

	;; radius of sphere
	.dc.s	fix(100.0, 24)
	;; 1/radius of sphere
	.dc.s	fix(1.0/100.0, 30)

	; scene objects
	; this is the master list of objects to use for
	; intersection testing

	.align.v
scene:
	.dc.s	p1
	.dc.s	s1
	.dc.s	s2
	.dc.s	mousesphere
	.dc.s	0
sceneobjptr:
	.dc.s	scene
	
	; shadow objects
	; these are the objects that might concievably cast shadows
	; (i.e. everything but the shadow plane)
shadowobjs:
	.dc.s	s1
	.dc.s	s2
	.dc.s	mousesphere
	.dc.s	0
shadowobjptr:
	.dc.s	shadowobjs

	;
	; scanline objects
	; this is a list of objects on the current scan line;
	; use this for eye rays
	; it's recalculated each frame
	;

scanlineobjs:
	.dc.s	p1
	.dc.s	s1
	.dc.s	s2
	.dc.s	mousesphere
	.dc.s	0
scanlineobjptr:
	.dc.s	scanlineobjs

	;
	; these are the objects that are animated; a 0 terminated
	; list
	;

	.align.v
	; animation records:
	; consist of velocity (x,y,z)
	; max (x,y,z)
	; min (x,y,z)
s1pos:
        /* position */
        .dc.s   0x00400000      /* 0.25 */
        .dc.s   0x04000000      /* 4.0 */
        .dc.s   0x00800000      /* 0.5 */
	.dc.s	0
	
s1vel:
	/* velocity */
	.dc.s	0x000f0000/SPEED
	.dc.s	0x00410000/SPEED
	.dc.s	0x001f0000/SPEED	/* VELOCITY:	1/8 */
	.dc.s	0

s2pos:
        /* position */
        .dc.s  -0x00b00000      /* -1.25 */
        .dc.s   0x00300000      /* 5.5 */
        .dc.s   0x00700000      /* 0.75 */
	.dc.s	0
	
s2vel:
	/* velocity */
	.dc.s	-0x00270000/SPEED
	.dc.s	-0x004c0000/SPEED	/* VELOCITY */
	.dc.s	-0x0050c000/SPEED
	.dc.s	0
		
maxvals:
	.dc.s	0x03c00000	/* maximum X (8.24) */
;;	.dc.s	0x0c000000	/* maximum Y (8.24) */
	.dc.s	0x0ff00000	/* maximum Y (8.24) */
	.dc.s	0x03400000	/* maximum Z (8.24) */
	.dc.s	0
minvals:
	.dc.s	-0x03c00000	/* minimum X (8.24) */
	.dc.s	 0x01c00000	/* minimum Y (8.24) */
	.dc.s	-0x01a00000     /* minimum Z */
	.dc.s	0
	
	; scene lights
lights:
	.dc.s	l1
	.dc.s	0

	.align.v
eyepoint:
	.dc.v	0,0,0,0
	
	.align.sv
	;; background color
.if 1
bgcolor:
        .dc.sv  fix(0.2,14), fix(0.0, 14), fix(0.45,14),0
deltacolor:
        .dc.sv  fix(0.7,14), fix(0.0, 14), fix(-0.45,14),0
.else
bgcolor:
        .dc.sv  fix(0.9,14), fix(0.0, 14), fix(0.0,14),0
deltacolor:
        .dc.sv  fix(-0.75,14), fix(0.0, 14), fix(0.35,14),0
.endif

wateroffset:
	.dc.sv 0,0,0,0

	;; black
black:	
	.dc.sv	0,0,0,0

	;; white
white:	
	.dc.sv	fix(0.99,14), fix(0.99,14), fix(0.99,14), 0


