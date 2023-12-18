/*
 * Title	 	MDMATH.S
 * Desciption		Merlin Math functions
 * Version		1.0
 * Start Date		08/15/1998
 * Last Update		08/15/1999
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	tmsft	=	28		;Matrix Shift value (4.28)
	qtsft	=	24		;Quaternion Shift value (8.24)
	vecsft	=	16		;Vector Shift value (16.16)

	IndexBits	=	7	;#of Index Bits Recip Table MPE0
	iPrec		=	29	;
	sizeofScalar	=	2	;

	csp	=	r31		;C Stack Pointer

	.module MATH

	.import	_RecipLUTData

	.text


	.cache
	.nooptimize

	.import	RSqrtLUT

CNFOSIZE	=	(((3*4)+4)*4)



;* _mdFastArctan2
	.export	_mdFastArctan2
;* Input:
;* r0 dy
;* r1 dx
;* Output:
;* r0 angle (1<<16) is 360 degrees

_mdFastArctan2:
       {
	subm	r3,r3			;clear dx sign
	mv_s	r0,r2			;dy
	abs	r1			;Absolute dx
       }
       {
	addwc	r3,r3			;dx sign
	mv_s	#0,r4			;clear dy sign
       }
	abs	r2			;Absolute dy
	addwc	r4,r4			;dy sign
	eor	r3,r4,r0		;dx eor dy
       {
	bra	eq,`noquadrantswapdxdy
	eor	r0,r3			;dx eor (dx eor dy)
       }
	or	r3,>>#-1,r0		;r0 Quadrant#
	add	r0,r0			;shift Quadrant# up
       ;--------------------------------;bra eq,`noquadrantswapdxdy
       {
	mv_s	r1,r2			;swap
	copy	r2,r1                   ;dx,dy
       }
`noquadrantswapdxdy:
	sub	r2,r1,r5		;abs(dy)-abs(dx)
       {
	abs	r5			;abs (abs(y) - abs(x))
	mv_s	#0,r3			;clear r3
       }
       {
	bra	cc,`nooddoctantswapdxdy
	addwc	r3,r0			;insert flag x < y
       }
       {
	mv_s	#1,r3			;one
	lsl	#vecsft-3,r0		;shift quadrant up (16.16)
       }
	lsl	#vecsft-3,r3		;shift one up (16.16)
       ;--------------------------------;`nooddoctantswapdxdy
       {
	mv_s	r2,r1			;dy denominator
	sub	r1,#0,r2		;-dx nominator
	addm	r3,r0			;Increment #of octants
       }
`nooddoctantswapdxdy:
	;now calculate r2/r1		;divide r2 by r1
       {
	mv_s	r2,r3			;EC: r3 dy
	msb	r1,v1[0]		;sigbits
       }
       {
	mul	r3,r3,>>#vecsft-1,r3	;EC: 2*dy*dy
	sub	#IndexBits+1+1,v1[0],v1[1]	;indexshift
       }
       {
	as	v1[1],r1,v1[2]		;LUT offset
	mv_s	#1<<vecsft,v2[0]	;EC: v2[0] one
       }
       {
	rts	eq,nop			;Bail out if r1 is zero
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;LUT ptr
	subm	r3,v2[0]		;EC: 1-2*dy*dy
       }
	ld_w	(v1[2]),v1[2]		;Retrieve LUT value
	mul	r2,v2[0],>>#(vecsft),v2[0];EC: dy(1-2*dy*dy)
	mul	v1[2],r1,>>v1[0],r1	;answer
       {
	mv_s	#0x270<<5,v2[1]		;EC: Max error term
	add	#iPrec-(vecsft-3),v1[0];fracbits = sigbits+iPrec-16
       }
       {
	sub	r1,#fix(2,iPrec),r1	;2 - answer
	mul	v2[1],v2[0],>>#vecsft,v2[0] ;EC: MAXERR*(4*dy*(1-2*dy*dy))
       }
	mul	v1[2],r1,>>#iPrec,r1	;answer
	add	v2[0],r2		;EC: Correct r2
       {
	rts				;Done
	mul	r1,r2,>>v1[0],r2	;r2/r1
       }
	nop
	add	r2,r0			;Angle in rotations
       ;--------------------------------;rts


;* _mdGetPosCurve3D
	.export	_mdGetPosCurve3D
;* Input:
;* r0 mdBYTE*  splinedata
;* r1 md2DOT30 param
;* r2 mdV3*    position

_mdGetPosCurve3D:
       {
	mv_s	#16,v1[3]		;v1[3] cte 16
	add	#12,r0,v1[0]		;Ptr Curve SFT
       }
       {
	ld_s	(v1[0]),v1[0]		;Read Curve Control Point shift value
					;Remember it is stored negative!
	abs	r1			;Absolute param
	addm	v1[3],r0		;Ptr Knots
       }
       {
	bits	#30-1,>>#0,r1		;Isolate Lower Bits
	subm	v1[3],csp,v2[3]  	;1 Vector on Stack
       }
       {
	ls	v1[0],r1,v2[0]		;param
       }
       {
	bits	#30-1,>>#0,v2[0]	;Isolate Lower bits
	mv_s	#30,v1[1]		;v1[2] cte 1
       }
       {
	addm	v1[0],v1[1]		;30-sft control point
	mv_s	v2[0],v2[2]		;param
	cmp	#1<<30,r1		;is One ?
       }
       {
	bra	eq,C3DPosOne		;Yap, do special
	ls	v1[1],r1	   	;r1 Index Active control point
	mul	v2[0],v2[2],>>#30,v2[2]	;param*param
	mv_s	#CNFOSIZE,v1[3]     	;Offset
       }
       {
	mul	v1[3],r1,>>#0,r1	;Offset in cp array
	mv_s	#1,v1[2]		;v1[2] cte 1
	and	#-16,v2[3]		;Align Stack
       }
       {
	st_v	v3,(v2[3]) 		;Backup v3
	ls	v1[0],v1[2]		;#of Control Points
       }
       ;--------------------------------;bra eq,C3Done
       {
	mv_s	v2[2],v2[1]		;param^2
	mul	v2[0],v2[2],>>#30,v2[2]	;param^3
	add	r1,r0 			;Ptr Active control point
       }
       {
	ld_v	(r0),v1			;Read cx
	add	#16,r0			;Increment ptr
       }
       {
	ld_v	(r0),v3			;Read cy
	add	#16,r0			;Increment ptr
       }
       {
	mul	v2[0],v1[1],>>#30,v1[1]	;c1x*param
	add	#4,r2,r1		;ptr vy
       }
	mul	v2[1],v1[2],>>#30,v1[2]	;c2x*param^2
       {
	mul	v2[2],v1[3],>>#30,v1[3]	;c2x*param^2
	add	v1[1],v1[0]		;c0x+c1x*p
       }
       {
	mul	v2[0],v3[1],>>#30,v3[1]	;c1y*param
	add	v1[2],v1[0]		;c0x+c1x*p+c2x*p^2
       }
       {
	mul	v2[1],v3[2],>>#30,v3[2]	;c2y*param^2
	add	v1[3],v1[0],r3		;c0x+c1x*p+c2x*p^2+c3x*p^3
	ld_v	(r0),v1			;read cz
       }
       {
	mul	v2[2],v3[3],>>#30,v3[3]	;c2y*param^2
	add	v3[1],v3[0]		;c0y+c1y*p
       }
       {
	st_s	r3,(r2)			;Store vx
	mul	v2[0],v1[1],>>#30,v1[1]	;c1z*param
	add	v3[2],v3[0]		;c0y+c1y*p+c2y*p^2
       }
       {
	mul	v2[1],v1[2],>>#30,v1[2]	;c2z*param^2
	add	v3[3],v3[0]		;c0y+c1y*p+c2y*p^2+c3y*p^3
       }
       {
	st_s	v3[0],(r1)		;Store vy
	mul	v2[2],v1[3],>>#30,v1[3]	;c2z*param^2
	add	v1[1],v1[0]		;c0z+c1z*p
       }
       {
	rts
	add	v1[2],v1[0]		;c0z+c1z*p+c2z*p^2
	ld_v	(v2[3]),v3		;Restore v3
       }
       {
	addm	v1[3],v1[0]		;c0z+c1z*p+c2z*p^2+c3z*p^3
	add	#4,r1			;Ptr vz
       }
	st_s	v1[0],(r1)		;Store vz
       ;--------------------------------;rts

C3DPosOne:
	sub	#1,v1[2]		;#of Control Points-1
	mul	v1[3],v1[2],>>#0,v1[2]	;Offset in cp array
	add	#(3*4)*4,r0		;Skip Polynomial Coefficients
	add	v1[2],r0		;Ptr Last Knot
	ld_v	(r0),v2			;Read last p
	nop				;Load Delay slot
       {
	rts				;Done
	st_s	v2[0],(r2)		;store vx
	add	#4,r2			;Increase ptr
       }
       {
	st_s	v2[1],(r2)		;store vy
	add	#4,r2			;Increase ptr
       }
       {
	st_s	v2[2],(r2)		;store vz
       }
       ;--------------------------------;rts


;* _mdGetPosTangentCurve3D
	.export	_mdGetPosTangentCurve3D
;* Input:
;* r0 mdBYTE*  splinedata
;* r1 md2DOT30 param
;* r2 mdV3*    position
;* r3 mdV3*    tangent

_mdGetPosTangentCurve3D:
       {
	mv_s	#16,v1[3]		;v1[3] cte 16
	add	#12,r0,v1[0]		;Ptr Curve SFT
       }
       {
	ld_s	(v1[0]),v1[0]		;Read Curve Control Point shift value
					;Remember it is stored negative!
	abs	r1			;Absolute param
	addm	v1[3],r0		;Ptr Knots
       }
       {
	bits	#30-1,>>#0,r1		;Isolate Lower Bits
	subm	v1[3],csp,v2[3] 	;1 Vector on Stack
       }
       {
	ls	v1[0],r1,v2[0]		;param
       }
       {
	bits	#30-1,>>#0,v2[0]	;Isolate Lower bits
	mv_s	#30,v1[1]		;v1[2] cte 1
       }
       {
	addm	v1[0],v1[1]		;30-sft control point
	mv_s	v2[0],v2[2]		;param
	cmp	#1<<30,r1		;is One ?
       }
       {
	bra	eq,C3DPosTangentOne 	;Yap, do special
	ls	v1[1],r1	   	;r1 Index Active control point
	mul	v2[0],v2[2],>>#30,v2[2]	;param*param
	mv_s	#CNFOSIZE,v1[3]    	;Offset
       }
       {
	mul	v1[3],r1,>>#0,r1	;Offset in cp array
	mv_s	#1,v1[2]		;v1[2] cte 1
	and	#-16,v2[3]		;Align Stack
       }
       {
	st_v	v3,(v2[3]) 		;Backup v3
	ls	v1[0],v1[2]		;#of Control Points
       }
       ;--------------------------------;bra eq,C3Done
       {
	mv_s	v2[2],v2[1]		;param^2
	mul	v2[0],v2[2],>>#30,v2[2]	;param^3
	add	r1,r0 			;Ptr Active control point
       }
       {
	ld_v	(r0),v1			;Read cx
	add	#16,r0			;Increment ptr
       }
       {
	ld_v	(r0),v3			;Read cy
	add	#16,r0			;Increment ptr
       }
	mul	v2[0],v1[1],>>#30,v1[1]	;c1x*param
	mul	v2[1],v1[2],>>#30,v1[2]	;c2x*param^2
       {
	mul	v2[2],v1[3],>>#30,v1[3]	;c2x*param^3
	add	v1[1],v1[0]		;c0x+c1x*p
       }
       {
	mul	v2[0],v3[1],>>#30,v3[1]	;c1y*param
	add	v1[2],v1[0]		;c0x+c1x*p+c2x*p^2
       }
       {
	mul	v2[1],v3[2],>>#30,v3[2]	;c2y*param^2
	add	v1[3],v1[0],r1		;c0x+c1x*p+c2x*p^2+c3x*p^3
	ld_v	(r0),v1			;read cz
       }
       {
	mul	v2[2],v3[3],>>#30,v3[3]	;c2y*param^3
	add	v3[1],v3[0]		;c0y+c1y*p
       }
       {
	st_s	r1,(r2)			;Store vx
	mul	v2[0],v1[1],>>#30,v1[1]	;c1z*param
	add	v3[2],v3[0]		;c0y+c1y*p+c2y*p^2
       }
       {
	mul	#2,v2[0],>>#2,v2[0]	;2*param
	sub	#32,r0			;ptr cx
       }
       {
	mul	v2[1],v1[2],>>#30,v1[2]	;c2z*param^2
	add	v3[3],v3[0],r1		;c0y+c1y*p+c2y*p^2+c3y*p^3
	ld_v	(r0),v3			;read cx
       }
       {
	mul	v2[2],v1[3],>>#30,v1[3]	;c2z*param^3
	add	#4,r2
       }
       {
	st_s	r1,(r2)			;Store vy
	add	v1[1],v1[0]		;c0z+c1z*p
       }
       {
	add	#16,r0			;ptr cy
	addm	v1[3],v1[2]		;c2z*param^3+c1z*param^2
       }
       {
	ld_v	(r0),v1			;read cy
	add	v1[2],v1[0],r1		;c0z+c1z*p+c2z*p^2+c3z*p^3
	mul	#3,v2[1],>>#2,v2[1]	;3*param^2
       }
       {
	add	#4,r2			;Ptr vz
	mul     v2[0],v3[2],>>#30-2,v3[2]	;2*c2x*p
       }
       {
	st_s	r1,(r2)			;Store vz
	add	#16,r0			;ptr cz
	mul     v2[1],v3[3],>>#30-2,v3[3]	;3*c3x*p^2
       }
       {
	mv_s	r3,v1[0]			;Backup ptr tangent
	mul	v2[0],v1[2],>>#30-2,v1[2]	;2*c2y*p
	add	v3[2],v3[1]			;c1x+2*c2x*p
       }
       {
	mul     v2[1],v1[3],>>#30-2,v1[3]	;3*c3x*p^2
	add	v3[3],v3[1],v2[2]		;c1x+2*c2x*p+3*c2x*p^2
	ld_v	(r0),v0				;read cz
       }
	add	v1[2],v1[1]			;c1y+2*c2y*p
       {
	st_s	v2[2],(v1[0])			;store tx
	mul	v0[2],v2[0],>>#30-2,v2[0]	;2*c2z*p
	add	#4,v1[0]			;ptr ty
       }
       {
	ld_v	(v2[3]),v3		;Restore v3
	mul	v0[3],v2[1],>>#30-2,v2[1]	;3*c2z*p^2
	add	v1[3],v1[1]			;c1x+2*c2x*p+3*c2x*p^2
       }
       {
	rts
	add	v0[1],v2[0]			;c1z+2*c2z*p
       }
       {
	addm	v2[1],v2[0]			;c1z+2*c2z*p+3*c3z*p^2
	st_s	v1[1],(v1[0]) 			;store ty
	add	#4,v1[0]			;ptr ty
       }
	st_s	v2[0],(v1[0])			;store tz
       ;--------------------------------;rts


C3DPosTangentOne:
	sub	#1,v1[2]		;#of Control Points-1
	mul	v1[3],v1[2],>>#0,v1[2]	;Offset in cp array
	mv_s	#4,r1			;cte 4
	add	v1[2],r0		;Ptr Last Knot
       {
	ld_v	(r0),v1			;Read cx
	add	#16,r0
       }
       {
	ld_v	(r0),v2			;Read cy
	add	#16,r0
       }
       {
	add	v1[3],v1[0]		;c2x+c3x
	mul	#3,v1[3],>>#0,v1[3]	;3*c3x
       }
	add	v1[1],v1[0]		;c0x+c1x
       {
	addm	v1[2],v1[0]		;c0x+c1x+c2x+c3x
	add	v1[2],>>#-1,v1[1]	;2*c2x+c1x
       }
       {
	st_s	v1[0],(r2)		;Store cx
	add	v2[3],v2[0]		;c2y+c3y
	mul	#3,v2[3],>>#0,v2[3]	;3*c3y
       }
       {
	add	v1[3],v1[1]		;3*c3x+2*c2x+c1x
       }
       {
	st_s	v1[1],(r3)		;Store tx
	addm	r1,r3			;Increase ptr
	add	v2[1],v2[0]		;c0y+c1y
       }
	ld_v	(r0),v1			;Read cz
       {
	add	r1,r2			;Increase ptr
	addm	v2[2],v2[0]		;c0y+c1y+c2y+c3y
       }
       {
	st_s	v2[0],(r2)		;Store cy
	add	v2[2],>>#-1,v2[1]	;2*c2y+c1y
	addm	v1[3],v1[0]		;c2z+c3z
       }
       {
	add	v2[3],v2[1]		;3*c3y+2*c2y+c1y
	mul	#3,v1[3],>>#0,v1[3]	;3*c3z
       }
       {
	st_s	v2[1],(r3)		;Store ty
	add	v1[1],v1[0]		;c0z+c1z
       }
       {
	add	r1,r2			;Increase ptr
	addm	v1[2],v1[0]		;c0z+c1z+c2z+c3z
       }
       {
	rts				;Done
	st_s	v1[0],(r2)		;Store cx
	add	v1[2],>>#-1,v1[1]	;2*c2z+c1z
       }
       {
	add	v1[3],v1[1]		;3*c3z+2*c2z+c1z
	addm	r1,r3			;Increase ptr
       }
	st_s	v1[1],(r3)		;Store tx
       ;--------------------------------;rts


;* _mdNearestPointOnCurveSegment
	.export	_mdNearestPointOnCurveSegment
;* Input:
;* r0 mdBYTE*  splinedata
;* r1 mdINT32  Curve Segment#
;* r2 mdV3*    position to check with
;* r3 md2DOT30* Ptr to return param in segment
;* r4 mdV3*    nearest point on curve segment
;* Output:
;* r0 mdUINT32	Distance between position & nearest point on curve segment


;Note: This routine will find the nearest point to line segment defined by
; start & end control point of current curve segment
_mdNearestPointOnCurveSegment:
       {
	mul	#CNFOSIZE>>2,r1,>>#-2,r1 ;Offset
	ld_s	(r2),r5			;read p3.x
	add	#8,r2			;Increase Ptr
       }
       {
	add	#16,r0,v2[0]	;Skip spline header
	ld_s	(r2),r0			;read p3.z
       }
       {
	addm	r1,v2[0]		;Ptr Actual Curve segment
	sub	#8,r2,r1		;ptr position
       }
       {
	ld_s	(v2[0]),r6		;p0.x
	add	#16*2,v2[0]		;Increase ptr
       }
       {
	ld_s	(v2[0]),r7		;p0.z
	add	#16,v2[0]		;Increase ptr
       }
       {
	ld_v	(v2[0]),v2 		;v2[0] p1.x v2[2] p1.z v2[3] invdistsq
	sub	r6,r5			;p3.x-p0.x
       }
       {
	rts     vs			;curve segment too far away
	sub	r7,r0,r2  		;p3.z-p0.z
       }
       {
	mv_s	#-1,r0			;Maximum Distance between 2 points
	rts     vs			;curve segment too far away
	sub	r6,v2[0]		;p1.x-p0.x
       }
       {
	rts     vs			;curve segment too far away
	mul	v2[0],r5,>>#16+8,r5	;(p1.x-p0.x)(p3.x-p0.x) (24.8)
	sub	r7,v2[2]		;p1.z-p0.z
       }
       {
	rts     vs			;curve segment too far away
       }
       {
	rts	mvs,nop			;multiply overflow (nop for ld_s)
	mul	v2[2],r2,>>#16+8,r2	;(p1.z-p0.z)(p3.z-p0.z) (24.8)
       }
	nop				;mul delay slot
       {
	rts	mvs			;multiply overflow
	add	r5,r2			;(p1.x-p0.x)(p3.x-p0.x)+(p1.z-p0.z)(p3.z-p0.z)
	ld_s	(r1),r5			;p3.x
       }
       {
	rts     vs			;curve segment too far away
	mul	v2[3],r2,>>#30-(30-8),r2  ;Divide by distance between p0 & p1 squared
	sub	v2[3],v2[3]		;clear v2[3]
       }
       {
	st_s	v2[3],(r3)		;return u
	add	#8,r1			;ptr p3.z
       }
       {
	rts	mvs			;multiply overflow (too far away from line segment)
	sat	#31,r2			;if bigger than (1<<30), saturate
       }
       {
	bra	mi,`its1st,nop		;u is negative
	mul	r2,v2[0],>>#30,v2[0]	;u(p1.x-p0.x)
	ld_s	(r1),r1			;p3.z
       }
       ;--------------------------------;bra mi,`its1st,nop
	mul	r2,v2[2],>>#30,v2[2]	;u(p1.z-p0.z)
       {
	st_s	r2,(r3)			;set return u
	add	v2[0],r6		;p0.x+u(p1.x-p0.x)
       }
       {
	mv_s	r2,r0			;set return u
	add	v2[2],r7  		;p0.z+u(p1.z-p0.z)
       }
`its1st:
       ;Nearest pointx/z is in r6/r7
       ;Calculate distance
       	sub	r6,r5			;p3.x-p0.x
       {
	rts	vs			;overflow
       	sub	r7,r1			;p3.z-p0.z
	mul	r5,r5,>>#32,r5		;(p3.x-p0.x)(p3.x-p0.x)
       }
       {
	rts	vs			;overflow
       	st_s	r6,(r4)			;store nearx
	add	#4,r4			;increase ptr
       }
       {
	rts	mvs			;multiply overflow
       	st_s	v2[1],(r4) 		;store neary (same as point)
	add	#4,r4			;increase ptr
	mul	r1,r1,>>#32,r1		;(p3.z-p0.z)(p3.z-p0.z)
       }
       	st_s	r7,(r4)			;store nearz
       {
	rts	mvs,nop			;multiply overflow
	add	r5,r1			;Distance
       }
       {
	mv_s	r1,r0			;Set return value
	rts	vc,nop			;Done
       }
       ;--------------------------------;Done
       {
	mv_s	#-1,r0			;Distance overflow
	rts	nop			;Quit
       }
       ;--------------------------------;Done


;* _mdQuatLerp
	.export	_mdQuatLerp
;* Input:
;* r0 mdQUAT* start
;* r1 mdQUAT* end
;* r2 md2DOT30 time
;* r3 mdQUAT* destination

_mdQuatLerp:
       {
	mv_s	#4,v2[3]		;ct 4
	cmp	#0,r2			;? Time < 0
       }
       {
	bra	ge,`TimeOkay
	ld_s	(r0),v1[0]		;read start s
	add	v2[3],r0 		;Increase ptr
       }
       {
	ld_s	(r0),v1[1]		;read start vx
	add	#4,r0			;Increase ptr
       }
       {
	ld_s	(r0),v1[2]		;read start vy
	addm	v2[3],r0  		;Increase ptr
	cmp	#1<<30,r2		;Time > 1
       }
       ;--------------------------------;bra le,`TimeOkay
	sub	r2,r2			;Set Min
`TimeOkay:
       {
	ld_s	(r0),v1[3]		;read start vz
	bra	le,`TimeOkay2		;New Quaternion is 'end'
	sub	r0,r0			;Clear r0
       }
	bset	#30,r0			;Set r0 (1<<30)
       {
	ld_s	(r1),v2[0]		;read end s
	add	#4,r1			;Increase ptr
       }
       ;--------------------------------;bra le,`TimeOkay2
	copy	r0,r2 			;Set Max
`TimeOkay2:
       {
	ld_s	(r1),v2[1]		;read end vx
	add	#4,r1			;Increase ptr
       }
       {
	ld_s	(r1),v2[2]		;read end vy
	add	#4,r1			;Increase ptr
	subm	v1[0],v2[0]		;
       }
       {
	ld_s	(r1),v2[3]		;read end vz
	mul	r2,v2[0],>>#30,v2[0]	;t*(end-start)
	sub	v1[1],v2[1]		;
       }
       {
	mul	r2,v2[1],>>#30,v2[1]	;t*(end-start)
	sub	v1[2],v2[2]		;
       }
       {
	mul	r2,v2[2],>>#30,v2[2]	;t*(end-start)
	sub	v1[3],v2[3]		;
       }
	mul	r2,v2[3],>>#30,v2[3]	;t*(end-start)
	add	v2[0],v1[0]		;start+t*(end-start)
       {
	st_s	v1[0],(r3)		;Store Interpolated
	add	#4,r3			;Increase Ptr
	addm	v2[1],v1[1]		;start+t*(end-start)
       }
       {
	rts				;Done
	st_s	v1[1],(r3)		;Store Interpolated
	add	#4,r3			;Increase Ptr
	addm	v2[2],v1[2]		;start+t*(end-start)
       }
       {
	st_s	v1[2],(r3)		;Store Interpolated
	add	#4,r3			;Increase Ptr
	addm	v2[3],v1[3]		;start+t*(end-start)
       }
       {
	st_s	v1[3],(r3)		;Store Interpolated
       }
       ;--------------------------------;rts


;* _mdQuatNormal
	.export	_mdQuatNormal
;* Input:
;* r0 mdQUAT* input
;* r1 mdQUAT* output
_mdQuatNormal:
       {
	ld_s	(r0),v1[0]			;Read S
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[1]			;Read vx
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[2]			;Read vy
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[3]			;Read vz
	abs	v1[0]				;abs(S)
       }
	abs	v1[1]                           ;abs(X)
	cmp	v1[0],v1[1]			;S >= X
       {
	bra	le,`nomodif
	sub	#3*4,r0				;Ptr Qin
       }
	abs	v1[2]                           ;abs(Y)
       {
	mv_s	v1[0],r2			;max = S
	cmp	v1[0],v1[2]			;S >= Y
       }
       ;----------------------------------------;bra le,`nomodif
       {
	mv_s	v1[1],r2			;max = X
	cmp	v1[1],v1[2]			;X >= Y
       }
`nomodif:
	bra	le,`nomodif2
	abs	v1[3]                           ;abs(Z)
	cmp	r2,v1[3]			;S/X >= Z
       ;----------------------------------------;bra le,`nomodif
       {
	mv_s	v1[2],r2			;max = Y
	cmp	v1[2],v1[3]			;Y >= Z
       }
`nomodif2:
	bra	le,`nomodif3
	msb	r2,r3				;msb(Max)
	addm	r3,r3				;msb(Max)*2
       ;----------------------------------------;bra le,`nomodif2
	msb	v1[3],r3 			;msb(Max)
	addm	r3,r3				;msb(Max)*2
`nomodif3:
	sub	#28,r3,r2			;max msb(s*s+x*x+y*y+z*z)
	bra	ge,`nomodif4,nop		;shift value positive ?
       ;----------------------------------------;bra ge,`nomodif3,nop
	sub	r2,r2				;clear r2
`nomodif4:
       {
	mul	v1[0],v1[0],>>r2,v1[0]		;s*s
	mv_s	#qtsft*2,r3
       }
       {
	sub	r2,r3  	  			;#of fracbits
	mul	v1[1],v1[1],>>r2,v1[1]		;x*x
       }
	mul	v1[2],v1[2],>>r2,v1[2]		;y*y
       {
	mul	v1[3],v1[3],>>r2,v1[3]		;z*z
	add	v1[1],v1[0]			;s*s+x*x
       }
	add	v1[2],v1[0]                     ;s*s+x*x+y*y
	add	v1[3],v1[0]                     ;s*s+x*x+y*y+z*z

       ;Calculate 1/Sqrt(s*s+x*x+y*y+z*z)
       {
	rts	eq,nop				;if ZERO, finished!
	msb	v1[0],v1[3]			;sigbits msb()
       }
       ;----------------------------------------;rts eq,nop
	sub	r3,v1[3]			;
	add	#1,v1[3]			;shift1
	and	#~1,v1[3]			;shift1
       {
	addm	r3,v1[3],v2[0]			;frac
	asr	#1,v1[3]			;shift1
       }
       {
	mv_s	#RSqrtLUT - ((1<<8)/4)*4,v2[1]	;lut
	sub	#8+2,v2[0],v2[2]		;shift2
       }
       {
	mv_s	#29,r2				;ansfBits = iPrec
	as	v2[2],v1[0],v2[3]		;shiftedx()
       }
	add	v2[3],v2[1]			;lutptr
       {
	ld_s	(v2[1]),v2[1]			;y
	add	v1[3],r2			;ansfbits
       }
	copy	v1[0],v2[3]			;temp
	mul	v2[1],v2[3],>>v2[0],v2[3]	;temp
	nop
	mul	v2[1],v2[3],>>#(29+1),v2[3]	;temp
	mv_s	#fix(1.5,29),v2[2]		;threehalves
	sub	v2[3],v2[2],v2[3]		;temp
	mul	v2[3],v2[1],>>#(29),v2[1]	;y
	nop
	mul	v2[1],v1[0],>>v2[0],v1[0]	;answer
       {
	ld_s	(r0),v1[1]			;S
	add	#4,r0
       }
	mul	v2[1],v1[0],>>#(29+1),v1[0]	;answer
       {
	ld_s	(r0),v1[2]			;X
	add	#4,r0
       }
	sub	v1[0],v2[2],v1[0]		;answer
	mul	v2[1],v1[0],>>#(29),v1[0]	;answer
       {
	ld_s	(r0),v1[3]			;Y
	add	#4,r0
       }
       {
	ld_s	(r0),r3				;Z
	mul	v1[0],v1[1],>>r2,v1[1]		;S / sqrt(S*S+X*X+Y*Y+Z*Z)
       }
	mul	v1[0],v1[2],>>r2,v1[2]		;X / sqrt(S*S+X*X+Y*Y+Z*Z)
       {
	mul	v1[0],v1[3],>>r2,v1[3]		;Y / sqrt(S*S+X*X+Y*Y+Z*Z)
	st_s	v1[1],(r1)			;Store S
	add	#4,r1				;Increase Ptr
       }
       {
	rts					;Done
	mul	v1[0],r3,>>r2,r3		;Z / sqrt(S*S+X*X+Y*Y+Z*Z)
	st_s	v1[2],(r1)			;Store X
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[3],(r1)			;Store Y
	add	#4,r1				;Increase Ptr
       }
	st_s	r3,(r1)				;Store Z
       ;----------------------------------------;rts


;* _mdQuatDotProduct
	.export	_mdQuatDotProduct
	.export	_mdQuatDotProductSFT
;* Input:
;* r0 mdQUAT* input0
;* r1 mdQUAT* input1
;* r2 mdINT32 Shift value
;* r3 mdINT32* dotp

_mdQuatDotProduct:
       {
	copy	r2,r3				;Destination addr
	mv_s	#qtsft,r2			;Set shift value
       }
_mdQuatDotProductSFT:
       {
	ld_s	(r0),v1[0]			;Read S0
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[1]			;Read X0
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[2]			;Read Y0
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[3]			;Read Z0
	sub	r0,r0				;Clear r0
       }
	nop
       {
	ld_s	(r1),v2[0]			;Read S1
	add	#4,r1				;Increase ptr
       }
       {
	ld_s	(r1),v2[1]			;Read X1
	add	#4,r1				;Increase ptr
       }
       {
	ld_s	(r1),v2[2]			;Read Y1
	add	#4,r1				;Increase ptr
	mul	v2[0],v1[0],>>r2,v1[0] 		;S0*S1
       }
	ld_s	(r1),v2[3]			;Read Z1
       {
	rts	mvs				;Multiply Overflow
	mul	v2[1],v1[1],>>r2,v1[1]		;X0*X1
       }
       {
	st_s	r0,(r3)				;Clear DotProduct value
	add	#1,r0				;Set overflow code
       }
       {
	rts	mvs				;Multiply Overflow
	mul	v2[2],v1[2],>>r2,v1[2]		;Y0*Y1
	add	v1[1],v1[0]			;S0*S1+X0*X1
       }
	rts	vs				;Addition Overflow
       {
	rts	mvs				;Multiply Overflow
	mul	v2[3],v1[3],>>r2,v1[3]		;Z0*Z1
	add	v1[2],v1[0]			;S0*S1+X0*X1+Y0*Y1
       }
	rts	vs				;Addition Overflow
       {
	rts	mvs				;Multiply Overflow
	add	v1[3],v1[0]			;S0*S1+X0*X1+Y0*Y1+Z0*Z1
       }
       ;----------------------------------------;rts mvs
	rts	vc				;Addition Okay
	rts					;Done, Addition Overflow
       {
	st_s	v1[0],(r3)			;Store Result
	sub	r0,r0				;Clear Return code
       }
       ;----------------------------------------;rts vc
	mv_s	#1,r0				;Set Addition Overflow
       ;----------------------------------------;rts


;* _mdQuat2Matrix
	.export	_mdQuat2Matrix
;* Input:
;* r0 ptr Quaternion
;* r1 ptr Matrix

_mdQuat2Matrix:
	and	#-16,csp,v2[3]		;Align csp
	sub	#16,v2[3]		;1 Vector
	st_v	v3,(v2[3])		;Backup v3
       {
	ld_s	(r0),v3[0]		;Read s
	add	#4,r0			;Increase ptr
       }
       {
	ld_s	(r0),v3[1]		;Read vx
	add	#4,r0			;Increase ptr
       }
       {
	ld_s	(r0),v3[2]		;Read vy
	add	#4,r0			;Increase ptr
       }
       {
	ld_s	(r0),v3[3]		;Read vz
	copy	v3[1],v0[2]		;vx
       }
       {
	mul	v3[1],v0[2],>>#(2*qtsft-tmsft)-1,v0[2]	;2*vx*vx
	copy	v3[2],v0[3]		;vy
       }
       {
	mul	v3[2],v0[3],>>#(2*qtsft-tmsft)-1,v0[3]	;2*vy*vy
	copy	v3[3],v1[0]		;vy
	mv_s	v3[1],v1[1]		;vx
       }
       {
	mul	v3[3],v1[0],>>#(2*qtsft-tmsft)-1,v1[0]	;2*vz*vz
	copy	v3[0],v2[2]		;s
	mv_s	v3[1],v1[2]		;vx
       }
       {
	mul	v3[2],v1[1],>>#(2*qtsft-tmsft)-1,v1[1]	;2*vx*vy
	sub	v0[3],#1<<tmsft,r0	;1-vy2
	mv_s	v3[0],v2[1]		;s
       }
       {
	mul	v3[3],v2[2],>>#(2*qtsft-tmsft)-1,v2[2]	;2*s*vz
	sub	v1[0],r0		;1-vy2-vz2
	mv_s	v3[2],v1[3]		;vy
       }
       {
	mul	v3[3],v1[2],>>#(2*qtsft-tmsft)-1,v1[2]	;2*vx*vz
	st_s	r0,(r1)			;Store
	add	#4,r1			;Increase ptr
       }
       {
	mul	v3[2],v2[1],>>#(2*qtsft-tmsft)-1,v2[1]	;2*s*vy
	mv_s	v3[0],v2[0]		;s
	sub	v2[2],v1[1],r0		;vxy-svz
       }
       {
	mul	v3[3],v1[3],>>#(2*qtsft-tmsft)-1,v1[3]	;2*vy*vz
	st_s	r0,(r1)			;Store
	add	#4,r1			;Increase ptr
       }
       {
	mul	v3[1],v2[0],>>#(2*qtsft-tmsft)-1,v2[0]	;2*s*vx
	add	v2[1],v1[2],r0		;vxz+svy
       }
       {
	st_s	r0,(r1)			;Store
	add	#8,r1			;Increase ptr
       }
       {
	addm	v2[2],v1[1]		;vxy+svz
	sub	v0[2],#1<<tmsft,r0	;1-vx2
       }
       {
	st_s	v1[1],(r1)		;Store
	add	#4,r1			;Increase ptr
	subm	v1[0],r0		;1-vx2-vz2
       }
       {
	st_s	r0,(r1)			;Store
	add	#4,r1			;Increase ptr
	subm	v2[0],v1[3],r0		;vyz-svx
       }
       {
	st_s	r0,(r1)			;Store
	add	#8,r1			;Increase ptr
	subm	v2[1],v1[2],r0		;vxz-svy
       }
       {
	st_s	r0,(r1)			;Store
	add	#4,r1			;Increase ptr
	addm	v2[0],v1[3],r0		;vyz+svx
       }
       {
	st_s	r0,(r1)			;Store
	add	#4,r1			;Increase ptr
       }
       {
	rts				;Finished
	ld_v	(v2[3]),v3		;restore v3
	sub	v0[2],#1<<tmsft,r0	;1-vx2
       }
	sub	v0[3],r0		;1-vx2-vy2
	st_s	r0,(r1)			;Store
       ;--------------------------------;rts


;* _mdMatrix2Quat
	.export	_mdMatrix2Quat
;* Input:
;* r0 ptr Matrix
;* r1 ptr Quaternion

_mdMatrix2Quat:
       {
	ld_s	(r0),v1[0]		;Read m[0][0]
	add	#20,r0			;Increase ptr
       }
       {
	ld_s	(r0),v1[1]		;Read m[1][1]
	add	#20,r0			;Increase ptr
       }
       {
	ld_s	(r0),v1[2]		;Read m[2][2]
	sub	#40,r0			;ptr Matrix
       }
	add	v1[0],v1[1],r2		;Trace m[0][0]+m[1][1]
       {
	mv_s	#`Tracepos,r3		;Return address
	add	v1[2],r2		;Trace m[0][0]+m[1][1]+m[2][2]
       }
       {
	bra	lt,`Traceneg,nop	;Branch if Trace is negative
	add	#1<<tmsft,r2		;Add One
       }
       ;--------------------------------;bra lt,`traceneg,nop
       {
	bra	DoSQRTtmsft		;Find 1/sqrt(1+trace)
	add	#36,r0			;Ptr m[2][1]
	mv_s	r2,v1[0]	  	;Backup trace
       }
       {
	ld_s	(r0),v1[1]		;Read m[2][1]
	add	#24-36,r0		;Ptr m[1][2]
       }
       {
	ld_s	(r0),v1[2]		;Read m[1][2]
	add	#8-24,r0		;Ptr m[0][2]
       }
       ;--------------------------------;bra DoSQRTqtsft
`Tracepos:
       {
	ld_s	(r0),v2[0]		;Read m[0][2]
	add	#32-8,r0		;Ptr m[2][0]
       }
       {
	ld_s	(r0),v2[1]		;Read m[2][0]
	add	#16-32,r0		;Ptr m[1][0]
       }
       {
	ld_s	(r0),v2[2]		;Read m[1][0]
	add	#4-16,r0		;Ptr m[0][1]
       }
       {
	ld_s	(r0),v2[3]		;Read m[0][1]
	add	#tmsft-qtsft+1,v1[3] 	;fracbits + 1
	subm	v1[2],v1[1]		;m[2][1] - m[1][2]
       }
       {
	mul	r2,v1[0],>>v1[3],v1[0]	;s
	sub	v2[1],v2[0]		;m[0][2] - m[2][0]
       }
       {
	mul	r2,v1[1],>>v1[3],v1[1]	;vx
	sub	v2[3],v2[2]		;m[1][0] - m[0][1]
       }
       {
	mul	r2,v2[0],>>v1[3],v2[0]	;vy
	st_s	v1[0],(r1)		;Store Result
	add	#4,r1			;Increase ptr
       }
       {
	rts				;Done
	mul	r2,v2[2],>>v1[3],v2[2]	;vz
	st_s	v1[1],(r1)		;Store Result
	add	#4,r1			;Increase ptr
       }
       {
	st_s	v2[0],(r1)		;Store Result
	add	#4,r1			;Increase ptr
       }
	st_s	v2[2],(r1)		;Store Result
       ;--------------------------------;rts


`Traceneg:
       {
	mv_s	#`m00wins,r3		;set return address
	cmp	v1[0],v1[1]            	;m00 > m11
       }
       {
	bra 	le,`mbig,nop		;branch if bigger
	mv_s	v1[0],r2		;set m00
	sub     #2<<tmsft,r2,v2[0]	;Trace-1
       }
       ;--------------------------------;bra le,`mbig,nop
       {
	copy	v1[1],r2		;biggest element is m11
	mv_s	#`m11wins,r3		;set return address
       }
`mbig:
	cmp	r2,v1[2]		;m00/m11 > m22
       {
	bra	le,`mbiggest,nop	;Find 1/sqrt()
	mv_s	#1,v1[0]		;cte 1
       }
       ;--------------------------------;bra le,DoSQRTtmsft
       { ;m22 is biggest
	mv_s	#`m22wins,r3		;set return address
	copy	v1[2],r2		;biggest element is m22
       }
       ;--------------------------------;bra DoSQRTtmsft
`mbiggest:
       {
	bra	DoSQRTtmsft		;Find 1/sqrt()
	add	#36,r0			;Ptr m[2][1]
	addm	r2,r2			;2*mxx
       }
       {
	ld_s	(r0),v1[1]		;Read m[2][1]
	add	#24-36,r0		;Ptr m[1][2]
	subm	v2[0],r2		;(2*mxx)-(trace-1)
       }
       {
	ld_s	(r0),v1[2]		;Read m[1][2]
	add	#8-24,r0		;Ptr m[0][2]
	mul	r2,v1[0],>>#0,v1[0]  	;Backup trace
       }
       ;--------------------------------;bra DoSQRTqtsft

`m00wins:
       {
	ld_s	(r0),v2[0]		;Read m[0][2]
	add	#32-8,r0		;Ptr m[2][0]
       }
       {
	ld_s	(r0),v2[1]		;Read m[2][0]
	add	#16-32,r0		;Ptr m[1][0]
       }
       {
	ld_s	(r0),v2[2]		;Read m[1][0]
	add	#4-16,r0		;Ptr m[0][1]
       }
       {
	ld_s	(r0),v2[3]		;Read m[0][1]
	add	#tmsft-qtsft+1,v1[3] 	;fracbits + 1
	subm	v1[2],v1[1]		;m[2][1] - m[1][2]
       }
       {
	mul	r2,v1[1],>>v1[3],v1[1]	;s
	add	v2[1],v2[0]		;m[0][2] + m[2][0]
       }
       {
	mul	r2,v1[0],>>v1[3],v1[0]	;vx
	add	v2[3],v2[2]		;m[1][0] + m[0][1]
       }
       {
	mul	r2,v2[2],>>v1[3],v2[2]	;vy
	st_s	v1[1],(r1)		;Store Result
	add	#4,r1			;Increase ptr
       }
       {
	rts				;Done
	mul	r2,v2[0],>>v1[3],v2[0]	;vz
	st_s	v1[0],(r1)		;Store Result
	add	#4,r1			;Increase ptr
       }
       {
	st_s	v2[2],(r1)		;Store Result
	add	#4,r1			;Increase ptr
       }
	st_s	v2[0],(r1)		;Store Result
       ;--------------------------------;rts
`m11wins:
       {
	ld_s	(r0),v2[0]		;Read m[0][2]
	add	#32-8,r0		;Ptr m[2][0]
       }
       {
	ld_s	(r0),v2[1]		;Read m[2][0]
	add	#16-32,r0		;Ptr m[1][0]
       }
       {
	ld_s	(r0),v2[2]		;Read m[1][0]
	add	#4-16,r0		;Ptr m[0][1]
       }
       {
	ld_s	(r0),v2[3]		;Read m[0][1]
	add	#tmsft-qtsft+1,v1[3] 	;fracbits + 1
	subm	v2[1],v2[0]		;m[0][2] - m[2][0]
       }
       {
	mul	r2,v2[0],>>v1[3],v2[0]	;s
	add	v1[2],v1[1]		;m[2][1] + m[1][2]
       }
       {
	mul	r2,v1[0],>>v1[3],v1[0]	;vy
	add	v2[3],v2[2]		;m[1][0] + m[0][1]
       }
       {
	mul	r2,v2[2],>>v1[3],v2[2]	;vx
	st_s	v2[0],(r1)		;Store Result
	add	#8,r1			;Increase ptr
       }
       {
	mul	r2,v1[1],>>v1[3],v1[1]	;vz
	rts				;Done
	st_s	v1[0],(r1)		;Store Result
	sub	#4,r1			;Increase ptr
       }
       {
	st_s	v2[2],(r1)		;Store Result
	add	#8,r1			;Increase ptr
       }
	st_s	v1[1],(r1)		;Store Result
       ;--------------------------------;rts
`m22wins:
       {
	ld_s	(r0),v2[0]		;Read m[0][2]
	add	#32-8,r0		;Ptr m[2][0]
       }
       {
	ld_s	(r0),v2[1]		;Read m[2][0]
	add	#16-32,r0		;Ptr m[1][0]
       }
       {
	ld_s	(r0),v2[2]		;Read m[1][0]
	add	#4-16,r0		;Ptr m[0][1]
       }
       {
	ld_s	(r0),v2[3]		;Read m[0][1]
	add	#tmsft-qtsft+1,v1[3] 	;fracbits + 1
	addm	v2[1],v2[0]		;m[0][2] + m[2][0]
       }
       {
	mul	r2,v2[0],>>v1[3],v2[0]	;vx
	add	v1[2],v1[1]		;m[2][1] + m[1][2]
       }
       {
	mul	r2,v1[1],>>v1[3],v1[1]	;vy
	sub	v2[3],v2[2]		;m[1][0] - m[0][1]
       }
       {
	mul	r2,v1[0],>>v1[3],v1[0]	;vz
	add	#4,r1,r3		;ptr vx
       }
       {
	mul	r2,v2[2],>>v1[3],v2[2]	;s
	st_s	v2[0],(r3)		;Store Result
	add	#4,r3			;Increase ptr
       }
       {
	rts				;Done
	st_s	v1[1],(r3)		;Store Result
	add	#4,r3			;Increase ptr
       }
	st_s	v1[0],(r3)		;Store Result
	st_s	v2[2],(r1)		;Store Result
       ;--------------------------------;rts


       ;Calculate 1/Sqrt()
DoSQRTtmsft:
;* Input:
;* r2 value
;* r3 return address
;* Output:
;* r2 answer (1/sqrt(input r2))
;* v1[3] fracbits of answer
;* Uses:
;* v2

	msb	r2,v1[3]			;sigbits msb()
       {
	mv_s	#tmsft,v2[0]			;Matrix Shift value
	sub	#tmsft,v1[3]			;
       }
	add	#1,v1[3]			;shift1
	and	#~1,v1[3]			;shift1
       {
	addm	v1[3],v2[0]    			;frac
	asr	#1,v1[3]			;shift1
       }
       {
	mv_s	#RSqrtLUT - ((1<<8)/4)*4,v2[1]	;lut
	sub	#8+2,v2[0],v2[2]		;shift2
       }
       {
	as	v2[2],r2,v2[3]		;shiftedx()
       }
	add	v2[3],v2[1]			;lutptr
       {
	ld_s	(v2[1]),v2[1]			;y
	add	#29,v1[3]			;ansfbits
       }
	copy	r2,v2[3]			;temp
	mul	v2[1],v2[3],>>v2[0],v2[3]	;temp
	nop
	mul	v2[1],v2[3],>>#(29+1),v2[3]	;temp
	mv_s	#fix(1.5,29),v2[2]		;threehalves
	sub	v2[3],v2[2],v2[3]		;temp
	mul	v2[3],v2[1],>>#(29),v2[1]	;y
	nop
	mul	v2[1],r2,>>v2[0],r2	;answer
	mv_s	#1,v2[3]		;set v2[3] = 1
	mul	v2[1],r2,>>#(29+1),r2	;answer
	jmp	(r3)			;return
	sub	r2,v2[2],r2		;answer
	mul	v2[1],r2,>>#(29),r2	;answer
       ;--------------------------------;jmp (r3)



