/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/
	;; animation functions for raytracer
	;; 
	;;
	;;
	.module move
	.export default_move
	.export mouse_sphere_move
	.export light_sphere_move
	.export mouse_box_move
	
	;; joystick button defines
	OBJECT_BITS = (4+16)
	START_BIT =   (13+16)
	A_BIT     =   (14+16)
	B_BIT     =   (3+16)
	NUON_BIT  =   (12+16)

	;
	; default animation code
	; Entered with: r0 == ptr to object
	;  uses: v0, v1
	;
	
	animposptr = r0
	animvelptr = r1
	animmaxptr = r2
	animminptr = r3

	animpos = r4
	animvel = r5
	animmax = r6
	animmin = r7
	
default_move:
	add	#OFF_BASEPT,r0
	add	#(OFF_VELOCITY-OFF_BASEPT),r0,r1
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

	;
	; mouse controlled movement code;
	; light version (used when the L
	; button is down)
	;
light_sphere_move:
{	push	v2
	add	#OFF_BASEPT,r0,v2[0]
}
        ld_s    usejoyval,r0
        ld_v   (v2[0]),v1	; get old position
	copy	r0,r1
	bits	#3,>>#OBJECT_BITS,r1	; check for object number
	cmp	#0,r1
	bra	eq,go_move,nop
no_move:
	rts
	pop	v2
	nop
		
	;
	; mouse controlled movement code
	; this is the sphere version
	;
mouse_sphere_move:
{	push	v2
	add	#OFF_BASEPT,r0,v2[0]
}
        ; look for the joystick's current value
        ld_s    usejoyval,r0
        ld_v   (v2[0]),v1	; get old position
	copy	r0,r1
	bits	#3,>>#20,r1	; check for object number
	cmp	#1,r1
	bra	ne,no_move,nop
go_move:
        copy    r0,r1
        asl     #24,r1
        asl     #16,r0
;;        asr     #7,r0,v1[0]
;;        asr     #7,r1,v1[1]

        add     r0,>>#7,v1[0]
        add     r1,>>#7,v1[1]
	;; limit how far we can go
	sat	#31,v1[0]
	sat	#31,v1[1]

        ; move up or down based on button states
        ld_s    usejoyval,r0
        sub     r1,r1
        btst    #A_BIT,r0      ; check for down arrow
        bra     eq,`notDown,nop
        mv_s    #-0x000f0000,r1
        bra     `doneButton,nop
`notDown:
        btst    #B_BIT,r0      ; check for up arrow
        bra     eq,`notUp,nop
        mv_s    #0x000f0000,r1
        bra     `doneButton,nop
`notUp:
        btst    #START_BIT,r0      ; check for Start button
        bra     eq,`doneButton,nop
        sub_sv  v1,v1
        mv_s    #$07f80000,v1[1]

`doneButton:
        add     r1,v1[2]        ; update Z coordinate

        st_v   v1,(v2[0])

	rts
	pop	v2
	nop

	;
	; mouse controlled movement code
	; this is the box version; it works only
	; when the R button is held down
	;
	
	posptr = v2[0]
	numplanes = v2[1]
		
mouse_box_move:
{	push	v2
	add	#OFF_BASEPT,r0,posptr
}
	; load the original position
        ld_s    usejoyval,r0	; get joystick value
	ld_v	(posptr),v1
	copy	r0,r1
	bits	#3,>>#OBJECT_BITS,r1     ; check for object number
	cmp	#2,r1		
	bra	ne,no_move,nop

	push	v1
	
        copy    r0,r1
        asl     #24,r1
        asl     #16,r0
;;        asr     #7,r0,v1[0]
;;        asr     #7,r1,v1[1]

        add     r0,>>#7,v1[0]
        add     r1,>>#7,v1[1]

	;; limit how far we can go
	sat	#31,v1[0]
	sat	#31,v1[1]

        ; move up or down based on button states
        ld_s    usejoyval,r0
        sub     r1,r1
        btst    #A_BIT,r0      ; check for down arrow
        bra     eq,`notDown,nop
        mv_s    #-0x000f0000,r1
        bra     `doneButton,nop
`notDown:
        btst    #B_BIT,r0      ; check for up arrow
        bra     eq,`notUp,nop
        mv_s    #0x000f0000,r1
        bra     `doneButton,nop
`notUp:
        btst    #START_BIT,r0      ; check for Start button
        bra     eq,`doneButton,nop
        sub_sv  v1,v1
        mv_s    #$07f80000,v1[1]

`doneButton:
        add     r1,v1[2]        ; update Z coordinate

	;; get the old position
	pop	v0

	;; store the new position
        st_v   v1,(posptr)

	sub_sv	v0,v1		; now v1 = new position - old position

	;; update all plane base points
	add	#(OFF_POLY_NUMPLANES-OFF_BASEPT),posptr
	ld_s	(posptr),numplanes	; get number of planes
	add	#(OFF_POLY_PLANES-OFF_POLY_NUMPLANES),posptr
`planeloop:
	ld_sv	(posptr),v0	; get plane base pt
	sub	#1,numplanes
{	bra	gt,`planeloop
	add_p	v1,v0		; plane_pt += (new_base - old_base);
}
	st_sv	v0,(posptr)
	add	#16,posptr	; skip point + normal
	
	rts
	pop	v2
	nop
