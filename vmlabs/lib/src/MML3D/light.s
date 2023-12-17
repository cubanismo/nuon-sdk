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
	; 3D pipeline -- gouraud + specular lighting code
	; Version 1.0 for C
	;
	; local storage required:
	;	standard amount
	; stack required:
	;	12 long words

	;
	; general strategy: at initialization time,
	; the lighting module loads up to 64 bytes
	; worth of lighting data into its local
	; data region. Then, when it is called
	; it can quickly access this data
	;

	; LIGHTING MODEL STRUCTURE
	; byte
	; +0	ambient light intensity (4.28 fraction, 1.0 == maximum)
	; +4	number of external lights (32.0 integer)
	; +8	number of in-scene lights (not used)
	; +12	reserved
	; +16	start of light data; first directional lights, then in-scene
	;		lights
	;
	; External lights look like:
	; 4 words: (x,y,z,a): (all are 4.12 fractions)
	;		intensity is calculated as I = a*(N.(x,y,z,0))
	;

	.module	light_s
	.export	_light_init, _light_end
	.import	light_data

	;
	; initialization code
	;
	.align CODEALIGN
	
_light_init:
{	rts	nop
	add	#light_code - _light_init,r0
}

	
	;****************************************
	; Lighting module
	; Inputs:
	;
	; r0 = pointer to vertex to be lit
	; lighting data was passed in parameter block
	;
	; Outputs:
	; r0 = diffuse intensity of lit vertex
	; r1 = specular intensity of lit vertex
	;
	; Register usage:
	;*****************************************


LdotN		=	r3		; dot product(L,N)

L_litemodel	=	r4		; pointer into lighting model
L_diffuse	=	r5		; diffuse lighting intensity
L_specular	=	r6		; specular lighting intensity
L_one		=	r7		; constant value of 1 in 4.28 format

L_vnorm		=	v2		; vertex normal
L_va		=	r11

L_lnorm		=	v3		; light normal
L_lx		=	r12
L_ly		=	r13
L_lz		=	r14
L_la		=	r15

; v4: some scratch stuff
L_vtemp		=	v4		; temporary vector for calculations


light_code:
{	push	v2
	subm	L_one,L_one,L_one	; clear L_one
	add	#16,r0,r1		; save pointer to vertex into r1, and skip position
}
{	push	v3
	add	#1,L_one		; set L_one to 1.0
}
{	push	v4
	asl	#28,L_one			; now L_one == 1.0 in 4.28 format
}
{	sub	L_specular,L_specular	; set L_specular to 0
	mv_s	#light_data,L_litemodel		; get lighting model
}
{	ld_s	(L_litemodel),L_diffuse		; initialize diffuse intensity to ambient light
	add	#4,L_litemodel
}
{	ld_s	(L_litemodel),r0	; get number of directional lights
	add	#12,L_litemodel		; skip everything else
}
	ld_v	(r1),L_vnorm		; load vertex normal
	cmp	#0,r0			; are there any directional lights?

{	ld_v	(L_litemodel),L_lnorm	; fetch next light vector
	bra	le,enddirltlp		; if there are no directional lights, skip this stuff
}
;*** NEXT TWO INSTRUCTIONS ARE BRANCH DELAY SLOTS
{	add	#16,L_litemodel
}
{	sub	L_va,L_va	; set last element of vertex normal to 0
	st_s	r0,rc0		; set up counter
}

;directional lighting loop

dirltlp:
	dotp	L_lnorm,L_vnorm,>>#30,LdotN	; find dot product
	dec	rc0			; wait for dot product, and count down lights remaining
	copy	LdotN,r0	; save dot product, and test to see if it's negative
{	bra	le,nodirlt,nop
	mul	L_la,r0,>>acshift,r0		; multiply by intensity (a 4.28 number)
}
	mul_sv	LdotN,L_vnorm,>>#30,L_vtemp	; L_vtemp = N(N.L)
	add	r0,L_diffuse			; add intensity product to diffuse intensity

; saturate diffuse intensity
	cmp	L_diffuse,L_one			; is L_one-L_diffuse still positive?
	bra	ge,nosat1			; if so, keep going
	sub_sv	L_vtemp,L_lnorm,L_lnorm	; L_lnorm = L - N(N.L)		; branch delay slot
	sub_sv	L_vtemp,L_lnorm,L_lnorm	; L_lnorm = L - 2N(N.L)		; branch delay slot
		
	mv_s	L_one,L_diffuse

nosat1:
; now calculate specular intensity
; find R.V == (2N(N.L)-L).V), where V=(0,0,-1)

	neg	L_lz			; so if V=(0,0,-1), then L_lz = R.V
{	bra	le,nodirlt,nop
	st_s	#2,rc1		; set up counter for intensity calculation with specular
}

powerlp:
	bra	c1ne,powerlp
	mul	L_lz,L_lz,>>#30,L_lz	; branch delay slot #1: raise (R.V) to an appropriate power
	dec	rc1			; branch delay slot #2

////	asr	#2,L_lz			; convert from 2.30 to 4.28
	add	L_lz,>>#2,L_specular	; update specular intensity

nodirlt:
{	bra	c0ne,dirltlp,nop	; we decremented rc0 at the top of the loop
	ld_v	(L_litemodel),L_lnorm	; get next light vector
	add	#16,L_litemodel
}

enddirltlp:



{	pop	v4
	asl	#2,L_diffuse,r0		; convert to a 2.30 number
}
{	pop	v3
	asl	#2,L_specular,r1
	rts
}
	pop	v2			; branch delay slot #1
	sub	r2,r2

_light_end:
