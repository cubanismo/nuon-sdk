/* Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/
	;; logo texture map
	;;
	;;
	;; this function is entered with:
	;; r0 pointing at object
	;; v1 holding object color
	;; v2 holding (world coordinates of) point on object
	;; v6 holding the object's surface normal
	;;
	;; it should return with v1 being an updated
	;; color
	;;
	.module logo

SLOPE = fix(1.5,24)
	

	xval = v4[0]
	yval = v4[2]
	temp = v4[1]
	zero = v4[3]
	
	.export vmlabs_logo
vmlabs_logo:
{	push	v4
	add	#OFF_BASEPT,r0
}
	ld_v	(r0),v4		; get the base point
	push	v1
	;; set v4 = ipt - base pt; but only xval and yval matter
{	sub	xval,v2[0],xval
	subm	yval,v2[2],yval
	mv_s	#fix(1.2/(BOXSIZE),30),r1
}
	;; normalize coordinates
{	mul	r1,xval,>>#30,xval
	mv_s	#fix(4.5/5.0,24),temp
}
{	mul	r1,yval,>>#30,yval
	sub	zero,zero
}
	;; if x >= temp (i.e. x - temp >= 0) return basic color
	cmp	temp,xval
	subm	temp,zero,temp		;; negate temp

	;; if x <= -temp return basic color
{	bra	ge,`returnbasic,nop
	cmp	temp,xval
}
{	bra	le,`returnbasic,nop
	cmp	#0,yval
}
	bra	ge,`tophalf,nop

	;;
	;; bottom half of picture
	;;
	add	#fix(3.0/5.0,24),yval
	cmp	#fix(-1.5/5.0,24),yval
{	bra	le,`returnbasic,nop
	cmp	#0,yval
	mv_s	#SLOPE,temp
}
{	bra	le,`returnblack,nop
	mul	xval,temp,>>#24,temp
}
	nop
	cmp	temp,yval
	bra	ge,`brancharound,nop
	sub	#fix(4.0/5.0,24),xval
	mv_s	#-SLOPE,temp
	mul	xval,temp,>>#24,temp
	nop
	cmp	temp,yval
	bra	le,`returnbasic,nop
	bra	`returnblack,nop
	
`brancharound:
	;; temp still has SLOPE*xval
	;; check for y > -SLOPE*xval
	neg	temp
	cmp	temp,yval
{	bra	ge,`returnblack,nop
	mv_s	#SLOPE,temp
}
	add	#fix(4.0/5.0,24),xval
	mul	xval,temp,>>#24,temp
	nop
	cmp	temp,yval
	bra	le,`returnbasic,nop
	bra	`returnblack,nop
	
	;;
	;; top half of picture
	;;
`tophalf:
	cmp	#fix(4.5/5.0,24),yval
{	bra	ge,`returnbasic,nop
	cmp	#fix(3.0/5.0,24),yval
}
{	bra	ge,`returnblack,nop
	mv_s	#SLOPE,temp
}
	mul	xval,temp,>>#24,temp
	nop
{	cmp	temp,yval
	subm	temp,zero,temp		; negate temp
}
{	bra	le,`returnblack,nop
	cmp	temp,yval
}
	bra	le,`returnblack,nop
	
	;; return basic color	
`returnbasic:
{	pop	v1
	rts
}
	pop	v4
	nop

	;; return black
`returnblack:
{	pop	v1
	rts
}
	pop	v4
	sub_sv	v1,v1


	.segment ray2d
white:
	.dc.s	$c0808000
other:
;;;	.dc.s	$55c66900 ;; red
	.dc.s	$6c525c00 ;; green
	
	.segment ray2c
	.export chkboard_color
chkboard_color:
	eor	v2[0],v2[1],r0
{	btst	#24,r0
	ld_p	white,v1
}
	rts	ne,nop
	rts
	ld_p	other,v1
	nop
	