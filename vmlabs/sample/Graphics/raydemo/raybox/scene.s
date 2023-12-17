	;;
	;; scene control file for raytracer
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
;

	;; lights for the scene
	;; the light structure consists of three small vectors:
	;; the first are the lighting coefficients (only kl matters)
	;; the second is the direction of the light
	;; the third is the light's color
	;; then comes a scalar giving the object (if any) associated
	;; with this light

USE_WATER = 1
	
	.align.sv
	;; ambient light
ambient:
//	.dc.sv	fix(0.17,14), fix(0.17,14), fix(0.17,14), 0
	.dc.sv	fix(0.20,14), fix(0.20,14), fix(0.20,14), 0

lastlight:
.if 1
	;; light direction (TOWARDS the light)
	.dc.sv	fix(0.1641527,14), fix(-0.54717566,14), fix(0.8207635,14),0
.else
	.dc.sv	fix(0.0,14), fix(0.0,14),fix(1.0,14),0
.endif

;; size of spheres: must be > 0.5
BALLSIZE = 0.75
;;BALLSIZE = 0.6
LIGHTSIZE = 0.33
	
;;
;; size of the VM Labs box
;;
//BOXSIZE = 0.75
BOXSIZE = 1.0
	
	.align.v
	;; a lit sphere
l1:
	;; pointer to intersection function
	.dc.s sphere_intersect
	;; pointer to normal function
	.dc.s sphere_normal
	;; pointer to movement function
	.dc.s	light_sphere_move
	;; pointer to color function (or NULL)	
	.dc.s	0
	
	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(0.0,14), fix(0.0,14), 0, fix(0.75,14)

	;; color of sphere
	.dc.s	0xe0808000
	
	;; radius of sphere
	.dc.s	fix(LIGHTSIZE, 24)

	;; center of sphere (for animation)
//	.dc.v	fix(1.8,24), fix(9.75,24), fix(-0.75,24), 0
	.dc.v	fix(1.65,24), fix(10.50,24), fix(0.65,24), 0

	;; velocity of sphere
	.dc.v	fix(0.08/SPEED,24), fix(0.25/SPEED, 24), fix(0.12/SPEED,24), 0

	;; 1/radius of sphere
	.dc.s	fix(1.0/LIGHTSIZE, 24)



	
	;; a diffuse sphere
	.align.v
s1:
	;; pointer to intersection function
	.dc.s sphere_intersect
	;; pointer to normal function
	.dc.s sphere_normal
	;; pointer to movement function
	.dc.s	default_move
	;; pointer to color function (or NULL)	
	.dc.s	0
	
	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(1.0,14), fix(0.0,14), 0, 0

	;; color of sphere
	.dc.s	0xc0808000
	
	;; radius of sphere
	.dc.s	fix(BALLSIZE, 24)

	;; center of sphere (for animation)
	.dc.v	fix(0.25,24), fix(4.0,24), fix(0.5,24), 0

	;; velocity of sphere
	.dc.v	fix(0.06/SPEED,24), fix(0.25/SPEED, 24), fix(0.125/SPEED,24), 0


	;; 1/radius of sphere
	.dc.s	fix(1.0/BALLSIZE, 24)


	;; the second bouncing ball sphere
	.align.v
s2:
	;; pointer to intersection function
	.dc.s sphere_intersect
	;; pointer to normal function
	.dc.s sphere_normal
	;; pointer to movement function
	.dc.s	default_move
	;; pointer to color function (or NULL)	
	.dc.s	0
	
	;; lighting coefficients:	kd, ks, kt, kl
        .dc.sv  fix(0.6,14), fix(-0.5,14), 0, 0

	;; color
	.dc.s	0x7da95200
	
	;; radius of sphere
	.dc.s	fix(BALLSIZE, 24)

	;; center of sphere
	.dc.v	fix(-1.25,24), fix(5.5,24), fix(0.75,24), 0

	;; velocity of sphere
	.dc.v	fix(-0.2/SPEED,24), fix(-0.3/SPEED,24), fix(-0.4/SPEED,24), 0
	
	;; 1/radius of sphere
	.dc.s	fix(1.0/BALLSIZE, 24)


	;; a reflective box
	.align.v
logobox:
	;; pointer to intersection function
	.dc.s polyhedron_intersect
	;; pointer to normal function
	.dc.s polyhedron_normal
	;; pointer to movement function
	.dc.s	mouse_box_move
	;; pointer to color function
	.dc.s	vmlabs_logo
//	.dc.s	texture_map
		
	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(0.6,14), fix(0.4,14), 0, 0
//	.dc.sv	fix(1.0,14), fix(0.0,14), 0, 0

	;; color
	.dc.s 0xc0808000
	
	;; radius of enclosing sphere
	.dc.s	fix(BOXSIZE, 24)

	;; center of object (for animation)
	.dc.v	fix(0.0,24), fix(14.0,24), fix(0.3,24), 0

	;; velocity
	.dc.v	fix(0.0,24), fix(0.0,24), fix(0.1,24), 0
	
	;; "last hit" normal
	.dc.sv	0, 0, fix(1.0,14), 0

	;; number of planes
	.dc.s	6
	.dc.s	0 ;; reserved
	
	;; planes, in the order "basept, normal"

	.dc.sv	fix(0.0+BOXSIZE,8), fix(14.0,8), fix(0.3,8), 0
	.dc.sv	fix(1.0,14), 0, 0, 0
	.dc.sv	fix(0.0-BOXSIZE,8), fix(14.0,8), fix(0.3,8), 0
	.dc.sv	fix(-1.0,14), 0, 0, 0

	.dc.sv	fix(0.0,8), fix(14.0+BOXSIZE,8), fix(0.3,8), 0
	.dc.sv	0, fix(1.0,14), 0, 0
	.dc.sv	fix(0.0,8), fix(14.0-BOXSIZE,8), fix(0.3,8), 0
	.dc.sv	0, fix(-1.0,14), 0, 0

	.dc.sv	fix(0.0,8), fix(14.0,8), fix(0.3+BOXSIZE,8), 0
	.dc.sv	0, 0, fix(1.0,14), 0
	.dc.sv	fix(0.0,8), fix(14.0,8), fix(0.3-BOXSIZE,8), 0
	.dc.sv	0, 0, fix(-1.0,14), 0
	

	;; a reflective sphere
	.align.v
shinyball:
	;; pointer to intersection function
	.dc.s sphere_intersect
	;; pointer to normal function
	.dc.s sphere_normal
	;; pointer to movement function
	.dc.s	mouse_sphere_move
	;; pointer to color function
	.dc.s	0
		
	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(0.0,14), fix(0.4,14), 0, 0

	;; color
	.dc.s 0x10808000
	
	;; radius of enclosing sphere
	.dc.s	fix(BALLSIZE, 24)

	;; center of sphere (for animation)
//	.dc.v	fix(-2.3,24), fix(8.0,24), fix(-0.25,24), 0
	.dc.v	fix(-1.8,24), fix(9.5,24), fix(-1.25,24), 0

	;; velocity
	.dc.v	fix(0.0,24), fix(0.0,24), fix(0.0,24), 0
	
	;; 1/radius
	.dc.s	fix(1/BALLSIZE,24)

	.align.v
	;; the ground plane -- water version
waterplane:
	// water world
	;; pointer to intersection function
	.dc.s polyhedron_intersect
	;; pointer to normal function
	.dc.s water_normal
	;; pointer to movement function
	.dc.s	default_move
	;; pointer to color function
	.dc.s 0

	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(0.0,14), fix(0.5,14), fix(0.0,14), 0

	;; color
	.dc.s 0xc0808000
	
	;; radius of enclosing sphere
	.dc.s	fix(100.0, 24)


	;; position
	.dc.v	fix(0.0,24), fix(0.0,24), fix(-1.0,24), 0
	;; velocity
	.dc.v	fix(0.0,24), fix(0.0,24), fix(0.0,24), 0
	;; "last hit" normal
	.dc.sv	fix(0.0,14), fix(0.0,14), fix(1.0,14), 0
	;; number of planes
	.dc.s	1
	.dc.s	0

	;; first plane
	.dc.sv	fix(0.0,8), fix(0.0,8), fix(-1.0,8),0
	.dc.sv	fix(0.0,14), fix(0.0,14), fix(1.0,14), 0
	;; second plane
	.dc.sv	fix(0.0,8), fix(15.0,8), fix(-1.0,8),0
	.dc.sv	fix(0.0,14), fix(1.0,14), fix(0.0,14), 0


	
	;; the ground plane -- checkerboard version
	.align.v
