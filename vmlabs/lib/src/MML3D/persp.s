/*
 * Copyright (C) 1995-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */
	;
	; 3D pipeline -- standard perspective transformation
	; Version 1.0 for C
	;
	; local storage required:
	;	standard amount
	; stack required:
	;	12 long words


	.module	persp_s
	.include "pipeline.i"
	.export	_persp_init, _persp_end

	.align CODEALIGN
			
_persp_init:	
{	rts	nop
	add	#persp - _persp_init,r0
}
	
;************************************************************************
;* persp: do perspective transformation on a point
;* Inputs:
;*  r0 = pointer to output vertex (in standard format)
;*  r1 = pointer to input vertex (in standard format)
;*
;* Outputs:
;*  writes output to area pointed to by r0
;*
;* Converts coordinates from camera coordinates to screen coordinates
;* This function affects only the x and y coordinates, which are
;* modified by:
;*		x = (focald*x)/z + xcenter
;*		y = (focald*y)/z + ycenter
;*
;************************************************************************

outptr	=	r0
inptr	=	r1

; v1 is trashed by recip()

; v2 and v3 hold miscellaneous stuff
; v2 holds camera data as defined in the input parameter block, namely:
; camera:
; camera_focal_length:
;	.ds.s	1	; focal length for camera (16.16 fixed point)
; camera_back_clip:
;	.ds.s	1	; distance to back clipping plane (16.16 fixed point)
; camera_center_x:
;	.ds.s	1	; center of viewpoint (16.16 fixed point)
; camera_center_y:
; 	.ds.s	1	; center of viewpoint (16.16 fixed point)
	
Vmisc1	=	v2
focald	=	v2[0]
backclip =	v2[1]
xcenter	=	v2[2]
ycenter	=	v2[3]

Vmisc2	=	v3
savz	=	Vmisc2[0]
savoutptr =	Vmisc2[1]			; saved copy of pointer for output

; v1 holds the input point (x,y,z,u)
Vpt		=	v1
ptx		=	r4
pty		=	r5
ptz		=	r6
ptu		=	r7

persp:
	ld_s	recip_func,r2		; get address of recip routine
{	ld_v	(inptr),Vpt
	sub	r1,r1			; zero r1
}

{	push	Vmisc2,rz
	jsr	(r2)			; call "recip" routine
	copy	outptr,savoutptr	; save old r0 (== destination for output)
}
{	ld_v	camera,Vmisc1		; branch delay slot #1:
	copy	ptz,r0
}
{	add	#16,r1			; branch delay slot #2: r0 is a 16.16 point number
	push	v1			; v1 is trashed by recip
}
	

; now r0 holds the reciprocal of z, and r1 holds the fracbits for it
	pop	v1			; wait for recip to finish

{//	copy	r0,savz			; save 1/z into the point
	mul	focald,r0,>>r1,r0	; now r0 is a 16.16 product (focald/z)
}
{	copy	savoutptr,r2		; set r2 == place to write output
}
{	mul	r0,ptx,>>#16,ptx
	pop	Vmisc2,rz
}
{	mul	r0,pty,>>#16,pty
}
{	rts
	add	xcenter,ptx
}
	add	ycenter,pty		; branch delay slot #1
	st_v	Vpt,(r2)		; branch delay slot #2

_persp_end: