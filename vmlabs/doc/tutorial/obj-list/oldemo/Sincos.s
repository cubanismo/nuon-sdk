;
; sincos -- compute sine and cosine to about 20 bits precision (each)
;
; Copyright 1996 VM Labs, Inc.
;
; Usage ==========================
;
;	r0 <- the argument, expressed as "rotations" in 16.16 format
;	call sincos
;	r0 -> the cosine, 2.30 format
;	r1 -> the sine, 2.30 format

;
; Interface ========================
;
	.module	sincos
	.export	sincos
;
; Input parameters
;
        x	= r0
;
; Results
;
	cosine	= r0
        sine	= r1
;
; Implementation ====================
;
; Working register declarations
;
	quadrant	= r0
	one		= r3
	q1		= r7
	q2		= r4
	temp		= r5
	y1		= r1
	y2		= r6
	x1		= r2
	x2		= r3
;
; Value definitions
;
	quadShift	= 14		; shift to right-adjust quadrant "field"
	quad2or4Shift	= 0		; bits to right of bit we want
	quad3or4Mask	= 2		; mask
;
; Coefficients for cubic polynomial evaluation
;
	A0 = fix(1.57079101108022,30)
	A1 = fix(-0.645892849558497,30)
	A2 = fix(0.0794343446081996,30)
	A3 = fix(-0.00433309527758793,30)

;
; Jump table for processing according to quadrant.
;
	.segment local_ram
jmpTable:
	.dc.s	quad1		; quadrant 1 routine (0.00 <= x < 0.25)
	.dc.s	quad2		; quadrant 2 routine (0.25 <= x < 0.50)
	.dc.s	quad3		; quadrant 3 routine (0.50 <= x < 0.75)
	.dc.s	quad4		; quadrant 4 routine (0.75 <= x < 1.00)

;
; The "sincos" code.
;
	.segment instruction_ram
sincos:
{	mv_s	#A3,y1			; load the first coefficient
	lsl	#18,x,x1		; normalize 1/4-rotation to 0.32
}
{	jmp	eq,rightAngle,nop	; jump if exact right angle
	mv_s	#fix(1,30),one		; load constant 1 in 2.30 format
	lsr	#2,x1			; adjust 1/4-rotation to 2.30
}
{	mv_s	x1,q1			; save q1 = adjusted quarter-rotation
	mul	x1,x1,>>#30,x1		; x1 = q1 ^ 2
	sub	x1,one,x2		; calculate "opposite" 1/4-rotation
}
{	mul	x2,x2,>>#30,x2		; x2 = q2 ^ 2
	mv_s	x2,q2			; save q2 = adjusted quarter-rotation
}
;
; Evaluate the polynomial using Horner's method.  Three things are going
; on in parallel:
;
;  1. Horner's method is used to calculate a 1/4 rotation result.
;  2. Horner's method is used to calculate opposite 1/4 rotation result.
;  3. A jump table is being processed to handle the two results based
;     on quadrant.
;
{	mul	x1,y1,>>#30,y1
	mv_s	y1,y2
	lsr	#quadShift - 2,x,quadrant ; save the "quadrant" field of x
}
{	mul	x2,y2,>>#30,y2
	mv_s	#A2,temp
	and	#3 << 2,quadrant	; clear unwanted bits from quadrant
}
	add	temp,y1
{	mv_s	#jmpTable,temp		; get address of jump table
	mul	x1,y1,>>#30,y1
	add	temp,y2
}
{	mul	x2,y2,>>#30,y2
	mv_s	#A1,temp
	add	temp,quadrant		; index into jump table
}
	add	temp,y1
{	ld_s	(quadrant),quadrant	; get address from jump table
	mul	x1,y1,>>#30,y1
	add	temp,y2
}
	mul	x2,y2,>>#30,y2
	mv_s	#A0,temp
{	jmp	(quadrant)
	add	temp,y1
}
{	mul	q1,y1,>>#30,y1		; multiply y1 polynomial by q1
	add	temp,y2
}
	mul	q2,y2,>>#30,y2		; multiply y2 polynomial by q2
;
; The following code segments are reached via the jump table, with
; a segment for each quadrant of a rotation.
;
quad1:
	rts
	mv_s	y1,sine			; sine = y1
	mv_s	y2,cosine		; cosine = y2
quad2:
	rts
	sub	y1,#0,cosine		; cosine = -y1
	mv_s	y2,sine			; sine = y2
quad3:
	rts
	sub	y1,#0,sine		; sine = -y1
	sub	y2,#0,cosine		; cosine = -y2
quad4:
	rts
	mv_s	y1,cosine		; cosine = y1
	sub	y2,#0,sine		; sine = -y2
;
; Special case precise result for exact right angle.
;
rightAngle:
{	mv_s	#jmpTable,temp		; get address of jump table
	lsr	#quadShift - 2,x,quadrant ; save the "quadrant" field of x
}
	and	#3 << 2,quadrant	; clear unwanted bits from quadrant
{	mv_s	#fix(1,30),y2		; y2 = 1
	add	temp,quadrant		; calculate jump table address
}
	ld_s	(quadrant),quadrant	; load address from jump table
	nop
	jmp	(quadrant)		; jump through table
	sub	y1,y1			; y1 = 0
	nop

;        1         2         3         4         5         6         7         8
;---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
;
; Revision history
; ----------------
; 96/06/24 - rja - updated for new "rts" form
; 96/03/13 - rja - initially coded
