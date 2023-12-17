/*
 * Copyright (C) 1998-2001 VM Labs, Inc.
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
	; FixDiv: do fixed point division
	;
	; Uses the recip function from the
	; assembler utility functions collection
	; to calculate the inverse of the
	; denominator, then multiplies the
	; numerator by this.
	;
	; parameters:
	; r0 == numerator
	; r1 == denominator
	; r2 == fracbits for denominator
	;
	; C API:
	; int FixDiv(int numerator, int denominator, int shift);
	;
	; here "shift" is the number of fractional bits in the
	; denominator. The result has the same number of
	; fractional bits as the numerator.
	;
	; There's also a direct interface to the reciprocal function:
	;
	; long long FixRecip(int num, int fracbits);
	;
	; This finds the reciprocal of "num", which is a positive fixed
	; point number with "fracbits" fractional bits. The reciprocal
	; is returned in the high 32 bits of the result, with the
	; low 32 bits being the fractional bits of the answer.
	;

	.module fixdiv_s
	.text
	.export _FixDiv

	num = v2[0]	; register to hold the numerator
	save_rz = v2[1]
		
_FixDiv:
{	abs	r1		; watch out for negative denominators
	ld_io	rz,save_rz
}
	bra	cc,pos_denom	; branch if denominator positive
	copy	r0,num		; save the numerator (branch delay slot)
{	copy	r1,r0		; copy denominator and fracbits (branch delay slot)
	mv_s	r2,r1		; into the registers where recip wants them
}

	neg	num		; if denominator was negative, negate the
				; numerator
pos_denom:
	abs	num
	bra	cs,neg_numerator,nop
	
	;; here is the code for a positive
	;; numerator
	jsr	recip,nop

	st_io	save_rz,rz
	mul	num,r0,>>r1,r0	; find product of numerator and 1/denominator
	rts	nop
neg_numerator:
	jsr	recip,nop
	st_io	save_rz,rz
	mul	num,r0,>>r1,r0	; find product of numerator and 1/denominator
	rts
	neg	r0		; fix up sign of result
	nop
	

;
; recip -- compute reciprocal (high precision)
;
; Copyright (c) 1996-1997 VM Labs, Inc.
; All rights reserved.
; Confidential and Proprietary Information of
; VM Labs, Inc.
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
spare = r6
	
;
; Some symbolic constants
;
iPrec = 29				; intermediate working precision
indexBits = 7				; nbr of bits used for table lookup
sizeOfScalar = 2


;
; The "recip" code.
;
	.export _FixRecip
_FixRecip:
recip:
;
; Normalize the input X -- figure out how many bits to shift.
;
{	mv_s	#_RecipLUT - 128 * sizeOfScalar,lut ; start computing LUT ptr
	msb	x,sigBits		; compute sig bits of input x
}
;
; Fetch the first approximation from look-up table (while concurrently
; calculating the fracBits of the result).
;
{	sub	#indexBits + 1 + 1,sigBits,indexShift
					; compute amount to shift index field
	subm	fracBits,sigBits,ansFBits ; begin computing result fracBits
}
{	mv_s	#fix(2,iPrec),two	; load constant 2 in internal precision
	as	indexShift,x,y
}
{	add	y,lut			; compute look-up table pointer
}
{	ld_w	(lut),y			; load first approximation value
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
; 2/23/96	(rja) rewrite for new mul unit definition
; 2/5/96	(rja) accommodate new instruction set, + several small changes
; 12/19/95	(mh) updated for register conventions


;
; Look-up table for reciprocal
;
;    indexes:  0 through 127
;    values:   0.5 through 1
;    fracBits: 29 (8 stored)
;    centered: yes
;
	.data
_RecipLUT:
	.dc.w	$3fc0 ; 0. fix(1.992,29) <- recip(0.501953125) =
;	001.1 1111 1100 0000 0000 0000 0000 0000
	.dc.w	$3f40 ; 1. fix(1.977,29) <- recip(0.505859375) =
;	001.1 1111 0100 0000 0000 0000 0000 0000
	.dc.w	$3ec0 ; 2. fix(1.961,29) <- recip(0.509765625) =
;	001.1 1110 1100 0000 0000 0000 0000 0000
	.dc.w	$3e40 ; 3. fix(1.945,29) <- recip(0.513671875) =
;	001.1 1110 0100 0000 0000 0000 0000 0000
	.dc.w	$3de0 ; 4. fix(1.934,29) <- recip(0.517578125) =
;	001.1 1101 1110 0000 0000 0000 0000 0000
	.dc.w	$3d60 ; 5. fix(1.918,29) <- recip(0.521484375) =
;	001.1 1101 0110 0000 0000 0000 0000 0000
	.dc.w	$3ce0 ; 6. fix(1.902,29) <- recip(0.525390625) =
;	001.1 1100 1110 0000 0000 0000 0000 0000
	.dc.w	$3c80 ; 7. fix(1.891,29) <- recip(0.529296875) =
;	001.1 1100 1000 0000 0000 0000 0000 0000
	.dc.w	$3c00 ; 8. fix(1.875,29) <- recip(0.533203125) =
;	001.1 1100 0000 0000 0000 0000 0000 0000
	.dc.w	$3ba0 ; 9. fix(1.863,29) <- recip(0.537109375) =
;	001.1 1011 1010 0000 0000 0000 0000 0000
	.dc.w	$3b20 ; 10. fix(1.848,29) <- recip(0.541015625) =
;	001.1 1011 0010 0000 0000 0000 0000 0000
	.dc.w	$3ac0 ; 11. fix(1.836,29) <- recip(0.544921875) =
;	001.1 1010 1100 0000 0000 0000 0000 0000
	.dc.w	$3a40 ; 12. fix(1.820,29) <- recip(0.548828125) =
;	001.1 1010 0100 0000 0000 0000 0000 0000
	.dc.w	$39e0 ; 13. fix(1.809,29) <- recip(0.552734375) =
;	001.1 1001 1110 0000 0000 0000 0000 0000
	.dc.w	$3980 ; 14. fix(1.797,29) <- recip(0.556640625) =
;	001.1 1001 1000 0000 0000 0000 0000 0000
	.dc.w	$3920 ; 15. fix(1.785,29) <- recip(0.560546875) =
;	001.1 1001 0010 0000 0000 0000 0000 0000
	.dc.w	$38c0 ; 16. fix(1.773,29) <- recip(0.564453125) =
;	001.1 1000 1100 0000 0000 0000 0000 0000
	.dc.w	$3840 ; 17. fix(1.758,29) <- recip(0.568359375) =
;	001.1 1000 0100 0000 0000 0000 0000 0000
	.dc.w	$37e0 ; 18. fix(1.746,29) <- recip(0.572265625) =
;	001.1 0111 1110 0000 0000 0000 0000 0000
	.dc.w	$3780 ; 19. fix(1.734,29) <- recip(0.576171875) =
;	001.1 0111 1000 0000 0000 0000 0000 0000
	.dc.w	$3720 ; 20. fix(1.723,29) <- recip(0.580078125) =
;	001.1 0111 0010 0000 0000 0000 0000 0000
	.dc.w	$36c0 ; 21. fix(1.711,29) <- recip(0.583984375) =
;	001.1 0110 1100 0000 0000 0000 0000 0000
	.dc.w	$3660 ; 22. fix(1.699,29) <- recip(0.587890625) =
;	001.1 0110 0110 0000 0000 0000 0000 0000
	.dc.w	$3620 ; 23. fix(1.691,29) <- recip(0.591796875) =
;	001.1 0110 0010 0000 0000 0000 0000 0000
	.dc.w	$35c0 ; 24. fix(1.680,29) <- recip(0.595703125) =
;	001.1 0101 1100 0000 0000 0000 0000 0000
	.dc.w	$3560 ; 25. fix(1.668,29) <- recip(0.599609375) =
;	001.1 0101 0110 0000 0000 0000 0000 0000
	.dc.w	$3500 ; 26. fix(1.656,29) <- recip(0.603515625) =
;	001.1 0101 0000 0000 0000 0000 0000 0000
	.dc.w	$34a0 ; 27. fix(1.645,29) <- recip(0.607421875) =
;	001.1 0100 1010 0000 0000 0000 0000 0000
	.dc.w	$3460 ; 28. fix(1.637,29) <- recip(0.611328125) =
;	001.1 0100 0110 0000 0000 0000 0000 0000
	.dc.w	$3400 ; 29. fix(1.625,29) <- recip(0.615234375) =
;	001.1 0100 0000 0000 0000 0000 0000 0000
	.dc.w	$33a0 ; 30. fix(1.613,29) <- recip(0.619140625) =
;	001.1 0011 1010 0000 0000 0000 0000 0000
	.dc.w	$3360 ; 31. fix(1.605,29) <- recip(0.623046875) =
;	001.1 0011 0110 0000 0000 0000 0000 0000
	.dc.w	$3300 ; 32. fix(1.594,29) <- recip(0.626953125) =
;	001.1 0011 0000 0000 0000 0000 0000 0000
	.dc.w	$32c0 ; 33. fix(1.586,29) <- recip(0.630859375) =
;	001.1 0010 1100 0000 0000 0000 0000 0000
	.dc.w	$3260 ; 34. fix(1.574,29) <- recip(0.634765625) =
;	001.1 0010 0110 0000 0000 0000 0000 0000
	.dc.w	$3220 ; 35. fix(1.566,29) <- recip(0.638671875) =
;	001.1 0010 0010 0000 0000 0000 0000 0000
	.dc.w	$31c0 ; 36. fix(1.555,29) <- recip(0.642578125) =
;	001.1 0001 1100 0000 0000 0000 0000 0000
	.dc.w	$3180 ; 37. fix(1.547,29) <- recip(0.646484375) =
;	001.1 0001 1000 0000 0000 0000 0000 0000
	.dc.w	$3140 ; 38. fix(1.539,29) <- recip(0.650390625) =
;	001.1 0001 0100 0000 0000 0000 0000 0000
	.dc.w	$30e0 ; 39. fix(1.527,29) <- recip(0.654296875) =
;	001.1 0000 1110 0000 0000 0000 0000 0000
	.dc.w	$30a0 ; 40. fix(1.520,29) <- recip(0.658203125) =
;	001.1 0000 1010 0000 0000 0000 0000 0000
	.dc.w	$3060 ; 41. fix(1.512,29) <- recip(0.662109375) =
;	001.1 0000 0110 0000 0000 0000 0000 0000
	.dc.w	$3000 ; 42. fix(1.500,29) <- recip(0.666015625) =
;	001.1 0000 0000 0000 0000 0000 0000 0000
	.dc.w	$2fc0 ; 43. fix(1.492,29) <- recip(0.669921875) =
;	001.0 1111 1100 0000 0000 0000 0000 0000
	.dc.w	$2f80 ; 44. fix(1.484,29) <- recip(0.673828125) =
;	001.0 1111 1000 0000 0000 0000 0000 0000
	.dc.w	$2f40 ; 45. fix(1.477,29) <- recip(0.677734375) =
;	001.0 1111 0100 0000 0000 0000 0000 0000
	.dc.w	$2f00 ; 46. fix(1.469,29) <- recip(0.681640625) =
;	001.0 1111 0000 0000 0000 0000 0000 0000
	.dc.w	$2ea0 ; 47. fix(1.457,29) <- recip(0.685546875) =
;	001.0 1110 1010 0000 0000 0000 0000 0000
	.dc.w	$2e60 ; 48. fix(1.449,29) <- recip(0.689453125) =
;	001.0 1110 0110 0000 0000 0000 0000 0000
	.dc.w	$2e20 ; 49. fix(1.441,29) <- recip(0.693359375) =
;	001.0 1110 0010 0000 0000 0000 0000 0000
	.dc.w	$2de0 ; 50. fix(1.434,29) <- recip(0.697265625) =
;	001.0 1101 1110 0000 0000 0000 0000 0000
	.dc.w	$2da0 ; 51. fix(1.426,29) <- recip(0.701171875) =
;	001.0 1101 1010 0000 0000 0000 0000 0000
	.dc.w	$2d60 ; 52. fix(1.418,29) <- recip(0.705078125) =
;	001.0 1101 0110 0000 0000 0000 0000 0000
	.dc.w	$2d20 ; 53. fix(1.410,29) <- recip(0.708984375) =
;	001.0 1101 0010 0000 0000 0000 0000 0000
	.dc.w	$2ce0 ; 54. fix(1.402,29) <- recip(0.712890625) =
;	001.0 1100 1110 0000 0000 0000 0000 0000
	.dc.w	$2ca0 ; 55. fix(1.395,29) <- recip(0.716796875) =
;	001.0 1100 1010 0000 0000 0000 0000 0000
	.dc.w	$2c60 ; 56. fix(1.387,29) <- recip(0.720703125) =
;	001.0 1100 0110 0000 0000 0000 0000 0000
	.dc.w	$2c20 ; 57. fix(1.379,29) <- recip(0.724609375) =
;	001.0 1100 0010 0000 0000 0000 0000 0000
	.dc.w	$2be0 ; 58. fix(1.371,29) <- recip(0.728515625) =
;	001.0 1011 1110 0000 0000 0000 0000 0000
	.dc.w	$2bc0 ; 59. fix(1.367,29) <- recip(0.732421875) =
;	001.0 1011 1100 0000 0000 0000 0000 0000
	.dc.w	$2b80 ; 60. fix(1.359,29) <- recip(0.736328125) =
;	001.0 1011 1000 0000 0000 0000 0000 0000
	.dc.w	$2b40 ; 61. fix(1.352,29) <- recip(0.740234375) =
;	001.0 1011 0100 0000 0000 0000 0000 0000
	.dc.w	$2b00 ; 62. fix(1.344,29) <- recip(0.744140625) =
;	001.0 1011 0000 0000 0000 0000 0000 0000
	.dc.w	$2ac0 ; 63. fix(1.336,29) <- recip(0.748046875) =
;	001.0 1010 1100 0000 0000 0000 0000 0000
	.dc.w	$2a80 ; 64. fix(1.328,29) <- recip(0.751953125) =
;	001.0 1010 1000 0000 0000 0000 0000 0000
	.dc.w	$2a60 ; 65. fix(1.324,29) <- recip(0.755859375) =
;	001.0 1010 0110 0000 0000 0000 0000 0000
	.dc.w	$2a20 ; 66. fix(1.316,29) <- recip(0.759765625) =
;	001.0 1010 0010 0000 0000 0000 0000 0000
	.dc.w	$29e0 ; 67. fix(1.309,29) <- recip(0.763671875) =
;	001.0 1001 1110 0000 0000 0000 0000 0000
	.dc.w	$29c0 ; 68. fix(1.305,29) <- recip(0.767578125) =
;	001.0 1001 1100 0000 0000 0000 0000 0000
	.dc.w	$2980 ; 69. fix(1.297,29) <- recip(0.771484375) =
;	001.0 1001 1000 0000 0000 0000 0000 0000
	.dc.w	$2940 ; 70. fix(1.289,29) <- recip(0.775390625) =
;	001.0 1001 0100 0000 0000 0000 0000 0000
	.dc.w	$2920 ; 71. fix(1.285,29) <- recip(0.779296875) =
;	001.0 1001 0010 0000 0000 0000 0000 0000
	.dc.w	$28e0 ; 72. fix(1.277,29) <- recip(0.783203125) =
;	001.0 1000 1110 0000 0000 0000 0000 0000
	.dc.w	$28a0 ; 73. fix(1.270,29) <- recip(0.787109375) =
;	001.0 1000 1010 0000 0000 0000 0000 0000
	.dc.w	$2880 ; 74. fix(1.266,29) <- recip(0.791015625) =
;	001.0 1000 1000 0000 0000 0000 0000 0000
	.dc.w	$2840 ; 75. fix(1.258,29) <- recip(0.794921875) =
;	001.0 1000 0100 0000 0000 0000 0000 0000
	.dc.w	$2800 ; 76. fix(1.250,29) <- recip(0.798828125) =
;	001.0 1000 0000 0000 0000 0000 0000 0000
	.dc.w	$27e0 ; 77. fix(1.246,29) <- recip(0.802734375) =
;	001.0 0111 1110 0000 0000 0000 0000 0000
	.dc.w	$27a0 ; 78. fix(1.238,29) <- recip(0.806640625) =
;	001.0 0111 1010 0000 0000 0000 0000 0000
	.dc.w	$2780 ; 79. fix(1.234,29) <- recip(0.810546875) =
;	001.0 0111 1000 0000 0000 0000 0000 0000
	.dc.w	$2740 ; 80. fix(1.227,29) <- recip(0.814453125) =
;	001.0 0111 0100 0000 0000 0000 0000 0000
	.dc.w	$2720 ; 81. fix(1.223,29) <- recip(0.818359375) =
;	001.0 0111 0010 0000 0000 0000 0000 0000
	.dc.w	$26e0 ; 82. fix(1.215,29) <- recip(0.822265625) =
;	001.0 0110 1110 0000 0000 0000 0000 0000
	.dc.w	$26c0 ; 83. fix(1.211,29) <- recip(0.826171875) =
;	001.0 0110 1100 0000 0000 0000 0000 0000
	.dc.w	$2680 ; 84. fix(1.203,29) <- recip(0.830078125) =
;	001.0 0110 1000 0000 0000 0000 0000 0000
	.dc.w	$2660 ; 85. fix(1.199,29) <- recip(0.833984375) =
;	001.0 0110 0110 0000 0000 0000 0000 0000
	.dc.w	$2640 ; 86. fix(1.195,29) <- recip(0.837890625) =
;	001.0 0110 0100 0000 0000 0000 0000 0000
	.dc.w	$2600 ; 87. fix(1.188,29) <- recip(0.841796875) =
;	001.0 0110 0000 0000 0000 0000 0000 0000
	.dc.w	$25e0 ; 88. fix(1.184,29) <- recip(0.845703125) =
;	001.0 0101 1110 0000 0000 0000 0000 0000
	.dc.w	$25a0 ; 89. fix(1.176,29) <- recip(0.849609375) =
;	001.0 0101 1010 0000 0000 0000 0000 0000
	.dc.w	$2580 ; 90. fix(1.172,29) <- recip(0.853515625) =
;	001.0 0101 1000 0000 0000 0000 0000 0000
	.dc.w	$2560 ; 91. fix(1.168,29) <- recip(0.857421875) =
;	001.0 0101 0110 0000 0000 0000 0000 0000
	.dc.w	$2520 ; 92. fix(1.160,29) <- recip(0.861328125) =
;	001.0 0101 0010 0000 0000 0000 0000 0000
	.dc.w	$2500 ; 93. fix(1.156,29) <- recip(0.865234375) =
;	001.0 0101 0000 0000 0000 0000 0000 0000
	.dc.w	$24e0 ; 94. fix(1.152,29) <- recip(0.869140625) =
;	001.0 0100 1110 0000 0000 0000 0000 0000
	.dc.w	$24a0 ; 95. fix(1.145,29) <- recip(0.873046875) =
;	001.0 0100 1010 0000 0000 0000 0000 0000
	.dc.w	$2480 ; 96. fix(1.141,29) <- recip(0.876953125) =
;	001.0 0100 1000 0000 0000 0000 0000 0000
	.dc.w	$2460 ; 97. fix(1.137,29) <- recip(0.880859375) =
;	001.0 0100 0110 0000 0000 0000 0000 0000
	.dc.w	$2420 ; 98. fix(1.129,29) <- recip(0.884765625) =
;	001.0 0100 0010 0000 0000 0000 0000 0000
	.dc.w	$2400 ; 99. fix(1.125,29) <- recip(0.888671875) =
;	001.0 0100 0000 0000 0000 0000 0000 0000
	.dc.w	$23e0 ; 100. fix(1.121,29) <- recip(0.892578125) =
;	001.0 0011 1110 0000 0000 0000 0000 0000
	.dc.w	$23c0 ; 101. fix(1.117,29) <- recip(0.896484375) =
;	001.0 0011 1100 0000 0000 0000 0000 0000
	.dc.w	$2380 ; 102. fix(1.109,29) <- recip(0.900390625) =
;	001.0 0011 1000 0000 0000 0000 0000 0000
	.dc.w	$2360 ; 103. fix(1.105,29) <- recip(0.904296875) =
;	001.0 0011 0110 0000 0000 0000 0000 0000
	.dc.w	$2340 ; 104. fix(1.102,29) <- recip(0.908203125) =
;	001.0 0011 0100 0000 0000 0000 0000 0000
	.dc.w	$2320 ; 105. fix(1.098,29) <- recip(0.912109375) =
;	001.0 0011 0010 0000 0000 0000 0000 0000
	.dc.w	$22e0 ; 106. fix(1.090,29) <- recip(0.916015625) =
;	001.0 0010 1110 0000 0000 0000 0000 0000
	.dc.w	$22c0 ; 107. fix(1.086,29) <- recip(0.919921875) =
;	001.0 0010 1100 0000 0000 0000 0000 0000
	.dc.w	$22a0 ; 108. fix(1.082,29) <- recip(0.923828125) =
;	001.0 0010 1010 0000 0000 0000 0000 0000
	.dc.w	$2280 ; 109. fix(1.078,29) <- recip(0.927734375) =
;	001.0 0010 1000 0000 0000 0000 0000 0000
	.dc.w	$2260 ; 110. fix(1.074,29) <- recip(0.931640625) =
;	001.0 0010 0110 0000 0000 0000 0000 0000
	.dc.w	$2240 ; 111. fix(1.070,29) <- recip(0.935546875) =
;	001.0 0010 0100 0000 0000 0000 0000 0000
	.dc.w	$2200 ; 112. fix(1.063,29) <- recip(0.939453125) =
;	001.0 0010 0000 0000 0000 0000 0000 0000
	.dc.w	$21e0 ; 113. fix(1.059,29) <- recip(0.943359375) =
;	001.0 0001 1110 0000 0000 0000 0000 0000
	.dc.w	$21c0 ; 114. fix(1.055,29) <- recip(0.947265625) =
;	001.0 0001 1100 0000 0000 0000 0000 0000
	.dc.w	$21a0 ; 115. fix(1.051,29) <- recip(0.951171875) =
;	001.0 0001 1010 0000 0000 0000 0000 0000
	.dc.w	$2180 ; 116. fix(1.047,29) <- recip(0.955078125) =
;	001.0 0001 1000 0000 0000 0000 0000 0000
	.dc.w	$2160 ; 117. fix(1.043,29) <- recip(0.958984375) =
;	001.0 0001 0110 0000 0000 0000 0000 0000
	.dc.w	$2140 ; 118. fix(1.039,29) <- recip(0.962890625) =
;	001.0 0001 0100 0000 0000 0000 0000 0000
	.dc.w	$2120 ; 119. fix(1.035,29) <- recip(0.966796875) =
;	001.0 0001 0010 0000 0000 0000 0000 0000
	.dc.w	$2100 ; 120. fix(1.031,29) <- recip(0.970703125) =
;	001.0 0001 0000 0000 0000 0000 0000 0000
	.dc.w	$20e0 ; 121. fix(1.027,29) <- recip(0.974609375) =
;	001.0 0000 1110 0000 0000 0000 0000 0000
	.dc.w	$20c0 ; 122. fix(1.023,29) <- recip(0.978515625) =
;	001.0 0000 1100 0000 0000 0000 0000 0000
	.dc.w	$20a0 ; 123. fix(1.020,29) <- recip(0.982421875) =
;	001.0 0000 1010 0000 0000 0000 0000 0000
	.dc.w	$2080 ; 124. fix(1.016,29) <- recip(0.986328125) =
;	001.0 0000 1000 0000 0000 0000 0000 0000
	.dc.w	$2060 ; 125. fix(1.012,29) <- recip(0.990234375) =
;	001.0 0000 0110 0000 0000 0000 0000 0000
	.dc.w	$2040 ; 126. fix(1.008,29) <- recip(0.994140625) =
;	001.0 0000 0100 0000 0000 0000 0000 0000
	.dc.w	$2020 ; 127. fix(1.004,29) <- recip(0.998046875) =
;	001.0 0000 0010 0000 0000 0000 0000 0000
	