checkplane:

	;; pointer to intersection function
	.dc.s polyhedron_intersect
	;; pointer to normal function
	.dc.s polyhedron_normal
	;; pointer to movement function
	.dc.s	default_move
	;; pointer to color function
	.dc.s chkboard_color
//	.dc.s	texture_map
	;; lighting coefficients:	kd, ks, kt, kl
	.dc.sv	fix(0.99,14), fix(0.0,14), fix(0.0,14), 0

	;; color
	.dc.s 0xc0808000
	
	;; radius of enclosing sphere
	.dc.s	fix(100.0, 24)

	;; position
	.dc.v	fix(0.0,24), fix(0.0,24), fix(-1.0,24), 0
	;; velocity
	.dc.v	fix(0.0,24), fix(0.0,24), fix(0.0,24), 0
	;; "last hit" normal
	.dc.sv	fix(0.0,14), fix(0.0,14), fix(1.0,14), 0

	;; number of planes
	.dc.s	2
	.dc.s	0

	;; first plane
	.dc.sv	fix(0.0,8), fix(0.0,8), fix(-1.75-BALLSIZE,8),0
	.dc.sv	fix(0.0,14), fix(0.0,14), fix(1.0,14), 0
	;; second plane
	.dc.sv	fix(0.0,8), fix(40.0,8), fix(-1.75-BALLSIZE,8),0
	.dc.sv	fix(0.0,14), fix(1.0,14), fix(0.0,14), 0
	
	; scene objects
	; this is the master list of objects to use for
	; intersection testing
	;
	; KLUDGE: the ground plane must always come first
	; (see raymain.s for details)
	;
	.align.v
scene:
	.dc.s	checkplane
	.dc.s	s1
	.dc.s	s2
	.dc.s	shinyball
	.dc.s	logobox
	.dc.s	l1
	.dc.s	0
sceneobjptr:
	.dc.s	scene
	
	; shadow objects
	; these are the objects that might concievably cast shadows
	; (i.e. everything but the ground plane)
shadowobjs:
	.dc.s	l1
	.dc.s	s1
	.dc.s	s2
	.dc.s	shinyball
	.dc.s	logobox
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
	.dc.s	checkplane
	.dc.s	s1
	.dc.s	s2
	.dc.s	logobox
	.dc.s	l1
	.dc.s	shinyball
	.dc.s	0
scanlineobjptr:
	.dc.s	scanlineobjs

	
	;
	; these are the objects that are animated; a 0 terminated
	; list
	;

	.align.v
animlist:
	.dc.s	s1
	.dc.s	s2
	.dc.s	logobox
	.dc.s	shinyball
	.dc.s	l1
	.dc.s	0

	;; min/max. positions for various objects
	.align.v	
maxvals:
	.dc.s	0x03c00000	/* maximum X (8.24) */
	.dc.s	0x0ff00000	/* maximum Y (8.24) */
	.dc.s	0x03400000	/* maximum Z (8.24) */
	.dc.s	0
minvals:
	.dc.s	fix(-3.75,24)
	.dc.s	fix(1.75,24)
	.dc.s	fix(-1.75,24)	
//	.dc.s	-0x03c00000	/* minimum X (8.24) */
//	.dc.s	 0x01c00000	/* minimum Y (8.24) */
//	.dc.s	-0x01a00000     /* minimum Z */
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
	;;original sky -- light on top
bgcolor:
        .dc.sv  fix(0.2,14), fix(0.0, 14), fix(0.45,14),0
deltacolor:
        .dc.sv  fix(0.7,14), fix(0.0, 14), fix(-0.45,14),0
.else
	;; new sky -- light at horizon
bgcolor:
//        .dc.sv  fix(0.55,14), fix(-0.02, 14), fix(0.7,14),0
	  .dc.sv  fix(0.0,14), fix(0.0,14), fix(0.0,14), 0
deltacolor:
//        .dc.sv  fix(-0.48,14), fix(-0.02, 14), fix(0.1,14),0
	.dc.sv fix(0.8,14), fix(0.0,14), fix(0.0,14), 0
.endif



