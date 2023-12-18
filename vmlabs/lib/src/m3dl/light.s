/*
 * Title	 	LIGHT.S
 * Desciption		Merlin Lighting Functions
 * Version		1.0
 * Start Date		01/20/1999
 * Last Update		01/20/1999
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	xyzsft	=	16		;XYZ Shift value (16.16)
	tmsft	=	28		;Matrix Shift value (4.28)
	vecsft	=	16		;Vector Shift value (16.16)
	sclsft	=	20		;XScale & YScale Shift value (12.20)


	csp		=	r31		;C Stack Pointer

	IndexBits	=	7
	iPrec		=	29
	sizeofScalar	=	2


	.module LIGHT

	.text


	.include "M3DL/m3dl.i"
	.include "M3DL/mpr.i"

	.import	_MPT_FogNZ, _MPT_FogMulZ
	.import	_RecipLUTData



	.cache
	.nooptimize


;* _mdSetFogNearFar
	.export	_mdSetFogNearFar
;* Input:
;* r0	Fog NearZ value
;* r1   Fog FarZ value

_mdSetFogNearFar:
;* FogMulZ = (FogFarZ*256) / (FogFarZ-FogNearZ)

	sub	r0,r1,r2		;FogFarZ - FogNearZ
	msb	r2,v1[0]		;sigbits
	sub	#IndexBits+1+1,v1[0],v1[1]	;indexshift
	as	v1[1],r2,v1[2]		;LUT offset
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;LUT ptr
	ld_w	(v1[2]),v1[2]		;Retrieve LUT value
	nop
	mul	v1[2],r2,>>v1[0],r2	;answer
	add	#iPrec-vecsft,v1[0] 	;fracbits = sigbits+iPrec-16
	sub	r2,#fix(2,iPrec),r2	;2 - answer
	mul	v1[2],r2,>>#iPrec,r2	;answer
	sub	#8,v1[0]		;256/(FarZ-NearZ)
       {
	mul	r2,r1,>>v1[0],r1	;(FarZ*256)/(FarZ-NearZ)
	rts				;Done
       }
	st_s	r0,(_MPT_FogNZ)		;Store Fog NearZ
	st_s	r1,(_MPT_FogMulZ)	;Store Fog Multiplier
       ;--------------------------------;rts


;* _mdDepthCue
	.export	_mdDepthCue
;* Input:
;* r0	ptr ScrV3 (or even V3)
;* r1   ptr Color

_mdDepthCue:
;* Alpha = [(FogFarZ*256) / (FogFarZ-FogNearZ)] * ((1<<vecsft) - NearZ / Z)

       {
	ld_s	(_MPT_FogNZ),v2[0]	;FogNearZ
	add	#8,r0,r2		;Ptr Z
       }
	ld_s	(r2),r3			;Retrieve Z
	sub	r0,r0			;Clear return value
       {
	mv_s	#IndexBits+1+1,v1[1]	;
	msb	r3,v1[0]		;sigbits
       }
       {
	ld_s	(r1),v2[3]		;Retrieve Color
	subm	v1[1],v1[0],v1[1]	;indexshift
	sub	v2[0],r3,v2[2]		;v2[2] Z - NearZ
       }
       {
	bra	le,`alphaiszero		;Alpha is zero!
	as	v1[1],r3,v1[2]		;LUT offset
       }
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;LUT ptr
	and	#0xFFFFFF00,v2[3]	;Remove Alpha
       ;--------------------------------;bra le,`alphaiszero
	ld_w	(v1[2]),v1[2]		;Retrieve LUT value
	nop
	mul	v1[2],r3,>>v1[0],r3	;answer
	add	#iPrec-vecsft,v1[0] 	;fracbits = sigbits+iPrec-16
	sub	r3,#fix(2,iPrec),r3	;2 - answer
	mul	v1[2],r3,>>#iPrec,r3	;answer
	ld_s	(_MPT_FogMulZ),r0	;FogMulZ
	mul	r3,v2[2],>>v1[0],v2[2]	;v2[2] ((Z - NearZ)/Z)
	nop
	mul	v2[2],r0,>>#vecsft*2,r0 ;Calculate alpha
	nop
`alphaiszero:
       {
	rts				;Done
	sat	#9,r0			;Saturate result
       }
	or	r0,v2[3]		;Insert Alpha
	st_s	v2[3],(r1)		;Store GRBA
       ;--------------------------------;rts


;* _mdDepthCueN
	.export	_mdDepthCue3
	.export	_mdDepthCue4
	.export	_mdDepthCueN
;* Input:
;* r0	ptr ScrV3 (or even V3)
;* r1   ptr Color
;* r2   #of Vertices to DPQ


_mdDepthCueN:
       {
	bra	DepthCueCore		;bra DepthCueCore
	ld_s	(rc0),v1[3]		;Backup rc0
       }
	ld_s	(_MPT_FogNZ),v2[0]	;FogNearZ / FogMulZ / ? / ?
	st_s	r2,(rc0)		;Store Loop Counter
       ;--------------------------------;bra DepthCueCore

_mdDepthCue4:
       {
	bra	DepthCueCore		;bra DepthCueCore
	ld_s	(rc0),v1[3]		;Backup rc0
       }
	ld_s	(_MPT_FogNZ),v2[0]	;FogNearZ / FogMulZ / ? / ?
	st_s	#4,(rc0)		;Store Loop Counter
       ;--------------------------------;bra DepthCueCore

_mdDepthCue3:
	ld_s	(rc0),v1[3]		;Backup rc0
	ld_s	(_MPT_FogNZ),v2[0]	;FogNearZ / FogMulZ / ? / ?
	st_s	#3,(rc0)		;Store Loop Counter

DepthCueCore:
       {
	push	v3			;
	add	#8,r0,r2		;Ptr Z
       }
       {
	ld_s	(r2),v3[0]		;Retrieve Z
	sub	r0,r0			;Clear return value
       }
	add	#3*4,r2			;Next Vector
       {
	mv_s	#IndexBits+1+1,v3[2]	;
	msb	v3[0],v3[1]		;sigbits
       }
       {
	subm	v3[2],v3[1],v3[2]	;indexshift
	sub	v2[0],v3[0],v2[2]  	;v2[2] Z - NearZ
	ld_s	(_MPT_FogMulZ),v2[1]	;Fetch FogMulZ
       }
       {
	bra	le,`alphaiszero		;Alpha is zero!
	as	v3[2],v3[0],v3[2]   	;LUT offset
       }
	add	#_RecipLUTData-(128*sizeofScalar),v3[2]	;LUT ptr
	mv_s	#0,v1[2]		;Clear v1[2]
       ;--------------------------------;bra le,`alphaiszero
	ld_w	(v3[2]),v1[2]		;Retrieve LUT value
	copy	v3[0],r3		;Insert Z
`alphaiszero:
       {
	mul	v1[2],r3,>>v3[1],r3	;answer
	add	#iPrec-vecsft,v3[1],v1[0] 	;fracbits = sigbits+iPrec-16
       }
	sub	v1[1],v1[1]		;Clear Return Value

DPQLp:
       {
	ld_s	(r2),v3[0]		;Retrieve Z
	sub	r3,#fix(2,iPrec),r3	;2 - answer
	addm	v1[1],r0		;Add to Return Value
       }
       {
	add	#3*4,r2			;Next Vector
	mul	v1[2],r3,>>#iPrec,r3	;answer
       }
       {
	mv_s	#IndexBits+1+1,v3[2]	;
	msb	v3[0],v3[1]		;sigbits
       }
       {
	ld_s	(r1),v2[3]		;Retrieve Color
	subm	v3[2],v3[1],v3[2]	;indexshift
	sub	v2[0],v3[0],v3[3]  	;v3[3] Z - NearZ
       }
       {
	bra	le,`alphaiszero		;Alpha is zero!
	as	v3[2],v3[0],v3[2]   	;LUT offset
	mul	r3,v2[2],>>v1[0],v2[2]	;v2[2] ((Z - NearZ)/Z)
       }
       {
	add	#_RecipLUTData-(128*sizeofScalar),v3[2]	;LUT ptr
	mv_s	v2[1],v1[1]		;FogMulZ
       }
       {
	and	#0xFFFFFF00,v2[3]	;Remove Alpha
	mul	v2[2],v1[1],>>#vecsft*2,v1[1] ;Calculate alpha
	mv_s	#0,v1[2]		;Clear v1[2]
       }
       ;--------------------------------;bra le,`alphaiszero
       {
	ld_w	(v3[2]),v1[2]		;Retrieve LUT value
	copy	v3[0],r3		;Insert Z
       }
`alphaiszero:
       {
	dec	rc0			;Decrement Loop Counter
	add	#iPrec-vecsft,v3[1],v1[0] 	;fracbits = sigbits+iPrec-16
       }
       {
	mv_s	v3[3],v2[2]		;v2[2] Z - NearZ
	bra	c0ne,DPQLp		;Loop
	sat	#9,v1[1]		;Saturate result
       }
       {
	mul	v1[2],r3,>>v3[1],r3	;answer
	or	v1[1],v2[3]		;Insert Alpha
       }
       {
	st_s	v2[3],(r1)		;Store GRBA
	add	#4,r1			;Next Color
       }
       ;--------------------------------;bra c0ne,DPQLp
       {
	rts				;Done
	st_s	v1[3],(rc0)		;Restore rc0
       }
	pop	v3			;Restore v3
	add	v1[1],r0		;Add to Return Value
       ;--------------------------------;rts


