
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


; recip -- compute reciprocal (high precision)
;
; Copyright 1996 VM Labs, Inc.
;
; Usage ==========================
;
;	r0 <- the fixed-point, positive argument
;	r1 <- number of fraction bits in the argument
;	call recip
;	r0 -> the reciprocal
;	r1 -> number of fraction bits in the reciprocal
;
; Example =========================
;
;	mv_s	rn,r0		; put arg value in input register
;	mv_s	#fracBits,r1	; and pass input fracbits
;	jsr	recip		; call recip
;;
;; The answer is now in r0 (at max precision), and the number of fraction bits
;; in the answer is in r1.
;;
;; To store the answer in rn with a desired number of fraction bits, do the
;; following.
;;
;	sub	#desired_fracBits,r1
;	ls	r1,r0,rn	; move & shift result into another register
;

;
; Interface ========================
;
	.module	recip
	.export	recip

	.import RecipLUT_32
;
; Input parameters
;
x = r0				; the number to "recip"
fracBits = r1			; fracBits of X
;
; Results
;	
answer = r0			; the reciprocal
ansFBits = r1			; fracBits of the reciprocal


;
; Implementation ====================
;
; The algorithm, expressed in a pseudo-code (for a definition of the
; pseudo-code, see "The Icon Programming Language" :-)
;
;   procedure recip(x,fracBits)
;	sigBits := SigBits(x)
;	ansFBits := sigBits - fracBits + iPrec
;	index := ishift(x,-(sigBits - (index_bits + 1))) - 128 + 1
;	y := RecipLUT[index]
;	two := Fix(2,iPrec)
;	y := ishift(y * (two - ishift(x * y,-sigBits)),-iPrec)
;	y := ishift(y * (two - ishift(x * y,-sigBits)),-iPrec)
;	return FixNum(y,ansFBits)
;   end
;
; Working register declarations
;
sigBits = r2				; fracBits in normalized argument
indexShift = r3
lut = r4				; used for divide-LUT lookup
y = r3					; used for iterative result
temp = r4				; temporary work register
two = r5				; holds a constant 2 (3.29)
;
; Some symbolic constants
;
iPrec = 29				; intermediate working precision
indexBits = 7				; nbr of bits used for table lookup
sizeOfScalar = 4


;
; The "recip" code.
;
	.segment text
;	.segment instruction_ram

recip:
;
; hack to prevent recip crashing if it gets a 0

	nop
    cmp #0,x
    rts eq


;
; Normalize the input X -- figure out how many bits to shift.
;
{	mv_s	#RecipLUT_32 - 128 * sizeOfScalar,lut ; start computing LUT ptr
	msb	x,sigBits		; compute sig bits of input x
}
;
; Fetch the first approximation from look-up table (while concurrently
; calculating the fracBits of the result).
;
{	sub	#indexBits + 1 + 2,sigBits,indexShift
					; compute amount to shift index field
	subm	fracBits,sigBits,ansFBits ; begin computing result fracBits
}
{	mv_s	#fix(2,iPrec),two	; load constant 2 in internal precision
	as	indexShift,x,y
}
{	add	y,lut			; compute look-up table pointer
}
{	ld_s	(lut),y			; load first approximation value
	copy	x,temp			; make copy of x
}
{	add	#iPrec,ansFBits		; finish computing result fracBits
}
;
; Perform the first iteration, y *= 2 - x * y.
;
	mul	y,temp,>>sigBits,temp	; temp = x * y
	nop				; (wait for mul result)
	sub	temp,two,temp		; temp = 2 - temp
	mul	temp,y,>>#iPrec,y	; y *= temp
	nop				; (wait for mul result)
;
; Perform the second and final iteration (same computation as first iteration).
;
	mul	y,x,>>sigBits,answer	; answer = x * y
	rts				; return soon
	sub	answer,two,answer	; answer = 2 - answer
	mul	y,answer,>>#iPrec,answer ; answer *= y
					; return now, with mul result not yet
					;   ready

;        1         2         3         4         5         6         7         8
;---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
;
; Revision history
; ----------------
; 96/06/24 - rja - updated for new "rts" form
; 2/23/96	(rja) rewrite for new mul unit definition
; 2/5/96	(rja) accommodate new instruction set, + several small changes
; 12/19/95	(mh) updated for register conventions
