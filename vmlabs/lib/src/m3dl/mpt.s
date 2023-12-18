/*
 * Title	 	MPT.S
 * Desciption		Merlin Primitive Transformation
 * Version		1.0
 * Start Date		12/07/1998
 * Last Update		02/14/2000
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


	csp	=	r31		;C Stack Pointer
	IndexBits	=	7	;#of Index Bits Recip Table MPE0
	iPrec		=	29	;
	sizeofScalar	=	2



	.module MPT

	.text


	.include "M3DL/m3dl.i"
	.include "M3DL/mpr.i"

	.import	_FixSinCos
	.import	_MPT_TransformMatrix
	.import	_MPT_Tx, _MPT_Ty, _MPT_Tz
	.import	_MPT_OffX, _MPT_OffY
	.import	_MPT_ScaleX, _MPT_ScaleY
	.import	_MPT_NearZ, _MPT_FarZ
	.import	_MPT_MatrixStack
	.import	_MPT_FogNZ, _MPT_FogMulZ
	.import	_MPT_Ambient
	.import	_RecipLUTData

	.cache
	.nooptimize


;* _mdIdentityMatrix
	.export	_mdIdentityMatrix
;* Input:
;* r0 ptr Matrix

_mdIdentityMatrix:
       {
	sub	v1[0],v1[0]			;Clear v1
	mv_s	#1<<tmsft,v1[1]			;Set One as 1.tmsft
       }
       {
	st_s	v1[1],(r0)			;Set One
	add	#4,r0				;Increase Ptr
       }
       {
	st_s	v1[0],(r0)			;Set Zero
	add	#4,r0				;Increase Ptr
       }
       {
	st_s	v1[0],(r0)			;Set Zero
	add	#4,r0				;Increase Ptr
       }
       {
	st_s	v1[0],(r0)			;Set Zero
	add	#4,r0				;Increase Ptr
       }

       {
	st_s	v1[0],(r0)			;Set Zero
	add	#4,r0				;Increase Ptr
       }
       {
	st_s	v1[1],(r0)			;Set One
	add	#4,r0				;Increase Ptr
       }
       {
	st_s	v1[0],(r0)			;Set Zero
	add	#4,r0				;Increase Ptr
       }
       {
	st_s	v1[0],(r0)			;Set Zero
	add	#4,r0				;Increase Ptr
       }

       {
	st_s	v1[0],(r0)			;Set Zero
	add	#4,r0				;Increase Ptr
       }
       {
	rts					;Done
	st_s	v1[0],(r0)			;Set Zero
	add	#4,r0				;Increase Ptr
       }
       {
	st_s	v1[1],(r0)			;Set One
	add	#4,r0				;Increase Ptr
       }
       {
	st_s	v1[0],(r0)			;Set Zero
	sub	r0,r0				;Clear return value
       }
       ;----------------------------------------;rts


;* _mdSetTransformMatrix
	.export	_mdSetTransformMatrix
;* Input:
;* r0 ptr Matrix

_mdSetTransformMatrix:
       {
	ld_s	(r0),v0[0]			;Fetch R[0][0]
	add	#4,r0,r11			;Increase Ptr
       }
       {
	ld_s	(r11),v0[1]			;Fetch R[0][1]
	add	#4,r11				;Increase Ptr
       }
       {
	ld_s	(r11),v0[2]			;Fetch R[0][2]
	add	#4,r11				;Increase Ptr
       }
       {
	ld_s	(r11),v0[3]			;Fetch R[0][3]
	add	#4,r11				;Increase Ptr
       }
       {
	ld_s	(r11),v1[0]			;Fetch R[1][0]
	add	#4,r11				;Increase Ptr
       }
       {
	ld_s	(r11),v1[1]			;Fetch R[1][1]
	add	#4,r11				;Increase Ptr
       }
       {
	ld_s	(r11),v1[2]			;Fetch R[1][2]
	add	#4,r11				;Increase Ptr
       }
       {
	ld_s	(r11),v1[3]			;Fetch R[1][3]
	add	#4,r11
       }
       {
	ld_s	(r11),v2[0]			;Fetch R[2][3]
	add	#4,r11
       }
       {
	ld_s	(r11),v2[1]			;Fetch R[2][2]
	add	#4,r11
       }
       {
	ld_s	(r11),v2[2]			;Fetch R[2][1]
	add	#4,r11
       }
       {
	ld_s	(r11),v2[3]			;Fetch R[2][3]
       }
	nop					;Delay Slot Cache Bug
       {
	st_v	v0,(_MPT_TransformMatrix)	;Store 1st Row
	rts
       }
	st_v	v1,(_MPT_TransformMatrix+0x10)	;Store 2nd Row
       {
	st_v	v2,(_MPT_TransformMatrix+0x20)	;Store 3rd Row
	sub	r0,r0				;Clear return value
       }
       ;----------------------------------------;rts


;* _mdGetTransformMatrix
	.export	_mdGetTransformMatrix
;* Input:
;* r0 ptr Matrix

_mdGetTransformMatrix:
	ld_v	(_MPT_TransformMatrix),v1
	ld_v	(_MPT_TransformMatrix+0x10),v2
       {
	st_s	v1[0],(r0)			;r00
	add	#4,r0
       }
       {
	st_s	v1[1],(r0)			;r01
	add	#4,r0
       }
       {
	st_s	v1[2],(r0)			;r02
	add	#4,r0
       }
       {
	st_s	v1[3],(r0)			;r03
	add	#4,r0
       }
       {
	st_s	v2[0],(r0)			;r10
	add	#4,r0
       }
       {
	st_s	v2[1],(r0)			;r11
	add	#4,r0
       }
       {
	st_s	v2[2],(r0)			;r12
	add	#4,r0
       }
	ld_v	(_MPT_TransformMatrix+0x20),v1
       {
	st_s	v2[3],(r0)			;r13
	add	#4,r0
       }
       {
	st_s	v1[0],(r0)			;r20
	add	#4,r0
       }
       {
	rts
	st_s	v1[1],(r0)			;r21
	add	#4,r0
       }
       {
	st_s	v1[2],(r0)			;r22
	add	#4,r0
       }
       {
	st_s	v1[3],(r0)			;r23
       }
       ;----------------------------------------;rts


;* _mdTransposeMatrix
	.export	_mdTransposeMatrix
;* Input:
;* r0 ptr Matrix (input)
;* r1 ptr Matrix (output)

_mdTransposeMatrix:
       {
	ld_s	(r0),v1[0]			;Fetch r00
	add	#0x10,r0 			;Increase Ptr
       }
       {
	ld_s	(r0),v1[1]			;Fetch r10
	add	#0x10,r0 			;Increase Ptr
       }
       {
	ld_s	(r0),v1[2]			;Fetch r20
	sub	#0x20-4,r0			;Decrease Ptr
       }
       {
	ld_s	(r0),v2[0]			;Fetch r01
	add	#0x10,r0 			;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Fetch r11
	add	#0x10,r0 			;Increase Ptr
       }
       {
	ld_s	(r0),v2[2]			;Fetch r21
	sub	#0x20-4,r0			;Decrease Ptr
       }
       {
	ld_s	(r0),v0[3]			;Fetch r02
	add	#0x10,r0 			;Increase Ptr
       }
       {
	ld_s	(r0),v1[3]			;Fetch r12
	add	#0x10,r0 			;Increase Ptr
       }
       {
	ld_s	(r0),v2[3]			;Fetch r22
       }
	nop					;Delay Slot Cache bug
       {
	st_s	v1[0],(r1)			;Store r00
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[1],(r1)			;Store r01
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[2],(r1)			;Store r02
	add	#8,r1				;Increase Ptr
       }
       {
	st_s	v2[0],(r1)			;Store r10
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v2[1],(r1)			;Store r11
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v2[2],(r1)			;Store r12
	add	#8,r1				;Increase Ptr
       }
       {
	rts					;Done
	st_s	v0[3],(r1)			;Store r20
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[3],(r1)			;Store r20
	add	#4,r1				;Increase Ptr
       }
	st_s	v2[3],(r1)			;Store r22
       ;----------------------------------------;rts


;* _mdMulMatrix
	.export	_mdMulMatrix
;* Input:
;* r0 ptr Matrix A (input)
;* r1 ptr Matrix B (input)
;* r2 ptr Matrix C (output)

_mdMulMatrix:
	;PETER
       {
	ld_s	(acshift),v1[3]			;Read acshift
	and	#-0x10,csp,r3	 		;usp Vector align
       }
       {
	st_s	#tmsft,(acshift)		;Set new Acshift
	sub	#0x10,r3			;1 Vector Storage
       }
       {
	st_v	v6,(r3)				;Backup v6
	sub	#0x10,r3			;1 Vector Storage
       }
       {
	st_v	v5,(r3)				;Backup v5
	sub	#0x10,r3			;1 Vector Storage
       }
       {
	st_v	v4,(r3)				;Backup v4
	sub	#0x10,r3			;1 Vector Storage
       }
       {
	ld_s	(r1),v4[0]			;read B[0][0]
	add	#4,r1				;B[0][1]
       }
       {
	ld_s	(r1),v4[1]			;read B[0][1]
	add	#4,r1				;B[0][2]
       }
       {
	ld_s	(r1),v4[2]			;read B[0][2]
	add	#4,r1				;B[0][3]
       }
       {
	ld_s	(r1),v4[3]			;read B[0][3]
	add	#4,r1				;B[1][0]
       }
       {
	ld_s	(r1),v5[0]			;read B[1][0]
	add	#4,r1				;B[1][1]
       }
       {
	ld_s	(r1),v5[1]			;read B[1][1]
	add	#4,r1				;B[1][2]
       }
       {
	ld_s	(r1),v5[2]			;read B[1][2]
	add	#4,r1				;B[1][3]
       }
       {
	ld_s	(r1),v5[3]			;read B[1][3]
	add	#4,r1				;B[2][0]
       }
       {
	ld_s	(r1),v6[0]			;read B[2][0]
	add	#4,r1				;B[2][1]
       }
       {
	ld_s	(r1),v6[1]			;read B[2][1]
	add	#4,r1				;B[2][2]
       }
       {
	ld_s	(r1),v6[2]			;read B[2][2]
	add	#4,r1				;B[2][3]
       }
	ld_s	(r1),v6[3]			;read B[2][3]
	st_v	v3,(r3)				;Backup v3
	sub	r1,r1				;clear
       {
	ld_s	(r0),v2[0]			;read A[0][0]
	add	#4,r0				;A[0][1]
       }
       {
	ld_s	(r0),v2[1]			;read A[0][1]
	add	#4,r0				;A[0][2]
       }
       {
	ld_s	(r0),v2[2]			;read A[0][2]
	add	#4,r0				;A[0][3]
	mul	v2[0],v4[0],>>acshift,v3[0]	;A[0][0]*B[0][0]
       }
       {
	ld_s	(r0),v2[3]			;read A[0][3]
	add	#4,r0				;A[1][0]
	mul	v2[1],v5[0],>>acshift,v3[1]	;A[0][1]*B[1][0]
       }
	mul	v2[2],v6[0],>>acshift,v3[2]	;A[0][2]*B[2][0]
       {
	add	v3[0],v3[1]			;+=C[0][0]
	mul	v2[0],v4[1],>>acshift,v3[0]	;A[0][0]*B[0][1]
       }
       {
	add	v3[1],v3[2]                     ;+=C[0][0]
	mul	v2[1],v5[1],>>acshift,v3[1]	;A[0][1]*B[1][1]
       }
       {
	st_s	v3[2],(r2)			;store C[0][0]
	add	#4,r2				;C[0][1]
	mul	v2[2],v6[1],>>acshift,v3[2]	;A[0][2]*B[1][2]
       }
       {
	add	v3[0],v3[1]			;+=C[0][1]
	mul	v2[0],v4[2],>>acshift,v3[0]	;A[0][0]*B[0][2]
       }
       {
	add	v3[1],v3[2]			;+=C[0][1]
	mul	v2[1],v5[2],>>acshift,v3[1]	;A[0][1]*B[1][2]
       }
       {
	st_s	v3[2],(r2)			;store C[0][1]
	add	#4,r2				;C[0][2]
	mul	v2[2],v6[2],>>acshift,v3[2]	;A[0][2]*B[2][2]
       }
       {
	add	v3[0],v3[1]			;+=C[0][2]
	mul	v2[0],v4[3],>>acshift,v3[0]	;A[0][0]*TB0
       }
       {
	add	v3[1],v3[2]			;+=C[0][2]
	mul	v2[1],v5[3],>>acshift,v3[1]	;A[0][1]*TB1
       }
       {
	st_s	v3[2],(r2)			;store C[0][2]
	add	#4,r2				;C[0][3]
	mul	v2[2],v6[3],>>acshift,v3[2]	;A[0][2]*TB2
       }
       {
	add	v3[0],v3[1]			;+=C[0][3]
	ld_s	(r0),v2[0]			;read A[1][0]
       }
       {
	addm	v3[1],v3[2]			;+=C[0][3]
	add	#4,r0				;A[1][1]
       }
       {
	addm	v2[3],v3[2]			;+=C[0][3]
	ld_s	(r0),v2[1]			;read A[1][1]
	add	#4,r0				;A[1][2]
       }
       {
	st_s	v3[2],(r2)			;store C[0][3]
	add	#4,r2				;C[1][0]
	mul	v2[0],v4[0],>>acshift,v3[0]	;A[1][0]*B[0][0]
       }
       {
	ld_s	(r0),v2[2]			;read A[1][2]
	add	#4,r0				;A[1][3]
	mul	v2[1],v5[0],>>acshift,v3[1]	;A[1][1]*B[1][0]
       }
       {
	ld_s	(r0),v2[3]			;read A[1][3]
	add	#4,r0				;A[2][0]
	mul	v2[0],v4[1],>>acshift,r1	;A[1][0]*B[0][1]
       }
       {
	mul	v2[2],v6[0],>>acshift,v3[2]	;A[1][2]*B[2][0]
        add	v3[0],v3[1]			;+=C[1][0]
       }
	mul	v2[1],v5[1],>>acshift,v3[0]	;A[1][1]*B[1][1]
       {
	add	v3[1],v3[2]			;+=C[1][0]
	mul	v2[2],v6[1],>>acshift,v3[1]	;A[1][2]*B[2][1]
       }
       {
	st_s	v3[2],(r2)			;store C[1][0]
	add	v3[0],r1			;+=C[1][1]
	mul	v2[0],v4[2],>>acshift,v3[0]	;A[1][0]*B[0][2]
       }
       {
	add	#4,r2				;C[1][1]
	mul	v2[1],v5[2],>>acshift,v3[2]	;A[1][1]*B[1][2]
       }
       {
       	add	v3[1],r1			;+=C[1][1]
	mul	v2[2],v6[2],>>acshift,v3[1]	;A[1][2]*B[2][2]
       }
       {
	st_s	r1,(r2)				;store C[1][1]
	add	v3[0],v3[2]			;+=C[1][2]
       }
       {
	add	#4,r2				;C[1][2]
	addm	v3[1],v3[2]			;+=C[1][2]
       }
       {
	st_s	v3[2],(r2)			;store C[1][2]
	add	#4,r2				;C[1][3]
	mul	v2[0],v4[3],>>acshift,v3[0]	;A[1][0]*TB0
       }
       {
	mul	v2[1],v5[3],>>acshift,v3[1]	;A[1][1]*TB1
	ld_s	(r0),v2[0]			;read A[2][0]
	add	#4,r0				;A[2][1]
       }
       {
	mul	v2[2],v6[3],>>acshift,v3[2]	;A[1][2]*TB2
	add	v3[0],v2[3]                     ;+=C[1][3]
	ld_s	(r0),v2[1]			;read A[2][1]
       }
	add	v3[1],v2[3]			;+=C[1][3]
       {
	addm	v3[2],v2[3]			;+=C[1][3]
	add	#4,r0				;A[2][2]
       }
       {
	ld_s	(r0),v2[2]			;read A[2][2]
	add	#4,r0				;A[2][3]
	mul	v2[0],v4[0],>>acshift,v3[0] 	;A[2][0]*B[0][0]
       }
       {
	st_s	v2[3],(r2)			;store C[1][3]
	add	#4,r2				;C[2][0]
       	mul	v2[1],v5[0],>>acshift,v3[1] 	;A[2][1]*B[1][0]
       }
       {
	ld_s	(r0),v2[3]			;read A[2][3]
	mul	v2[2],v6[0],>>acshift,v3[2] 	;A[2][2]*B[2][0]
       }
       {
	add	v3[0],v3[1]			;+=C[2][0]
	mul	v2[0],v4[1],>>acshift,v3[0] 	;A[2][0]*B[0][1]
       }
       {
	add	v3[1],v3[2]			;+=C[2][0]
	mul	v2[1],v5[1],>>acshift,v3[1] 	;A[2][1]*B[1][1]
       }
       {
	st_s	v3[2],(r2)			;store C[2][0]
	add	#4,r2				;C[2][1]
	mul	v2[2],v6[1],>>acshift,v3[2] 	;A[2][2]*B[2][1]
       }
       {
	add	v3[0],v3[1]			;+=C[2][1]
	mul	v2[0],v4[2],>>acshift,v3[0] 	;A[2][0]*B[0][2]
       }
       {
	add	v3[1],v3[2]			;+=C[2][1]
	mul	v2[1],v5[2],>>acshift,v3[1] 	;A[2][1]*B[1][2]
       }
       {
	st_s	v3[2],(r2)			;store C[2][1]
	add	#4,r2				;C[2][2]
	mul	v2[2],v6[2],>>acshift,v3[2] 	;A[2][2]*B[2][2]
       }
       {
	add	v3[0],v3[1]			;+=C[2][2]
	mul	v2[0],v4[3],>>acshift,v3[0] 	;A[2][0]*TB0
       }
       {
	add	v3[1],v3[2]			;+=C[2][2]
	mul	v2[1],v5[3],>>acshift,v2[0] 	;A[2][1]*TB1
       }
       {
	st_s	v3[2],(r2)			;store C[2][2]
	mul	v2[2],v6[3],>>acshift,r1 	;A[2][2]*TB2
	add	v2[3],v3[0]
       }
	add	v3[0],v2[0]			;+=C[2][3]
       {
	addm	v2[0],r1			;+=C[2][3]
	st_s	v1[3],(acshift)			;restore acshift
	add	#4,r2				;C[2][3]
       }
	st_s	r1,(r2)				;store C[2][3]
       {
	ld_v	(r3),v3				;restore v3
	add	#16,r3
       }
       {
	ld_v	(r3),v4				;restore v4
	add	#16,r3
       }
       {
	ld_v	(r3),v5				;restore v5
	add	#16,r3
	rts					;Done
       }
        ld_v	(r3),v6				;restore v6
	sub	r0,r0				;Clear return Value
       ;----------------------------------------;rts


;* _mdRotMatrixX
	.export	_mdRotMatrixX
;* Input:
;* r0 X angle 16.16 (input)
;* r1 ptr Matrix (input/output)

_mdRotMatrixX:
	;PETER
       {
	and	#-0x10,csp,v2[3]		;usp Vector align
	ld_s	(rz),v1[0]			;Bak rz
       }
       {
	jsr	_FixSinCos			;Find sin & cos of r0
	sub	#16,v2[3]			;1 vector storage
       }
       {
	mv_s	r1,v1[1]			;Backup ptr Matrix
	add	#12,v2[3],r2			;ptr Cos
       }
       {
	st_v	v1,(v2[3])			;Backup rz & ptr Matrix
	sub	#4,r2,r1			;ptr Sin
       }
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v0			;Restore v0
	nop
	st_s	v0[0],(rz)			;Restore rz
	ld_s	(acshift),r0			;Read acshift
	st_s	#30,(acshift)			;Set new Acshift
       {
	st_v	v3,(v2[3])			;bak v3 vector
	add	#16,r1				;A[1][0]
       }
       {
	ld_s	(r1),v1[0]			;read A[1][0]
	add	#16,r1				;A[2][0]
       }
       {
	ld_s	(r1),v1[1]			;read A[2][0]
	sub	#12,r1				;A[1][1]
       }
       {
	ld_s	(r1),v1[2]			;read A[1][1]
	add	#16,r1				;A[2][1]
	mul	r3,v1[0],>>acshift,v3[0]	;cos*A[1][0]
       }
       {
	ld_s	(r1),v2[0]			;read A[2][1]
	sub	#12,r1				;A[1][2]
	mul	r2,v1[1],>>acshift,v3[1]	;sin*A[2][0]
       }
       {
	ld_s	(r1),v2[1]			;read A[1][2]
	add	#16,r1				;A[2][2]
	mul	r2,v1[0],>>acshift,v1[0]	;sin*A[1][0]
       }
       {
	ld_s	(r1),v2[2]			;read A[2][2]
	sub	#24,r1				;A[1][0]
	mul	r3,v1[1],>>acshift,v1[1]	;cos*A[2][0]
       }
       {
	sub     v3[1],v3[0],v3[2]		;cosA[1][0]-sinA[2][0]
	mul	r3,v1[2],>>acshift,v3[1]	;cos*A[1][1]
       }
       {
	st_s	v3[2],(r1)			;store A[1][0]
	add	#16,r1				;A[2][0]
	mul	r2,v1[2],>>acshift,v1[2]	;sin*A[1][1]
       }
       {
	add	v1[1],v1[0]			;cosA[2][0]+sinA[1][0]
	mul	r2,v2[0],>>acshift,v3[0]	;sin*A[2][1]
       }
       {
        st_s	v1[0],(r1)			;store A[2][0]
	sub	#12,r1				;A[1][1]
	mul	r3,v2[0],>>acshift,v2[0]	;cos*A[2][1]
       }
       {
	sub	v3[0],v3[1],v3[2]		;cosA[1][1]-sinA[2][1]
	mul	r3,v2[1],>>acshift,v3[0]	;cos*A[1][2]
       }
       {
	st_s	v3[2],(r1)			;store A[1][1]
	add	#16,r1				;A[2][1]
	mul	r2,v2[1],>>acshift,v2[1]	;sin*A[1][2]
       }
       {
	add	v1[2],v2[0]			;sinA[1][1]+cosA[2][1]
	mul	r2,v2[2],>>acshift,v3[1]	;sin*A[2][2]
       }
       {
	st_s	v2[0],(r1)			;store A[2][1]
	sub	#12,r1				;A[1][2]
	mul	r3,v2[2],>>acshift,v2[2]	;cos*A[2][2]
       }
	sub	v3[1],v3[0],v3[2]		;cosA[1][2]-sinA[2][2]
       {
        st_s	v3[2],(r1)			;store A[1][2]
	add	#16,r1				;A[2][2]
	addm	v2[1],v2[2]			;sinA[1][2]+cosA[2][2]
       }
       {
	st_s	v2[2],(r1)			;store A[2][2]
	sub	#12,r1				;A[1][3]
       }
       {
	ld_s	(r1),v2[0]			;Ty
	add	#16,r1				;A[2][3]
       }
       {
	ld_s	(r1),v2[1]			;Tz
	sub	#16,r1				;A[1][3]
       }
	mul	r3,v2[0],>>acshift,v3[0]	;c*Ty
	mul	r2,v2[1],>>acshift,v3[1]	;s*Tz
	mul	r2,v2[0],>>acshift,v3[2]	;s*Ty
       {
	sub	v3[1],v3[0]			;cTy-sTz
	mul	r3,v2[1],>>acshift,v3[1]	;c*Tz
       }
       {
	st_s	v3[0],(r1)			;store A[1][3]
	add	#16,r1				;A[2][3]
       }
       {
	add	v3[2],v3[1]
	st_s	r0,(acshift)			;restore acshift
       }
       {
	st_s	v3[1],(r1)			;store A[2][3]
	rts
       }
	ld_v	(v2[3]),v3			;restore v3 vector
	sub	r0,r0				;clear
       ;----------------------------------------;rts


;* _mdRotMatrixY
	.export	_mdRotMatrixY
;* Input:
;* r0 Y angle 16.16 (input)
;* r1 ptr Matrix (input/output)

_mdRotMatrixY:
	;PETER
       {
	and	#-0x10,csp,v2[3]		;usp Vector align
	ld_s	(rz),v1[0]			;Bak rz
       }
       {
	jsr	_FixSinCos			;Find sin & cos of r0
	sub	#16,v2[3]			;1 vector storage
       }
       {
	mv_s	r1,v1[1]			;Backup ptr Matrix
	add	#12,v2[3],r2			;ptr Cos
       }
       {
	st_v	v1,(v2[3])			;Backup rz & ptr Matrix
	sub	#4,r2,r1			;ptr Sin
       }
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v0			;Restore v0
	nop
	st_s	v0[0],(rz)			;Restore rz
	ld_s	(acshift),r0			;Read acshift
	st_s	#30,(acshift)			;Set new Acshift
       {
	st_v	v3,(v2[3])			;bak v3 vector
       }
       {
	ld_s	(r1),v1[0]			;read A[0][0]
	add	#16+16,r1			;A[2][0]
       }
       {
	ld_s	(r1),v1[1]			;read A[2][0]
	sub	#12+16,r1			;A[0][1]
       }
       {
	ld_s	(r1),v1[2]			;read A[0][1]
	add	#16+16,r1			;A[2][1]
	mul	r3,v1[0],>>acshift,v3[0]	;cos*A[0][0]
       }
       {
	ld_s	(r1),v2[0]			;read A[2][1]
	sub	#12+16,r1			;A[0][2]
	mul	r2,v1[1],>>acshift,v3[1]	;sin*A[2][0]
       }
       {
	ld_s	(r1),v2[1]			;read A[0][2]
	add	#16+16,r1			;A[2][2]
	mul	r2,v1[0],>>acshift,v1[0]	;sin*A[0][0]
       }
       {
	ld_s	(r1),v2[2]			;read A[2][2]
	sub	#24+16,r1   			;A[0][0]
	mul	r3,v1[1],>>acshift,v1[1]	;cos*A[2][0]
       }
       {
	add     v3[1],v3[0],v3[2]		;cosA[0][0]+sinA[2][0]
	mul	r3,v1[2],>>acshift,v3[1]	;cos*A[0][1]
       }
       {
	st_s	v3[2],(r1)			;store A[0][0]
	add	#16+16,r1 			;A[2][0]
	mul	r2,v1[2],>>acshift,v1[2]	;sin*A[0][1]
       }
       {
	sub	v1[0],v1[1]			;cosA[2][0]-sinA[0][0]
	mul	r2,v2[0],>>acshift,v3[0]	;sin*A[2][1]
       }
       {
        st_s	v1[1],(r1)			;store A[2][0]
	sub	#12+16,r1  			;A[0][1]
	mul	r3,v2[0],>>acshift,v2[0]	;cos*A[2][1]
       }
       {
	add	v3[0],v3[1],v3[2]		;cosA[0][1]+sinA[2][1]
	mul	r3,v2[1],>>acshift,v3[0]	;cos*A[0][2]
       }
       {
	st_s	v3[2],(r1)			;store A[0][1]
	add	#16+16,r1			;A[2][1]
	mul	r2,v2[1],>>acshift,v2[1]	;sin*A[0][2]
       }
       {
	sub	v1[2],v2[0]			;cosA[2][1]-sinA[0][1]
	mul	r2,v2[2],>>acshift,v3[1]	;sin*A[2][2]
       }
       {
	st_s	v2[0],(r1)			;store A[2][1]
	sub	#12+16,r1			;A[0][2]
	mul	r3,v2[2],>>acshift,v2[2]	;cos*A[2][2]
       }
	add	v3[1],v3[0],v3[2]		;cosA[0][2]+sinA[2][2]
       {
        st_s	v3[2],(r1)			;store A[0][2]
	add	#16+16,r1			;A[2][2]
	subm	v2[1],v2[2]			;cosA[2][2]-sinA[0][2]
       }
       {
	st_s	v2[2],(r1)			;store A[2][2]
	sub	#28,r1				;A[0][3]
       }
       {
	ld_s	(r1),v2[0]			;Tx
	add	#32,r1				;A[2][3]
       }
       {
	ld_s	(r1),v2[1]			;Tz
	sub	#32,r1				;A[0][3]
       }
	mul	r3,v2[0],>>acshift,v3[0]	;c*Tx
	mul	r2,v2[1],>>acshift,v3[1]	;s*Tz
	mul	r2,v2[0],>>acshift,v3[2]	;s*Tx
       {
	add	v3[1],v3[0]			;cTx-sTz
	mul	r3,v2[1],>>acshift,v3[1]	;c*Tz
       }
       {
	st_s	v3[0],(r1)			;store A[0][3]
	add	#32,r1				;A[2][3]
       }
       {
	sub	v3[2],v3[1]			;cTz-sTx
	st_s	r0,(acshift)			;restore acshift
       }
       {
	st_s	v3[1],(r1)			;store A[2][3]
	rts
       }
	ld_v	(v2[3]),v3			;restore v3 vector
	sub	r0,r0				;clear
       ;----------------------------------------;rts

;* _mdRotMatrixZ
	.export	_mdRotMatrixZ
;* Input:
;* r0 Z angle 16.16 (input)
;* r1 ptr Matrix (output)

_mdRotMatrixZ:
	;PETER
       {
	and	#-0x10,csp,v2[3]		;usp Vector align
	ld_s	(rz),v1[0]			;Bak rz
       }
       {
	jsr	_FixSinCos			;Find sin & cos of r0
	sub	#16,v2[3]			;1 vector storage
       }
       {
	mv_s	r1,v1[1]			;Backup ptr Matrix
	add	#12,v2[3],r2			;ptr Cos
       }
       {
	st_v	v1,(v2[3])			;Backup rz & ptr Matrix
	sub	#4,r2,r1			;ptr Sin
       }
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v0			;Restore v0
	nop
	st_s	v0[0],(rz)			;Restore rz
	ld_s	(acshift),r0			;Read acshift
	st_s	#30,(acshift)			;Set new Acshift
       {
	st_v	v3,(v2[3])			;bak v3 vector
       }
       {
	ld_s	(r1),v1[0]			;read A[0][0]
	add	#16,r1				;A[1][0]
       }
       {
	ld_s	(r1),v1[1]			;read A[1][0]
	sub	#12,r1				;A[0][1]
       }
       {
	ld_s	(r1),v1[2]			;read A[0][1]
	add	#16,r1				;A[1][1]
	mul	r3,v1[0],>>acshift,v3[0]	;cos*A[0][0]
       }
       {
	ld_s	(r1),v2[0]			;read A[1][1]
	sub	#12,r1				;A[0][2]
	mul	r2,v1[1],>>acshift,v3[1]	;sin*A[1][0]
       }
       {
	ld_s	(r1),v2[1]			;read A[0][2]
	add	#16,r1				;A[1][2]
	mul	r2,v1[0],>>acshift,v1[0]	;sin*A[0][0]
       }
       {
	ld_s	(r1),v2[2]			;read A[1][2]
	sub	#24,r1				;A[0][0]
	mul	r3,v1[1],>>acshift,v1[1]	;cos*A[1][0]
       }
       {
	sub     v3[1],v3[0],v3[2]		;cosA[0][0]-sinA[1][0]
	mul	r3,v1[2],>>acshift,v3[1]	;cos*A[0][1]
       }
       {
	st_s	v3[2],(r1)			;store A[0][0]
	add	#16,r1				;A[1][0]
	mul	r2,v1[2],>>acshift,v1[2]	;sin*A[0][1]
       }
       {
	add	v1[1],v1[0]			;cosA[1][0]+sinA[0][0]
	mul	r2,v2[0],>>acshift,v3[0]	;sin*A[1][1]
       }
       {
        st_s	v1[0],(r1)			;store A[1][0]
	sub	#12,r1				;A[0][1]
	mul	r3,v2[0],>>acshift,v2[0]	;cos*A[1][1]
       }
       {
	sub	v3[0],v3[1],v3[2]		;cosA[0][1]-sinA[1][1]
	mul	r3,v2[1],>>acshift,v3[0]	;cos*A[0][2]
       }
       {
	st_s	v3[2],(r1)			;store A[0][1]
	add	#16,r1				;A[1][1]
	mul	r2,v2[1],>>acshift,v2[1]	;sin*A[0][2]
       }
       {
	add	v1[2],v2[0]			;sinA[0][1]+cosA[1][1]
	mul	r2,v2[2],>>acshift,v3[1]	;sin*A[1][2]
       }
       {
	st_s	v2[0],(r1)			;store A[1][1]
	sub	#12,r1				;A[0][2]
	mul	r3,v2[2],>>acshift,v2[2]	;cos*A[1][2]
       }
	sub	v3[1],v3[0],v3[2]		;cosA[0][2]-sinA[1][2]
       {
        st_s	v3[2],(r1)			;store A[0][2]
	add	#16,r1				;A[1][2]
	addm	v2[1],v2[2]			;sinA[0][2]+cosA[1][2]
       }
       {
	st_s	v2[2],(r1)			;store A[1][2]
	sub	#12,r1				;A[0][3]
       }
       {
	ld_s	(r1),v2[0]			;Tx
	add	#16,r1				;A[1][3]
       }
       {
	ld_s	(r1),v2[1]			;Ty
	sub	#16,r1				;A[0][3]
       }
	mul	r3,v2[0],>>acshift,v3[0]	;c*Tx
	mul	r2,v2[1],>>acshift,v3[1]	;s*Ty
	mul	r2,v2[0],>>acshift,v3[2]	;s*Tx
       {
	sub	v3[1],v3[0]			;cTx-sTy
	mul	r3,v2[1],>>acshift,v3[1]	;c*Ty
       }
       {
	st_s	v3[0],(r1)			;store A[0][3]
	add	#16,r1				;A[1][3]
       }
       {
	add	v3[2],v3[1]			;cTy+sTx
	st_s	r0,(acshift)			;restore acshift
       }
       {
	st_s	v3[1],(r1)			;store A[1][3]
	rts
       }
	ld_v	(v2[3]),v3			;restore v3 vector
	sub	r0,r0				;clear
       ;----------------------------------------;rts

;* _mdRotMatrixXYZ
	.export	_mdRotMatrixXYZ
	.export	_mdRotMatrix
;* Input:
;* r0 ptr Rotation Vector (input)
;* r1 ptr Matrix (output)

_mdRotMatrixXYZ:
_mdRotMatrix:
	;PETER
       {
	and	#-0x10,csp,v2[3]		;usp Vector align
	ld_s	(rz),v0[2] 			;Bak rz
       }
 	sub	#16,v2[3]			;1 vector storage
       {
	st_v	v3,(v2[3])			;Bak v3
	sub	#16,v2[3]			;1 vector storage
       }
       	mv_v	v0,v3				;Bak v0
       {
	st_v	v4,(v2[3])			;Bak v4
	sub	#16,v2[3]			;1 vector storage
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	ld_s	(v3[0]),r0			;angle
	add	#12,v2[3],r2			;ptr Cos
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v1			;Restore result
	add	#4,v3[0]			;+
       {
	mv_s	v1[2],v4[1]			;s0
	copy	v1[3],v4[0]			;c0
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	add	#12,v2[3],r2			;ptr Cos
	ld_s	(v3[0]),r0			;angle
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v1			;Restore result
	add	#4,v3[0]			;+
       {
	mv_s	v1[2],v4[3]			;s1
	copy	v1[3],v4[2]			;c1
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	add	#12,v2[3],r2			;ptr Cos
	ld_s	(v3[0]),r0			;angle
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
       {
	ld_s	(acshift),v3[0]			;Read acshift
	add	#8,v3[1]			;A[0][2]
	subm    v2[2],v2[2]			;clear
       }
       {
	st_s	#(2*30)-tmsft,(acshift)	 	;Set new acshift
	sub	#1,v2[2]			;set -1
       }
       {
	asr	#30-tmsft,v4[3],v0[0]		;s1 4.28
	ld_v	(v2[3]),v1			;Restore result
						;s2=v1[2],c2=v1[3]
       }
	add	#16,v2[3]			;v4
       {
	st_s	v3[2],(rz)			;Restore rz
	mul	v4[2],v1[3],>>acshift,v2[0]	;c1*c2
       }
       {
	st_s	v0[0],(v3[1])			;store A[0][2]
	sub	#8,v3[1]			;A[0][0]
	mul	v4[2],v1[2],>>acshift,v2[1]	;c1*s2
       }
       {
	st_s	v2[0],(v3[1])			;store A[0][0]
	add	#4,v3[1]			;A[0][1]
	mul	v4[1],v4[2],>>acshift,v2[0] 	;s0*c1
       }
       {
	neg	v2[1]                           ;-c1*s2
	mul	v4[0],v4[2],>>acshift,v1[0]	;c0*c1
       }
       {
	st_s	v2[1],(v3[1])			;store A[0][1]
	add	#36,v3[1]			;A[2][2]
	mul	v2[2],v2[0],>>#0,v2[0]		;-s0*c1
       }
       {
	st_s	v1[0],(v3[1])			;store A[2][2]
	sub	#16,v3[1]			;A[1][2]
	mul	v4[0],v1[2],>>acshift,v1[0]	;c0*s2 4.28
       }
       {
	st_s	v2[0],(v3[1])			;store A[1][2]
	sub	#8,v3[1]			;A[1][0]
	mul	v4[1],v4[3],>>acshift,v2[0]	;s0*s1 4.28
       }
       {
	copy	v1[3],v1[1]			;c2 2.30
	mul     v4[0],v1[3],>>acshift,v0[0]	;c0*c2 4.28
       }
       {
	mul	v2[0],v1[1],>>#30,v1[1]		;s0*s1*c2 4.28
	copy	v2[0],v0[1]			;s0*s1 4.28
       }
       {
	mul	v1[2],v0[1],>>#30,v0[1]		;s0*s1*s2 4.28
	copy	v1[3],v2[0]			;c2 2.30
       }
       {
	add	v1[1],v1[0]			;(c0*s2)+(s0*s1*c2)
	mul	v4[0],v4[3],>>acshift,v1[1]	;c0*s1 4.28
       }
       {
	st_s	v1[0],(v3[1])			;store A[1][0]
	add	#4,v3[1]			;A[1][1]
	mul	v4[1],v1[2],>>acshift,v2[1]	;s0*s2 4.28
       }
       {
        sub     v0[1],v0[0]			;(c0*c2)-(s0*s1*s2)
	mul	v1[1],v2[0],>>#30,v2[0]		;c0*s1*c2 4.28
       }
       {
	st_s	v0[0],(v3[1])			;store A[1][1]
	add	#12,v3[1]			;A[2][0]
	mul     v1[1],v1[2],>>#30,v1[2]		;c0*s1*s2 4.28 ! Lost s2!!
       }
       {
	sub	v2[0],v2[1]			;(s0*s2)-(c0*s1*c2)
	mul	v4[1],v1[3],>>acshift,v2[0]	;s0*c2 4.28
       }
       {
	st_s	v2[1],(v3[1])			;store A[2][0]
	add	#4,v3[1]			;A[2][1]
       }
       {
	add	v2[0],v1[2]			;(s0*c2)+(c0*s1*s2)
	st_s	v3[0],(acshift)			;restore acshift
       }
       {
	st_s	v1[2],(v3[1])			;store A[2][1]
       }
       {
	ld_v	(v2[3]),v4			;restore v4
	add	#16,v2[3]			;v3
	rts
       }
	ld_v	(v2[3]),v3			;restore v3
	add	#16,v2[3]			;start
       ;----------------------------------------;rts


;* _mdRotMatrixYXZ
	.export	_mdRotMatrixYXZ
;* Input:
;* r0 ptr Rotation Vector (input)
;* r1 ptr Matrix (output)

_mdRotMatrixYXZ:
	;PETER
       {
	and	#-0x10,csp,v2[3]		;usp Vector align
	ld_s	(rz),v0[2] 			;Bak rz
       }
 	sub	#16,v2[3]			;1 vector storage
       {
	st_v	v3,(v2[3])			;Bak v3
	sub	#16,v2[3]			;1 vector storage
       }
       	mv_v	v0,v3				;Bak v0
       {
	st_v	v4,(v2[3])			;Bak v4
	sub	#16,v2[3]			;1 vector storage
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	ld_s	(v3[0]),r0			;angle
	add	#12,v2[3],r2			;ptr Cos
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v1			;Restore result
	add	#4,v3[0]			;+
       {
	mv_s	v1[2],v4[1]			;s0
	copy	v1[3],v4[0]			;c0
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	add	#12,v2[3],r2			;ptr Cos
	ld_s	(v3[0]),r0			;angle
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v1			;Restore result
	add	#4,v3[0]			;+
       {
	mv_s	v1[2],v4[3]			;s1
	copy	v1[3],v4[2]			;c1
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	add	#12,v2[3],r2			;ptr Cos
	ld_s	(v3[0]),r0			;angle
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
       {
	ld_s	(acshift),v3[0]			;Read acshift
	add	#24,v3[1]			;A[1][2]
	subm    v2[2],v2[2]			;clear
       }
       {
	st_s	#32,(acshift)			;Set new acshift
	sub	#1,v2[2]			;set -1
       }
       {
	asr	#30-tmsft,v4[1],v0[0]		;s0 4.28
	ld_v	(v2[3]),v1			;Restore result
						;s2=v1[2],c2=v1[3]
       }
	add	#16,v2[3]			;v4
       {
	st_s	v3[2],(rz)			;Restore rz
	mul	v4[0],v1[3],>>acshift,v2[0]	;c0*c2  4.28
	neg	v0[0]				;-s0
       }
       {
	st_s	v0[0],(v3[1])			;store A[1][2]
	sub	#4,v3[1]			;A[1][1]
	mul	v4[0],v1[2],>>acshift,v2[1]	;c0*s2 4.28
       }
       {
	st_s	v2[0],(v3[1])			;store A[1][1]
	sub	#4,v3[1]			;A[1][0]
	mul	v4[0],v4[2],>>acshift,v2[0] 	;c0*c1 4.28
       }
       {
	st_s	v2[1],(v3[1])			;store A[1][0]
	add	#24,v3[1]			;A[2][2]
	mul	v4[3],v4[0],>>acshift,v2[1]	;s1*c0 4.28
       }
       {
	st_s	v2[0],(v3[1])			;store A[2][2]
	sub	#32,v3[1]			;A[0][2]
	mul	v4[1],v4[3],>>acshift,v2[0]	;s0*s1 4.28
       }
       {
       	st_s	v2[1],(v3[1])			;store A[0][2]
	mul	v4[2],v1[3],>>acshift,v1[0]	;c1*c2 4.28
       }
       {
	mul	v1[2],v2[0],>>#30,v2[0]		;s0*s1*s2 4.28
	copy	v2[0],v2[1]			;s0*s1 4.28
       }
       {
	sub	#8,v3[1]			;A[0][0]
	mul	v4[2],v1[2],>>acshift,v1[1]	;c1*s2 4.28
       }
       {
	add	v2[0],v1[0]			;(c1*c2)+(s0*s1*s2) 4.28
	mul	v1[3],v2[1],>>#30,v2[1]		;s0*s1*c2 4.28
       }
       {
	st_s	v1[0],(v3[1])			;store A[0][0]
	neg	v1[1]				;-c1*s2
	mul	v4[2],v4[1],>>acshift,v1[0]	;c1*s0 4.28
       }
       {
	add     v2[1],v1[1]			;-(c1*s2)+(s0*s1*c2)
	mul	v4[3],v1[3],>>acshift,v2[1] 	;s1*c2 4.28
       }
       {
	add	#4,v3[1]			;A[0][1]
	mul	v1[2],v1[0],>>#30,v1[0]		;c1*s0*s2 4.28
	mv_s	v1[0],v0[0]			;c1*s0 4.28
       }
       {
	st_s	v1[1],(v3[1])			;store A[0][1]
	add	#28,v3[1]			;A[2][0]
	mul	v1[3],v0[0],>>#30,v0[0]		;c1*s0*c2 4.28
       }
       {
	sub	v2[1],v1[0]			;(c1*s0*s2)-(s1*c2)
	mul	v4[3],v1[2],>>acshift,v2[0]	;s1*s2 4.28
       }
       {
	st_s 	v1[0],(v3[1])			;store A[2][0]
	add	#4,v3[1]			;A[2][1]
       }
       {
	add	v2[0],v0[0]			;(c1*s0*c2)+(s1*s2)
	st_s	v3[0],(acshift)			;restore acshift
       }
	st_s	v0[0],(v3[1])			;store A[2][1]
       {
	ld_v	(v2[3]),v4			;restore v4
	add	#16,v2[3]			;v3
	rts
       }
	ld_v	(v2[3]),v3			;restore v3
	add	#16,v2[3]			;start
       ;----------------------------------------;rts


;* _mdRotMatrixZYX
	.export	_mdRotMatrixZYX
;* Input:
;* r0 ptr Rotation Vector (input)
;* r1 ptr Matrix (output)

_mdRotMatrixZYX:
	;PETER
       {
	and	#-0x10,csp,v2[3]		;usp Vector align
	ld_s	(rz),v0[2] 			;Bak rz
       }
 	sub	#16,v2[3]			;1 vector storage
       {
	st_v	v3,(v2[3])			;Bak v3
	sub	#16,v2[3]			;1 vector storage
       }
       	mv_v	v0,v3				;Bak v0
       {
	st_v	v4,(v2[3])			;Bak v4
	sub	#16,v2[3]			;1 vector storage
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	ld_s	(v3[0]),r0			;angle
	add	#12,v2[3],r2			;ptr Cos
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v1			;Restore result
	add	#4,v3[0]			;+
       {
	mv_s	v1[2],v4[1]			;s0
	copy	v1[3],v4[0]			;c0
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	add	#12,v2[3],r2			;ptr Cos
	ld_s	(v3[0]),r0			;angle
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
	ld_v	(v2[3]),v1			;Restore result
	add	#4,v3[0]			;+
       {
	mv_s	v1[2],v4[3]			;s1
	copy	v1[3],v4[2]			;c1
	jsr	_FixSinCos			;Find sin & cos of r0
       }
       {
	add	#12,v2[3],r2			;ptr Cos
	ld_s	(v3[0]),r0			;angle
       }
	sub	#4,r2,r1			;ptr Sin
       ;----------------------------------------;jsr _FixSinCos
       {
	ld_s	(acshift),v3[0]			;Read acshift
	add	#32,v3[1]			;A[2][0]
	subm    v2[2],v2[2]			;clear
       }
       {
	st_s	#32,(acshift)			;Set new acshift
	sub	#1,v2[2]			;set -1
       }
       {
	asr	#30-tmsft,v4[3],v0[0]		;s1 4.28
	ld_v	(v2[3]),v1			;Restore result
						;s2=v1[2],c2=v1[3]
       }
       {
	add	#16,v2[3]			;v4
	mul	v2[2],v0[0],>>#0,v0[0]		;-s1
       }
       {
	st_s	v3[2],(rz)			;Restore rz
	mul	v4[2],v4[1],>>acshift,v2[0]	;c1*s0  4.28
       }
       {
	st_s	v0[0],(v3[1])			;store A[2][0]
	add	#4,v3[1]			;A[2][1]
	mul	v4[2],v4[0],>>acshift,v2[1]	;c1*c0 4.28
       }
       {
	st_s	v2[0],(v3[1])			;store A[2][1]
	add	#4,v3[1]			;A[2][2]
	mul	v1[2],v4[2],>>acshift,v2[0] 	;s2*c1 4.28
       }
       {
	st_s	v2[1],(v3[1])			;store A[2][2]
	sub	#24,v3[1]			;A[1][0]
	mul	v1[3],v4[2],>>acshift,v2[1]	;c2*c1 4.28
       }
       {
	st_s	v2[0],(v3[1])			;store A[1][0]
	sub	#16,v3[1]			;A[0][0]
	mul	v1[2],v4[0],>>acshift,v2[0]	;s2*c0 4.28
       }
       {
	st_s	v2[1],(v3[1])			;store A[0][0]
	add	#4,v3[1]			;A[0][1]
	mul	v1[3],v4[3],>>acshift,v2[1]	;c2*s1 4.28
       }
       {
	neg	v2[0]				;-s2*c0
	mul	v1[2],v4[1],>>acshift,v1[0]	;s2*s0 4.28
       }
       {
	copy	v2[1],v1[1]			;c2*s1 4.28
	mul	v4[1],v2[1],>>#30,v2[1]		;c2*s1*s0 4.28
       }
       {
	mul	v4[0],v1[1],>>#30,v1[1]		;c2*s1*c0 4.28
	copy	v1[0],v0[1]			;s2*s0
       }
       {
	add	v2[1],v2[0]			;-(s2*c0)+(c2*s1*s0)
	mul	v1[3],v4[0],>>acshift,v0[0]	;c2*c0 4.28
       }
       {
	st_s	v2[0],(v3[1])			;store A[0][1]
        add	#4,v3[1]			;A[0][2]
	mul	v4[3],v0[1],>>#30,v0[1]		;s2*s0*s1 4.28
       }
       {
	add	v1[1],v1[0]			;(s2*s0)+(c2*s1*c0)
	mul	v1[2],v4[3],>>acshift,v2[0]	;s2*s1 4.28
       }
       {
	st_s	v1[0],(v3[1])                   ;store A[0][2]
	add	v0[1],v0[0]			;(c2*c0)+(s2*s1*s0)
	mul	v4[1],v1[3],>>acshift,v2[1]	;s0*c2 4.28
       }
       {
	add	#12,v3[1]			;A[1][1]
	mul	v4[0],v2[0],>>#30,v2[0]		;s2*s1*c0 4.28
       }
       {
	st_s	v0[0],(v3[1])			;store A[1][1]
	neg	v2[1]				;-s0*c2
       }
       {
	addm	v2[0],v2[1],v0[0]		;-(s0*c2)+(s2*s1*c0)
	st_s	v3[0],(acshift)			;restore acshift
	add	#4,v3[1]			;A[1][2]
       }
	st_s	v0[0],(v3[1])			;store A[1][2]
       {
	ld_v	(v2[3]),v4			;restore v4
	add	#16,v2[3]			;v3
	rts
       }
	ld_v	(v2[3]),v3			;restore v3
	add	#16,v2[3]			;start
       ;----------------------------------------;rts


;* _mdSetFarZ
	.export	_mdSetFarZ
;* Input:
;* r0 FarZ

_mdSetFarZ:
	rts					;Done
	st_s	r0,(_MPT_FarZ)			;Set FarZ
	sub	r0,r0				;Clear Return value
       ;----------------------------------------;rts


;* _mdSetNearZ
	.export	_mdSetNearZ
;* Input:
;* r0 NearZ

_mdSetNearZ:
	mv_s	#1<<precdepthz,r2               ;r2 MinimumNearZ
	cmp	r2,r0				;MinimumNearZ <= ReqNearZ
	rts	ge				;Done
       {
	st_s	r0,(_MPT_NearZ)			;Set NearZ
	rts					;Done
       }
	sub	r0,r0				;Clear Return value
       ;----------------------------------------;rts ge
	st_s	r2,(_MPT_NearZ)			;Set Minimum NearZ
       ;----------------------------------------;rts


;* _mdSetNearFarZ
	.export	_mdSetNearFarZ
;* Input:
;* r0 NearZ
;* r1 FarZ

_mdSetNearFarZ:
	mv_s	#1<<precdepthz,r2               ;r2 MinimumNearZ
	cmp	r2,r0 				;MinimumNearZ <= ReqNearZ
       {
	st_s	r1,(_MPT_FarZ)			;Set FarZ
	rts	ge				;Done
       }
       {
	st_s	r0,(_MPT_NearZ)			;Set NearZ
	rts					;Done
       }
	sub	r0,r0				;Clear Return value
       ;----------------------------------------;rts ge
	st_s	r2,(_MPT_NearZ)			;Set Minimum NearZ
       ;----------------------------------------;rts


;* _mdSetFrustum
	.export	_mdSetFrustum
;* Input:
;* r0 FOV angle 16.16
;* r1 Width (Integer)
;* r2 Height (Integer)
;* r3 PhysAspect Ratio 16.16
;* r4 NearZ
;* r5 FarZ

_mdSetFrustum:
       {
	mv_s	#1<<precdepthz,v2[2]            ;v2[2] MinimumNearZ
	lsl	#subres-1,r1,v2[0]		;Width/2 in .4
       }
       {
	st_s	r4,(_MPT_NearZ)			;Set NearZ
	cmp	v2[2],r4			;MinimumNearZ <= NearZ
       }
       {
	bra	ge,`nominnearz			;Yap, dont store min NearZ
	st_s	r5,(_MPT_FarZ)			;Set FarZ
	lsl	#subres-1,r2,v2[1]   		;Height/2 in .4
       }
	st_s	v2[0],(_MPT_OffX)		;XOffset & XClip
	st_s	v2[1],(_MPT_OffY)		;YOffset & YClip
       ;----------------------------------------;bra ge,`nominnearz
	st_s	v2[2],(_MPT_NearZ)		;Store minimum NearZ
`nominnearz:
       {
	mv_s	r3,v1[2]			;Backup height
	copy	r1,v1[1]			;Backup width
       }
       {
	ld_s	(rz),v1[3]			;Backup rz
	and	#-0x10,csp,v2[3]		;usp Vector align
       }
       {
	mul	r2,v1[2],>>#0,v1[2]		;height*physaspectratio
	sub	#0x10,v2[3]			;1 Vector Storage
       }
       ;----------------------------------------;bra le,`zsftok
       {
	jsr	_FixSinCos			;Find sin & cos of r0
	lsr	#1,r0				;angle/2
       }
       {
	st_v	v1,(v2[3]) 			;Backup v1
	sub	#8,v2[3]			;
       }
       {
	mv_s	v2[3],r1   			;Ptr Sin
	add	#4,v2[3],r2			;Ptr Cos
       }
       ;----------------------------------------;jsr __fix_sincos
       {
	ld_s	(v2[3]),r0			;Read Sin
	add	#4,v2[3]
       }
       {
	ld_s	(v2[3]),v2[0]			;Read Cos
       }
	cmp	#0,r0				;Verify Sin
	jsr	ne,_Recip			;Find Reciprocal
	mv_s	#30,r1				;#of Fracbits
	add	#4,v2[3]
       ;----------------------------------------;jsr ne,_Recip
	ld_v	(v2[3]),v1 			;Restore v0
	add	#1,r1
       {
	mul	v2[0],v1[1],>>#30-(sclsft),v1[1]  	;Width*Cos as .20
	mv_s	#_MPT_Ambient,r3		;Set Ptr Ambient color
       }
       {
	mul	v2[0],v1[2],>>#30-(sclsft-16),v1[2]    	;Height*Cos as .20
	st_s	v1[3],(rz)			;Set Return Address
       }
       {
	mv_s	#0xFFFFFF00,r2			;Default Ambient color
	mul	r0,v1[1],>>r1,v1[1]		;XScale as 12.20
       }
       {
	st_s	r2,(r3)				;Set Default Ambient Color
	mul	r0,v1[2],>>r1,v1[2]		;YScale as 12.20
	rts					;Done
       }
	st_s	v1[1],(_MPT_ScaleX)		;Set XScale
	st_s	v1[2],(_MPT_ScaleY)		;Set YScale
       ;----------------------------------------;rts


;* _mdRot
	.export	_mdRot
	.export	_mdRot3
	.export	_mdRot4
	.export	_mdRotN
;* Input:
;* r0 mdP3* input
;* r1 mdP3* output
;* r2 N for mdRotN

_mdRot:
	push	v3				;Backup v3
       {
	ld_s	(r0),v1[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[2]			;Read Z
	add	#4,r1,r2			;Ptr y'
       }
	add	#8,r1,r3			;Ptr z'
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
       {
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
       }
       {
	add	v2[1],v2[0]			;r00*X + r01*Y
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
       }
       {
	add	v2[2],v2[0],r0			;r00*X + r01*Y + r02*Z
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
       }
       {
	st_s	r0,(r1)				;Store x'
	add	v3[1],v3[0]			;r10*X + r11*Y
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r20*X
       }
       {
	add	v3[2],v3[0]			;r10*X + r11*Y + r12*Z
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r21*Y
       }
       {
	st_s	v3[0],(r2)			;Store y'
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r22*Z
       }
       {
	rts					;Done
	pop	v3				;Restore v3
	add	v2[1],v2[0]			;r20*X + r21*Y
       }
	add	v2[2],v2[0]			;r20*X + r21*Y + r22*Z
       {
	st_s	v2[0],(r3)			;Store z'
	sub	r0,r0				;Clear Return Value
       }
       ;----------------------------------------;rts


_mdRot4:
       {
	bra	RotCore				;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#4,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransCore

_mdRot3:
       {
	bra	RotCore				;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#3,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransCore

_mdRotN:
	ld_s	(rc0),r3			;Backup rc0
	st_s	r2,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3

RotCore:
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	copy	r0,v1[3]			;Ptr
       {
	ld_s	(v1[3]),v1[0]			;Read X
	add	#4,v1[3] 			;Increase Ptr
       }
       {
	ld_s	(v1[3]),v1[1]			;Read Y
	add	#4,v1[3]			;Increase Ptr
       }
       {
	ld_s	(v1[3]),v1[2]			;Read Z
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
       }
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y

`RLoop:
       {
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
       }
       {
	add	v2[1],v2[0]			;r00*X + r01*Y
       }
       {
	add	v2[2],v2[0],r2			;r00*X + r01*Y + r02*Z
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
       }
       {
	add	#4,v1[3]			;Increase Ptr
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
       }
       {
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r20*X
	ld_s	(v1[3]),v1[0]			;Read X
	add	#4,v1[3] 			;Increase Ptr
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r21*Y
	ld_s	(v1[3]),v1[1]			;Read Y
	add	#4,v1[3]			;Increase Ptr
       }
       {
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r22*Z
	ld_s	(v1[3]),v1[2]			;Read Z
	add	v3[1],v3[0]			;r10*X + r11*Y
       }
       {
	add	v3[2],v3[0]			;r10*X + r11*Y + r12*Z
	dec	rc0				;Decrement Counter
       }
       {
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	copy	v2[0],v3[1]			;r20*X
	addm	v2[1],v2[2],v3[2]		;r21*Y + r22*Z
       }
       {
	bra	c0ne,`RLoop			;Loop
	st_s	r2,(r1)				;Store x'
	add	#4,r1				;Increase Ptr
	addm	v3[2],v3[1]			;r20*X + r21*Y + r22*Z
       }
       {
	st_s	v3[0],(r1) 			;Store y'
	add	#4,r1				;Increase Ptr
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
       }
       {
	st_s	v3[1],(r1) 			;Store z'
	add	#4,r1				;Increase Ptr
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
       }
       ;----------------------------------------;bra c0ne,`RLoop
       {
	st_s	r3,(rc0)			;Restore rc0
	rts					;Done
       }
	pop	v3				;Restore v3
	sub	r0,r0				;Clear Return Value
       ;----------------------------------------;rts


;* _mdRotTrans
	.export	_mdRotTrans
	.export	_mdRotTrans3
	.export	_mdRotTrans4
	.export	_mdRotTransN
;* Input:
;* r0 mdP3* input
;* r1 mdP3* output
;* r2 N for mdRotTransN

_mdRotTrans:
	push	v3				;Backup v3
       {
	ld_s	(r0),v1[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[2]			;Read Z
	add	#4,r1,r2			;Ptr y'
       }
	add	#8,r1,r3			;Ptr z'
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
       {
	add	v2[3],v2[0]			;Tx + r00*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
       }
       {
	add	v2[1],v2[0]			;Tx + r00*X + r01*Y
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
       }
       {
	add	v2[2],v2[0],r0			;Tx + r00*X + r01*Y + r02*Z
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	add	v3[3],v3[0]			;Ty + r10*X
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
       }
       {
	st_s	r0,(r1)				;Store x'
	add	v3[1],v3[0]			;Ty + r10*X + r11*Y
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r20*X
       }
       {
	add	v3[2],v3[0]			;Ty + r10*X + r11*Y + r12*Z
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r21*Y
       }
       {
	st_s	v3[0],(r2)			;Store y'
	add	v2[3],v2[0]			;Tz + r20*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r22*Z
       }
       {
	rts					;Done
	pop	v3				;Restore v3
	add	v2[1],v2[0]			;Tz + r20*X + r21*Y
       }
	add	v2[2],v2[0]			;Tz + r20*X + r21*Y + r22*Z
       {
	st_s	v2[0],(r3)			;Store z'
	sub	r0,r0				;Clear Return Value
       }
       ;----------------------------------------;rts


_mdRotTrans4:
       {
	bra	RotTransCore			;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#4,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransCore

_mdRotTrans3:
       {
	bra	RotTransCore			;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#3,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransCore

_mdRotTransN:
	ld_s	(rc0),r3			;Backup rc0
	st_s	r2,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3

RotTransCore:
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	copy	r0,v1[3]			;Ptr
       {
	ld_s	(v1[3]),v1[0]			;Read X
	add	#4,v1[3] 			;Increase Ptr
       }
       {
	ld_s	(v1[3]),v1[1]			;Read Y
	add	#4,v1[3]			;Increase Ptr
       }
       {
	ld_s	(v1[3]),v1[2]			;Read Z
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
       }
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y

`RTLoop:
       {
	add	v2[3],v2[0]			;Tx + r00*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
       }
       {
	add	v2[1],v2[0]			;Tx + r00*X + r01*Y
       }
       {
	add	v2[2],v2[0],r2			;Tx + r00*X + r01*Y + r02*Z
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
       }
       {
	add	#4,v1[3]			;Increase Ptr
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	add	v3[3],v3[0]			;Ty + r10*X
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
       }
       {
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r20*X
	ld_s	(v1[3]),v1[0]			;Read X
	add	#4,v1[3] 			;Increase Ptr
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r21*Y
	ld_s	(v1[3]),v1[1]			;Read Y
	add	#4,v1[3]			;Increase Ptr
       }
       {
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r22*Z
	ld_s	(v1[3]),v1[2]			;Read Z
	add	v3[1],v3[0]			;Ty + r10*X + r11*Y
       }
       {
	add	v3[2],v3[0]			;Ty + r10*X + r11*Y + r12*Z
	dec	rc0				;Decrement Counter
       }
       {
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	add	v2[3],v2[0],v3[1]		;Tz + r20*X
	addm	v2[1],v2[2],v3[2]		;r21*Y + r22*Z
       }
       {
	bra	c0ne,`RTLoop			;Loop
	st_s	r2,(r1)				;Store x'
	add	#4,r1				;Increase Ptr
	addm	v3[2],v3[1]			;Tz + r20*X + r21*Y + r22*Z
       }
       {
	st_s	v3[0],(r1) 			;Store y'
	add	#4,r1				;Increase Ptr
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
       }
       {
	st_s	v3[1],(r1) 			;Store z'
	add	#4,r1				;Increase Ptr
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
       }
       ;----------------------------------------;bra c0ne,`RTLoop
       {
	st_s	r3,(rc0)			;Restore rc0
	rts					;Done
       }
	pop	v3				;Restore v3
	sub	r0,r0				;Clear Return Value
       ;----------------------------------------;rts


;* _mdPers
	.export	_mdPers
	.export	_mdPers3
	.export	_mdPers4
	.export	_mdPersN
;* Input:
;* r0 mdP3* input
;* r1 mdP3* output
;* r2 N for mdPersN

_mdPers:
       {
	ld_s	(r0),v2[0]			;Fetch X
	add	#8,r0				;Ptr Z
       }
       {
	ld_s	(r0),v1[0]			;Fetch Z
	sub	#4,r0				;Ptr Y
       }
       {
	ld_s	(r0),v2[1]			;Fetch Y
	add	#8,r1				;Ptr Destination Z
       }
	msb	v1[0],v1[1]			;sigbits of z
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	ld_s	(_MPT_ScaleY),v2[3]		;ScaleY
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
`CannotRecip0:
	copy	v1[0],v1[3]			;Z
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
	ld_s	(_MPT_OffX),v0[2]		;Offset X
       {
	st_s	v1[0],(r1)			;Store Z
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
	ld_s	(_MPT_OffY),v0[3]		;Offset Y
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
	sub	#8,r1				;Ptr Destination X
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	#iPrec-xyzsft,v1[1]	   	;result Fracbits
       {
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
	copy	v1[0],v1[2]			;Backup 1/Z
       }
	mul	v2[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
	mul	v1[0],v2[0],>>#sclsft+xyzsft-subres,v2[0]	;(X*ScaleX)/Z
       {
	mul	v1[2],v2[1],>>#sclsft+xyzsft-subres,v2[1]	;(Y*ScaleY)/Z
       }
       {
	rts					;Done
	add	v0[2],v2[0]			;((X*ScaleX)/Z) + OffsetX
       }
       {
	st_s	v2[0],(r1)			;Store Transformed X
	addm	v0[3],v2[1]			;((Y*ScaleY)/Z) + OffsetY
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v2[1],(r1)			;Store Transformed X
	sub	r0,r0				;Clear Return Value
       }
       ;----------------------------------------;rts


_mdPers3:
       {
	bra	PersCore			;Execute
	mv_s	#3,r2				;#of vertices to transform
	add	#8,r0				;Ptr Z
       }
	ld_s	(r0),v1[0]			;Read Z
	add	#8,r1				;Ptr Destination Z
       ;----------------------------------------;bra PersCore
_mdPers4:
       {
	bra	PersCore			;Execute
	mv_s	#4,r2				;#of vertices to transform
	add	#8,r0				;Ptr Z
       }
	ld_s	(r0),v1[0]			;Read Z
	add	#8,r1				;Ptr Destination Z
       ;----------------------------------------;bra PersCore
_mdPersN:
	add	#8,r0				;Ptr Z
	ld_s	(r0),v1[0]			;Read Z
	add	#8,r1				;Ptr Destination Z

PersCore:
       {
	ld_s	(rc0),r3			;Backup rc0
	msb	v1[0],v1[1]			;sigbits of z
       }
       {
	st_s	r2,(rc0)			;Set #of Vertices to Transform
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	push	v3				;Backup v3
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
	sub	#8,r0				;Ptr X
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
	ld_v	(_MPT_ScaleX),v3		;Fetch ScaleXY OffXY
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)

PLoop:
       {
	st_s	v1[0],(r1)			;Store Z
	add	#iPrec-xyzsft,v1[1],v2[1]   	;result Fracbits
       }
       {
	ld_s	(r0),v2[2]			;Fetch X
	add	#4,r0				;Increase Ptr
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	ld_s	(r0),v2[3]			;Fetch Y
	add	#4+12,r0			;Increase Ptr Next Z
       }
       {
	sub	v1[0],#fix(2,iPrec),v2[0]	;refine
	ld_s	(r0),v1[0]			;Read Z
       }
       {
	sub	#8,r0				;Ptr X
	mul	v1[2],v2[0],>>#iPrec,v2[0]	;result 1/Z
       }
	msb	v1[0],v1[1]			;sigbits of z
       {
	mv_s	v2[0],r2			;Backup 1/Z
	mul	v3[0],v2[0],>>v2[1],v2[0]	;ScaleX/Z as 12.20
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	mul	v3[1],r2,>>v2[1],r2		;ScaleY/Z as 12.20
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	mul	v2[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(X*ScaleX)/Z
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
	mul	r2,v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Y*ScaleY)/Z
	add	v3[2],v2[2]			;((X*ScaleX)/Z) + OffsetX
	dec	rc0				;Decrement Loop Counter
       }
       {
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
	sub	#8,r1				;Ptr X
       }
       {
	bra	c0ne,PLoop			;Loop
	st_s	v2[2],(r1)			;Store Transformed x
	add	#4,r1				;Increase ptr
       }
       {
	addm	v3[3],v2[3]			;((Y*ScaleY)/Z) + OffsetY
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	st_s	v2[3],(r1)			;Store Transformed y
	add	#4+12,r1 			;Ptr Next Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       ;----------------------------------------;bra c0ne,PLoop

       {
	st_s	r3,(rc0)			;Restore rc0
	rts					;Done
       }
	pop	v3				;Restore v3
	sub	r0,r0				;Clear Return Value
       ;----------------------------------------;rts


;* _mdRotTransPers
	.export	_mdRotTransPers
	.export	_mdRotTransPers3
	.export	_mdRotTransPers4
	.export	_mdRotTransPersN
;* Input:
;* r0 mdP3* input
;* r1 mdP3* output
;* r2 N for mdRotTransPersN

_mdRotTransPers:
	push	v3				;Backup v3
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
	add	#8,r1,r3			;Ptr Destination Z
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
	as	v1[2],v1[0],v1[2]		;IndexOffset
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	st_s	v1[0],(r3)			;Store Z
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v3[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v2[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1] 	  	;result Fracbits
       }
       {
	pop	v3				;Restore v3
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
	mul	v2[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
       {
	mul	r2,v1[0],>>#sclsft+xyzsft-subres,v1[0]	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),r2			;OffsetX
       }
       {
	ld_s	(_MPT_OffY),r3			;OffsetY
	mul	r3,v1[2],>>#sclsft+xyzsft-subres,v1[2]	;(Y*ScaleY)/Z
       }
       {
	rts					;Done
	add	r2,v1[0]			;((X*ScaleX)/Z) + OffsetX
       }
       {
	st_s	v1[0],(r1)			;Store Transformed X
	addm	r3,v1[2]			;((Y*ScaleY)/Z) + OffsetY
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[2],(r1)			;Store Transformed Y
	sub	r0,r0				;Clear Return Value
       }
       ;----------------------------------------;rts


_mdRotTransPers3:
       {
	bra	RotTransPersCore		;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#3,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransPersCore
_mdRotTransPers4:
       {
	bra	RotTransPersCore		;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#4,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransPersCore
_mdRotTransPersN:
       {
	bra	RotTransPersCore		;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	r2,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransPersCore

RotTransPersCore:
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
       }
`RTPLoop:
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
	as	v1[2],v1[0],v1[2]		;IndexOffset
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	add	#8,r1				;Ptr Destination Z
       {
	st_s	v1[0],(r1)			;Store Transformed Z
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	add	v3[0],v3[3],v1[3]		;Ty + r10*X
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v3[1],v1[3]			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],v1[3]			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v2[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1] 	  	;result Fracbits
       }
       {
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	mul	v2[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
	ld_s	(_MPT_OffY),v1[1]		;OffsetY
	sub	#8,r1				;Ptr X
       }
       {
	mul	r2,v1[0],>>#sclsft+xyzsft-subres,v1[0]	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),r2			;OffsetX
       }
       {
	ld_s	(r0),v2[2]			;Read Z
	mul	v1[3],v1[2],>>#sclsft+xyzsft-subres,v1[2]	;(Y*ScaleY)/Z
	dec	rc0				;Decrement Loop Counter
       }
       {
	bra	c0ne,`RTPLoop			;bra c0ne,`RTPLoop
	add	r2,v1[0]			;((X*ScaleX)/Z) + OffsetX
       }
       {
	st_s	v1[0],(r1)			;Store Transformed X
	addm	v1[1],v1[2]			;((Y*ScaleY)/Z) + OffsetY
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[2],(r1)			;Store Transformed Y
	add	#8,r1				;Increase Ptr
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
       }
       ;----------------------------------------;bra c0ne,`RTPLoop
       {
	st_s	r3,(rc0)			;Restore rc0
	rts					;Done
       }
	pop	v3				;Restore v3
	sub	r0,r0				;Clear Return Value
       ;----------------------------------------;rts


;* _mdRotTransClip
	.export	_mdRotTransClip
	.export	_mdRotTransClip3
	.export	_mdRotTransClip4
	.export	_mdRotTransClipN
	.export	_mdRotTransClipAABB

;* Input:
;* r0 mdP3* input
;* r1 mdP3* output
;* r2 N for mdRotTransClipN

_mdRotTransClip:
	push	v3				;Backup v3
       {
	ld_s	(r0),v1[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[2]			;Read Z
	add	#4,r1,r2			;Ptr y'
       }
	add	#8,r1,r3			;Ptr z'
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
       {
	add	v2[3],v2[0]			;Tx + r00*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
       }
       {
	add	v2[1],v2[0]			;Tx + r00*X + r01*Y
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
       }
       {
	add	v2[2],v2[0],r0			;Tx + r00*X + r01*Y + r02*Z
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	add	v3[3],v3[0]			;Ty + r10*X
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
       }
       {
	st_s	r0,(r1)				;Store x'
	add	v3[1],v3[0]			;Ty + r10*X + r11*Y
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r20*X
       }
       {
	add	v3[2],v3[0]			;Ty + r10*X + r11*Y + r12*Z
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r21*Y
       }
       {
	st_s	v3[0],(r2)			;Store y'
	add	v2[3],v2[0]			;Tz + r20*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r22*Z
       }
       {
	add	v2[1],v2[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_ScaleX),v1[0]		;Fetch XScale
       }
       {
	add	v2[2],v2[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_ScaleY),v1[1]		;Fetch YScale
       }
       {
	ld_s	(_MPT_OffX),v1[2]		;XClip
	mul	r0,v1[0],>>#sclsft+xyzsft-subres,v1[0] 	;ScaleX * x'
	sub	r0,r0				;Clear Return Value
       }
       {
	ld_s	(_MPT_OffY),v1[3]		;YClip
	mul	v3[0],v1[1],>>#sclsft+xyzsft-subres,v1[1] 	;ScaleY * y'
       }
       {
	ld_s	(_MPT_FarZ),r2			;Fetch FarZ
	mul	v2[0],v1[2],>>#xyzsft,v1[2] 	;XClip * z'
       }
       {
	st_s	v2[0],(r3)			;Store z'
	mul	v2[0],v1[3],>>#xyzsft,v1[3]	;YClip * z'
       }
       {
	ld_s	(_MPT_NearZ),r3			;Fetch NearZ
	sub	v2[0],r2			;Far Clip ?
       }
       {
	pop	v3				;Restore v3
	subm	v1[0],v1[2]			;v1[2] XClip*z' - ScaleX*x'
	add	v1[2],v1[0]			;v1[0] ScaleX*x'-(-XClip*z')
       }
       {
	subm	v1[1],v1[3]			;v1[2] YClip*z' - ScaleY*y'
	add	v1[3],v1[1]			;v1[0] ScaleY*y'-(-YClip*z')
       }
       {
	subm	r3,v2[0]			;Near Clip ?
	abs	v1[0]				;Set C if Left XClip
       }
	addwc	r0,r0				;Set Left XClip Bit
	abs	v1[2]				;Set C if Right XClip
	addwc	r0,r0				;Set Right XClip Bit
	abs	v1[1]				;Set C if Top YClip
	addwc	r0,r0				;Set Top YClip Bit
	abs	v1[3]				;Set C if Bottom YClip
	addwc	r0,r0				;Set Bottom YClip Bit
	abs	r2				;Set C if FarClip
       {
	rts					;Done
	addwc	r0,r0				;Set FarClip Bit
       }
	abs	v2[0]				;Set C if NearClip
	addwc	r0,r0				;Set FarClip Bit
       ;----------------------------------------;rts


_mdRotTransClip4:
       {
	bra	RotTransClipCore 		;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#4,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransCore

_mdRotTransClip3:
       {
	bra	RotTransClipCore 		;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#3,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransCore

_mdRotTransClipN:
	ld_s	(rc0),r3			;Backup rc0
	st_s	r2,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3

RotTransClipCore:
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
       {
	push	v4				;Backup v4
	copy	r0,v1[3]			;Ptr
       }
       {
	ld_s	(v1[3]),v1[0]			;Read X
	add	#4,v1[3] 			;Increase Ptr
	subm	v4[0],v4[0]			;Clear v4[0]
       }
       {
	ld_s	(v1[3]),v1[1]			;Read Y
	add	#4,v1[3]			;Increase Ptr
	subm	v4[1],v4[1]			;Clear v4[1]
       }
       {
	ld_s	(v1[3]),v1[2]			;Read Z
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
	sub	#1,v4[1]			;v4[1] All 1s
       }

`RTCLoop:
       {
	add	v2[3],v2[0]			;Tx + r00*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
       }
       {
	add	v2[1],v2[0]			;Tx + r00*X + r01*Y
       }
       {
	add	v2[2],v2[0],r2			;Tx + r00*X + r01*Y + r02*Z
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
       }
       {
	add	#4,v1[3]			;Increase Ptr
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	add	v3[3],v3[0]			;Ty + r10*X
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
       }
       {
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r20*X
	ld_s	(v1[3]),v1[0]			;Read X
	add	#4,v1[3] 			;Increase Ptr
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r21*Y
	ld_s	(v1[3]),v1[1]			;Read Y
	add	#4,v1[3]			;Increase Ptr
       }
       {
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r22*Z
	ld_s	(v1[3]),v1[2]			;Read Z
	add	v3[1],v3[0]			;Ty + r10*X + r11*Y
       }
       {
	add	v3[2],v3[0]			;Ty + r10*X + r11*Y + r12*Z
	dec	rc0				;Decrement Counter
       }
       {
	add	v2[3],v2[0],v3[1]		;Tz + r20*X
	addm	v2[1],v2[2],v3[2]		;r21*Y + r22*Z
	ld_v	(_MPT_ScaleX),v2		;v2[0] ScaleX v2[1] ScaleY
       }                                        ;v2[2] ClipX   v2[3] ClipY
       {
	st_s	r2,(r1)				;Store x'
	add	#4,r1				;Increase Ptr
	addm	v3[2],v3[1]			;Tz + r20*X + r21*Y + r22*Z
       }
       {
	st_s	v3[0],(r1) 			;Store y'
	add	#4,r1				;Increase Ptr
	mul	r2,v2[0],>>#sclsft+xyzsft-subres,v2[0]	 ;v2[0] ScaleX*x'
       }
       {
	st_s	v3[1],(r1) 			;Store z'
	add	#4,r1				;Increase Ptr
	mul	v2[1],v3[0],>>#sclsft+xyzsft-subres,v3[0] ;v3[0] ScaleY*y'
       }
       {
	mul	v3[1],v2[2],>>#xyzsft,v2[2]	;XClip*z'
	ld_s	(_MPT_FarZ),v3[2]		;v3[2] FarZ
	sub	r2,r2				;Clear ClipCode
       }
       {
	mul	v3[1],v2[3],>>#xyzsft,v2[3]	;YClip*z'
	ld_s	(_MPT_NearZ),v3[3]		;v3[3] NearZ
	copy	v2[0],v2[1]			;v2[1] ScaleX*x'
       }
	add	v2[2],v2[1]			;v2[1] ScaleX*x' - (-XClip*z')
       {
	subm	v2[0],v2[2]			;v2[2] XClip*z' - ScaleX*x'
	abs	v2[1]				;Set C if Left XClip
       }
       {
	subm	v3[1],v3[2]			;FarZ - z'
	addwc	r2,r2				;Set Left XClip Bit
       }
       {
	subm	v3[3],v3[1]			;z' - NearZ
	abs	v2[2]				;Set C if Right XClip
       }
       {
	mv_s	v3[0],v3[3]			;v3[3] v3[0]
	addm	v2[3],v3[0]			;v3[0] ScaleY*y' - (-YClip*z')
	addwc	r2,r2				;Set Left XClip Bit
       }
       {
	subm	v3[3],v2[3]			;v2[3] YClip*z' - ScaleY*y'
	abs	v3[0]				;Set C if Top YClip
       }
	addwc	r2,r2				;Set Top YClip Bit
	abs	v2[3]				;Set C if Bottom YClip
       {
	addwc	r2,r2				;Set Top YClip Bit
       }
	abs	v3[2]				;Set C if FarClip
	addwc	r2,r2				;Set FarClip Bit
       {
	abs	v3[1]				;Set C if NearClip
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
       }
       {
	bra	c0ne,`RTCLoop			;Loop
	addwc	r2,r2				;Set NearClip Bit
       }
       {
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
	or	r2,v4[0]			;Logical Or
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
	and	r2,v4[1]			;Logical And
       }
       ;----------------------------------------;bra c0ne,`RTCLoop
       {
	st_s	r3,(rc0)			;Restore rc0
	copy	v4[1],r0			;Logical And return value
       }
       {
	rts					;Done
	or	v4[0],>>#-6,r0			;Logical Or return value
	pop	v4				;Restore v4
       }
	pop	v3				;Restore v3
	nop
       ;----------------------------------------;rts


;* _mdCheckVisAABB
	.export	_mdCheckVisAABB
;* Input:
;* r0 mdAABB* input
;* Output:
;* 0 if not visible
;* Average Z if visible
_mdCheckVisAABB:
       {
	push	v3				;Backup v3
	and	#-16,csp,v1[3]			;Ptr Vertices AABB on stack
       }
       {
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
	sub	#2*16,v1[3]	  		;Ptr 1st vertex (leave 16 open)
	subm	r3,r3				;Clear r1
       }
       {
	add	#4,r3				;cte 4
       }
       {
	ld_s	(r0),v2[0]			;Read minx
	add	r3,r0				;Increase ptr
       }
       {
	ld_s	(r0),v2[1]			;Read miny
	add	r3,r0				;Increase ptr
       }
       {
	ld_s	(r0),v2[2]			;Read minz
	addm	r3,r0				;Increase ptr
	asr	#1,v2[0],r1			;minx/2
       }
       {
	ld_s	(r0),v1[0]			;Read maxx
	addm	r3,r0				;Increase ptr
	asr	#1,v2[1],r2			;miny/2
       }
       {
	ld_s	(r0),v1[1]			;Read maxy
	addm	r3,r0				;Increase ptr
	asr	#1,v2[2],r3			;minz/2
       }
       {
	ld_s	(r0),v1[2]			;Read maxz
	add	v1[0],>>#1,r1			;(minx+maxx)/2
       }
       {
	mul	v3[0],r1,>>#tmsft,r1		;r20*X
	add	v1[1],>>#1,r2			;(miny+maxy)/2
       }
       {
	mul	v3[1],r2,>>#tmsft,r2		;r21*Y
	add	v1[2],>>#1,r3			;(minz+maxz)/2
       }
       {
	mul	v3[2],r3,>>#tmsft,r3		;r22*Z
	add	v3[3],r1			;Tz+r20*X
	mv_v	v2,v3				;min min min
       }
       {
	add	r2,r1				;Tz+r20*X+r21*Y
	mv_s	#16,r2				;cte 16
       }
       {
	st_v	v2,(v1[3])			;Store min min min
	subm	r2,v1[3]			;Decrease ptr
	copy	v1[2],v3[2]			;min min max
       }
       {
	st_v	v3,(v1[3])			;store min min max
	subm	r2,v1[3]			;Decrease ptr
	copy	v1[1],v3[1]			;min max max
       }
       {
	st_v	v3,(v1[3])			;store min max max
	subm	r2,v1[3]			;Decrease ptr
	copy	v2[2],v3[2]			;min max min
       }
       {
	st_v	v3,(v1[3])			;store min max min
	subm	r2,v1[3]			;Decrease ptr
	copy	v1[0],v3[0]			;max max min
       }
       {
	st_v	v3,(v1[3])			;store max max min
	subm	r2,v1[3]			;Decrease ptr
	copy	v2[1],v3[1]			;max min min
       }
       {
	st_v	v3,(v1[3])			;store max min min
	subm	r2,v1[3]			;Decrease ptr
	copy	v1[2],v3[2]			;max min max
       }
       {
	st_v	v3,(v1[3])			;store max min max
	subm	r0,r0				;Clear r0
	add	r3,r1  				;AverageZ = Tz+r20*X+r21*Y+R22*Z
       }
       {
	bra	ne,`AABBLoop			;AverageZ is nonzero, so no fix
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	sub	#1,r0				;r0 -1
       }
       {
	ld_s	(rc0),r3			;Backup rc0
	sub	r2,r2				;Clear r2
       }
       {
	st_s	#8,(rc0)			;Set #of Vertices to Transform
	sub	#1,r2				;Logical And & set Carry
       }
       ;----------------------------------------;bra ne,`AABBLoop
	subm	r2,r1				;Average Z = 0-(-1) = 1

`AABBLoop:
       {
	addwc	r2,r2				;Set NearClip Bit
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	and	r2,r0				;Logical And
       }
       {
	bra	eq,AABBTrivAccept,nop		;Trivial Accept (Point is in frustum)
	add	v2[3],v2[0]			;Tx + r00*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
       }
       {
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
	add	v2[1],v2[0]			;Tx + r00*X + r01*Y
       }
       {
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	add	v2[2],v2[0],r2			;Tx + r00*X + r01*Y + r02*Z
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v3[3],v3[0]			;Ty + r10*X
       }
       {
	mul	v2[0],v1[0],>>#tmsft,v1[0]	;r20*X
	add	v3[1],v3[0]			;Ty + r10*X + r11*Y
       }
       {
	mul	v2[1],v1[1],>>#tmsft,v1[1]	;r21*Y
	add	v3[2],v3[0]			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	mul	v2[2],v1[2],>>#tmsft,v1[2]	;r22*Z
	add	v1[0],v2[3],v3[1]   		;Tz + r20*X
	ld_v	(_MPT_ScaleX),v2		;v2[0] ScaleX v2[1] ScaleY
       }                                        ;v2[2] ClipX   v2[3] ClipY
	add	v1[1],v3[1]			;Tz + r20*x + r21*Y
       {
	add	v1[2],v3[1] 			;Tz + r20*X + r21*Y + r22*Z
	mul	r2,v2[0],>>#sclsft+xyzsft-subres,v2[0]	 ;v2[0] ScaleX*x'
       }
       {
	add	#16,v1[3],r2			;Increase ptr
	ld_v	(v1[3]),v1			;Read xyz
	mul	v2[1],v3[0],>>#sclsft+xyzsft-subres,v3[0] ;v3[0] ScaleY*y'
       }
       {
	mul	v3[1],v2[2],>>#xyzsft,v2[2]	;XClip*z'
	copy	v2[0],v2[1]			;v2[1] ScaleX*x'
       }
       {
	mul	v3[1],v2[3],>>#xyzsft,v2[3]	;YClip*z'
	mv_s	r2,v1[3]			;Restore ptr
	sub	r2,r2				;Clear r2
       }
       {
	ld_s	(_MPT_FarZ),v3[2]		;v3[2] FarZ
	add	v2[2],v2[1]			;v2[1] ScaleX*x' - (-XClip*z')
       }
       {
	ld_s	(_MPT_NearZ),v3[3]		;v3[3] NearZ
	subm	v2[0],v2[2]			;v2[2] XClip*z' - ScaleX*x'
	abs	v2[1]				;Set C if Left XClip
       }
       {
	addwc	r2,r2				;Set Left XClip Bit
	subm	v3[1],v3[2]			;FarZ - z'
       }
       {
	subm	v3[3],v3[1]			;z' - NearZ
	abs	v2[2]				;Set C if Right XClip
       }
       {
	mv_s	v3[0],v3[3]			;v3[3] v3[0]
	addm	v2[3],v3[0]			;v3[0] ScaleY*y' - (-YClip*z')
	addwc	r2,r2				;Set Left XClip Bit
       }
       {
	subm	v3[3],v2[3]			;v2[3] YClip*z' - ScaleY*y'
	abs	v3[0]				;Set C if Top YClip
       }
	addwc	r2,r2				;Set Top YClip Bit
	abs	v2[3]				;Set C if Bottom YClip
       {
	addwc	r2,r2				;Set Top YClip Bit
	dec	rc0				;Decrement root counter
       }
       {
	bra	c0ne,`AABBLoop
	abs	v3[2]				;Set C if FarClip
       }
       {
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	addwc	r2,r2				;Set FarClip Bit
       }
       {
	abs	v3[1]				;Set C if NearClip
       }
       ;----------------------------------------;bra c0ne,`RTCLoop
	addwc	r2,r2				;Set NearClip Bit
	and	r2,r0				;Logical And
       {
	rts	ne				;Quit if invisible
	st_s	r3,(rc0)			;Restore rc0
       }
AABBTrivAccept:
       {
	rts					;Done
	pop	v3				;Restore v3
       }
	sub	r0,r0				;Clear return Z
       ;----------------------------------------;rts ne
       {
	st_s	r3,(rc0)			;Restore rc0 (for triv accept)
	copy	r1,r0				;Insert average Z
       }
       ;----------------------------------------;rts


;* _mdCheckVisNearZAABB
	.export	_mdCheckVisNearZAABB
;* Input:
;* r0 mdAABB* input
;* Output:
;* 0 if not visible
;* Average Z if visible
_mdCheckVisNearZAABB:
       {
	push	v3				;Backup v3
	and	#-16,csp,v1[3]			;Ptr Vertices AABB on stack
       }
       {
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
	sub	#2*16,v1[3]	  		;Ptr 1st vertex (leave 16 open)
	subm	r3,r3				;Clear r1
       }
       {
	add	#4,r3				;cte 4
       }
       {
	ld_s	(r0),v2[0]			;Read minx
	add	r3,r0				;Increase ptr
       }
       {
	ld_s	(r0),v2[1]			;Read miny
	add	r3,r0				;Increase ptr
       }
       {
	ld_s	(r0),v2[2]			;Read minz
	addm	r3,r0				;Increase ptr
	asr	#1,v2[0],r1			;minx/2
       }
       {
	ld_s	(r0),v1[0]			;Read maxx
	addm	r3,r0				;Increase ptr
	asr	#1,v2[1],r2			;miny/2
       }
       {
	ld_s	(r0),v1[1]			;Read maxy
	addm	r3,r0				;Increase ptr
	asr	#1,v2[2],r3			;minz/2
       }
       {
	ld_s	(r0),v1[2]			;Read maxz
	add	v1[0],>>#1,r1			;(minx+maxx)/2
       }
       {
	mul	v3[0],r1,>>#tmsft,r1		;r20*X
	add	v1[1],>>#1,r2			;(miny+maxy)/2
       }
       {
	mul	v3[1],r2,>>#tmsft,r2		;r21*Y
	add	v1[2],>>#1,r3			;(minz+maxz)/2
       }
       {
	mul	v3[2],r3,>>#tmsft,r3		;r22*Z
	add	v3[3],r1			;Tz+r20*X
	mv_v	v2,v3				;min min min
       }
       {
	add	r2,r1				;Tz+r20*X+r21*Y
	mv_s	#16,r2				;cte 16
       }
       {
	st_v	v2,(v1[3])			;Store min min min
	subm	r2,v1[3]			;Decrease ptr
	copy	v1[2],v3[2]			;min min max
       }
       {
	st_v	v3,(v1[3])			;store min min max
	subm	r2,v1[3]			;Decrease ptr
	copy	v1[1],v3[1]			;min max max
       }
       {
	st_v	v3,(v1[3])			;store min max max
	subm	r2,v1[3]			;Decrease ptr
	copy	v2[2],v3[2]			;min max min
       }
       {
	st_v	v3,(v1[3])			;store min max min
	subm	r2,v1[3]			;Decrease ptr
	copy	v1[0],v3[0]			;max max min
       }
       {
	st_v	v3,(v1[3])			;store max max min
	subm	r2,v1[3]			;Decrease ptr
	copy	v2[1],v3[1]			;max min min
       }
       {
	st_v	v3,(v1[3])			;store max min min
	subm	r2,v1[3]			;Decrease ptr
	copy	v1[2],v3[2]			;max min max
       }
       {
	st_v	v3,(v1[3])			;store max min max
	subm	r0,r0				;Clear r0
	add	r3,r1  				;AverageZ = Tz+r20*X+r21*Y+R22*Z
       }
       {
	bra	ne,`AABBStartLoop		;AverageZ is nonzero, so no fix
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	sub	#1,r0				;r0 -1
       }
       {
	ld_s	(rc0),r3			;Backup rc0
       }
       {
	st_s	#8,(rc0)			;Set #of Vertices to Transform
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
       }
       ;----------------------------------------;bra ne,`AABBStartLoop
	mv_s	#1,r1				;Average Z = 0-(-1) = 1


`AABBStartLoop:
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
       }
`AABBLoop:
       {
	add	v2[3],v2[0]			;Tx + r00*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
       }
       {
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
	add	v2[1],v2[0]			;Tx + r00*X + r01*Y
       }
       {
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	add	v2[2],v2[0],r2			;Tx + r00*X + r01*Y + r02*Z
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v3[3],v3[0]			;Ty + r10*X
       }
       {
	mul	v2[0],v1[0],>>#tmsft,v1[0]	;r20*X
	add	v3[1],v3[0]			;Ty + r10*X + r11*Y
       }
       {
	mul	v2[1],v1[1],>>#tmsft,v1[1]	;r21*Y
	add	v3[2],v3[0]			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	mul	v2[2],v1[2],>>#tmsft,v1[2]	;r22*Z
	add	v1[0],v2[3],v3[1]   		;Tz + r20*X
	ld_v	(_MPT_ScaleX),v2		;v2[0] ScaleX v2[1] ScaleY
       }                                        ;v2[2] ClipX   v2[3] ClipY
	add	v1[1],v3[1]			;Tz + r20*x + r21*Y
       {
	add	v1[2],v3[1] 			;Tz + r20*X + r21*Y + r22*Z
	mul	r2,v2[0],>>#sclsft+xyzsft-subres,v2[0]	 ;v2[0] ScaleX*x'
       }
       {
	add	#16,v1[3],r2			;Increase ptr
	ld_v	(v1[3]),v1			;Read xyz
	mul	v2[1],v3[0],>>#sclsft+xyzsft-subres,v3[0] ;v3[0] ScaleY*y'
       }
       {
	mul	v3[1],v2[2],>>#xyzsft,v2[2]	;XClip*z'
	copy	v2[0],v2[1]			;v2[1] ScaleX*x'
       }
       {
	mul	v3[1],v2[3],>>#xyzsft,v2[3]	;YClip*z'
	mv_s	r2,v1[3]			;Restore ptr
	sub	r2,r2				;Clear r2
       }
       {
	ld_s	(_MPT_FarZ),v3[2]		;v3[2] FarZ
	add	v2[2],v2[1]			;v2[1] ScaleX*x' - (-XClip*z')
       }
       {
	ld_s	(_MPT_NearZ),v3[3]		;v3[3] NearZ
	subm	v2[0],v2[2]			;v2[2] XClip*z' - ScaleX*x'
	abs	v2[1]				;Set C if Left XClip
       }
       {
	addwc	r2,r2				;Set Left XClip Bit
	subm	v3[1],v3[2]			;FarZ - z'
       }
       {
	subm	v3[3],v3[1]			;z' - NearZ
	abs	v2[2]				;Set C if Right XClip
       }
       {
	mv_s	v3[0],v3[3]			;v3[3] v3[0]
	addm	v2[3],v3[0]			;v3[0] ScaleY*y' - (-YClip*z')
	addwc	r2,r2				;Set Left XClip Bit
       }
       {
	subm	v3[3],v2[3]			;v2[3] YClip*z' - ScaleY*y'
	abs	v3[0]				;Set C if Top YClip
       }
	addwc	r2,r2				;Set Top YClip Bit
	abs	v2[3]				;Set C if Bottom YClip
       {
	addwc	r2,r2				;Set Top YClip Bit
       }
       {
	abs	v3[1]				;Set C if NearClip
       }
       {
	bra	cs,`NearZCrossed,nop		;NearZCrossed
	addwc	r2,r2				;Set NearClip Bit
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	dec	rc0				;Decrement root counter
       }
       ;----------------------------------------;bra cs,`NearZCrossed
       {
	bra	c0ne,`AABBLoop
	abs	v3[2]				;Set C if FarClip
       }
       {
	addwc	r2,r2				;Set FarClip Bit
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
	and	r2,r0				;Logical And
       }
       ;----------------------------------------;bra c0ne,`AABBLoop
`NearZCrossed:
       {
	rts	ne				;Quit if invisible
	st_s	r3,(rc0)			;Restore rc0
       }
       {
	rts					;Done
	pop	v3				;Restore v3
       }
	sub	r0,r0				;Clear return Z
       ;----------------------------------------;rts ne
	copy	r1,r0				;Insert average Z
       ;----------------------------------------;rts


;* _mdPersCull3
	.export	_mdPersCull3
	.export	_mdPersCull4
;* Input:
;* r0 mdP3* input
;* r1 mdP3* output

_mdPersCull3:
       {
	bra	PersCullCore			;Execute
	mv_s	#3,r2				;#of vertices to transform
	add	#8,r0				;Ptr Z
       }
	ld_s	(r0),v1[0]			;Read Z
	add	#8,r1				;Ptr Destination Z
       ;----------------------------------------;bra PersCore
_mdPersCull4:
       {
	mv_s	#4,r2				;#of vertices to transform
	add	#8,r0				;Ptr Z
       }
	ld_s	(r0),v1[0]			;Read Z
	add	#8,r1				;Ptr Destination Z
       ;----------------------------------------;bra PersCore

PersCullCore:
       {
	ld_s	(rc0),r3			;Backup rc0
	msb	v1[0],v1[1]			;sigbits of z
       }
       {
	st_s	r2,(rc0)			;Set #of Vertices to Transform
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	push	v3				;Backup v3
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
	sub	#8,r0				;Ptr X
       {
	or	r2,>>#-16,r3			;Insert #of Vertices
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	ld_v	(_MPT_ScaleX),v3		;Fetch ScaleXY OffXY
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)

PCLoop:
       {
	st_s	v1[0],(r1)			;Store Z
	add	#iPrec-xyzsft,v1[1],v2[1]   	;result Fracbits
       }
       {
	ld_s	(r0),v2[2]			;Fetch X
	add	#4,r0				;Increase Ptr
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	ld_s	(r0),v2[3]			;Fetch Y
	add	#4+12,r0			;Increase Ptr Next Z
       }
       {
	sub	v1[0],#fix(2,iPrec),v2[0]	;refine
	ld_s	(r0),v1[0]			;Read Z
       }
       {
	sub	#8,r0				;Ptr X
	mul	v1[2],v2[0],>>#iPrec,v2[0]	;result 1/Z
       }
	msb	v1[0],v1[1]			;sigbits of z
       {
	mv_s	v2[0],r2			;Backup 1/Z
	mul	v3[0],v2[0],>>v2[1],v2[0]	;ScaleX/Z as 12.20
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	mul	v3[1],r2,>>v2[1],r2		;ScaleY/Z as 12.20
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	mul	v2[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(X*ScaleX)/Z
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
	mul	r2,v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Y*ScaleY)/Z
	add	v3[2],v2[2]			;((X*ScaleX)/Z) + OffsetX
	dec	rc0				;Decrement Loop Counter
       }
       {
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
	sub	#8,r1				;Ptr X
       }
       {
	bra	c0ne,PCLoop			;Loop
	st_s	v2[2],(r1)			;Store Transformed x
	add	#4,r1				;Increase ptr
       }
       {
	addm	v3[3],v2[3]			;((Y*ScaleY)/Z) + OffsetY
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	st_s	v2[3],(r1)			;Store Transformed y
	add	#4+12,r1 			;Ptr Next Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       ;----------------------------------------;bra c0ne,PCLoop
       {
	pop	v3				;Restore v3
	btst	#16,r3				;Odd #of Vertices ?
       }
       {
	bra	ne,_mdCull3			;Yap, Cull Triangle
	sub	#(12*3)+(8),r1,r0		;Ptr 1st Vertex 3
       }
       {
	bra	_mdCull4			;Cull Quadrangle
	bits	#16-1,>>#0,r3			;Extract old rc0
       }
	st_s	r3,(rc0)			;Restore rc0
       ;----------------------------------------;bra ne,_mdCull3
	sub	#12*1,r0			;Ptr 1st Vertex 4
       ;----------------------------------------;bra _mdCull4


;* _mdRotTransPersCull3
	.export	_mdRotTransPersCull3
	.export	_mdRotTransPersCull4
;* Input:
;* r0 mdP3* input
;* r1 mdP3* output

_mdRotTransPersCull3:
       {
	bra	RotTransPersCullCore		;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#3,(rc0)			;Set #of Vertices to Transform
       {
	push	v3				;Backup v3
	bset	#16,r3				;Insert Triangle Bit
       }
       ;----------------------------------------;bra RotTransPersCore
_mdRotTransPersCull4:
       {
	bra	RotTransPersCullCore		;Execute
	ld_s	(rc0),r3			;Backup rc0
       }
	st_s	#4,(rc0)			;Set #of Vertices to Transform
	push	v3				;Backup v3
       ;----------------------------------------;bra RotTransPersCore

RotTransPersCullCore:
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
       }
`RTPCLoop:
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
	as	v1[2],v1[0],v1[2]		;IndexOffset
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	add	#8,r1				;Ptr Destination Z
       {
	st_s	v1[0],(r1)			;Store Transformed Z
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	add	v3[0],v3[3],v1[3]		;Ty + r10*X
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v3[1],v1[3]			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],v1[3]			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v2[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1]	   	;result Fracbits
       }
       {
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	mul	v2[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
	ld_s	(_MPT_OffY),v1[1]		;OffsetY
	sub	#8,r1				;Ptr X
       }
       {
	mul	r2,v1[0],>>#sclsft+xyzsft-subres,v1[0]	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),r2			;OffsetX
       }
       {
	ld_s	(r0),v2[2]			;Read Z
	mul	v1[3],v1[2],>>#sclsft+xyzsft-subres,v1[2]	;(Y*ScaleY)/Z
	dec	rc0				;Decrement Loop Counter
       }
       {
	bra	c0ne,`RTPCLoop			;bra c0ne,`RTPLoop
	add	r2,v1[0]			;((X*ScaleX)/Z) + OffsetX
       }
       {
	st_s	v1[0],(r1)			;Store Transformed X
	addm	v1[1],v1[2]			;((Y*ScaleY)/Z) + OffsetY
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[2],(r1)			;Store Transformed Y
	add	#8,r1				;Increase Ptr
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
       }
       ;----------------------------------------;bra c0ne,`RTPLoop
       {
	pop	v3				;Restore v3
	btst	#16,r3				;Odd #of Vertices ?
       }
       {
	bra	ne,_mdCull3			;Yap, Cull Triangle
	sub	#12*3,r1,r0			;Ptr 1st Vertex 3
       }
       {
	bra	_mdCull4			;Cull Quadrangle
	bits	#16-1,>>#0,r3			;Extract old rc0
       }
	st_s	r3,(rc0)			;Restore rc0
       ;----------------------------------------;bra eq,_mdCull3
	sub	#12*1,r0			;Ptr 1st Vertex 4
       ;----------------------------------------;bra _mdCull4


;* _mdCull3
	.export	_mdCull3
	.export	_mdCull4
;* Input:
;* r0 mdP3* input

_mdCull3:
       {
	ld_s	(r0),v1[0]			;Read x0
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[0]			;Read y0
	add	#8,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[1]			;Read x1
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read y1
	add	#8,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[2]			;Read x2
	add	#4,r0				;Increase Ptr
	subm	v1[0],v1[1]			;v1[1] x1 - x0
       }
       {
	ld_s	(r0),v2[2]			;Read y2
	sub	v2[0],v2[1]			;v2[1] y1 - y0
       }
	sub	v1[0],v1[2]			;v1[2] x2 - x0
       {
	mul	v2[1],v1[2],>>#subres,v1[2]	;v2[2] (x2-x0)(y1-y0)
	sub	v2[0],v2[2]			;v2[2] y2 - y0
       }
	mul	v2[2],v1[1],>>#subres,v1[1]	;v2[1] (x1-x0)(y2-y0)
	sub	r0,r0				;Clear r0
       {
	rts					;Done
	sub	v1[1],v1[2]			;Calculate Signed Area
       }
	abs	v1[2]				;Set c if < (CW)
	addwc	r0,r0				;Set Bit if CW
       ;----------------------------------------;rts

_mdCull4:
       {
	ld_s	(r0),v1[0]			;Read x0
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[0]			;Read y0
	add	#8,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[1]			;Read x1
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read y1
	add	#8,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[2]			;Read x2
	add	#4,r0				;Increase Ptr
	subm	v1[0],v1[1],v0[2]		;v0[2] x1 - x0
       }
       {
	ld_s	(r0),v2[2]			;Read y2
	add	#8,r0				;Increase Ptr
	subm	v2[0],v2[1],v0[3] 		;v0[3] y1 - y0
       }
       {
	ld_s	(r0),v1[3]			;Read x3
	add	#4,r0				;Increase Ptr
	subm	v1[2],v1[0]			;v1[0] x0 - x2
       }
       {
	ld_s	(r0),v2[3]			;Read y3
	mul	v0[3],v1[0],>>#subres,v1[0]	;v1[2] -(x2-x0)(y1-y0)
	sub	v2[2],v2[0]			;v2[0] y0 - y2
       }
       {
	mul	v0[2],v2[0],>>#subres,v2[0]	;v0[2] -(x1-x0)(y2-y0)
	sub	v1[1],v1[2]			;v1[2] x2 - x1
       }
       {
	mv_s	#0,r0				;Clear r0
	sub	v1[1],v1[3]			;v1[3] x3-x1
       }
       {
	sub	v2[1],v2[3]			;v1[3] y3-y1
	subm	v1[0],v2[0]			;Signed Area
       }
       {
	mul	v1[2],v2[3],>>#subres,v2[3]	;v2[1] (x2-x1)(y3-y1)
	sub	v2[1],v2[2]			;v1[2] y2 - y1
       }
       {
	mul	v1[3],v2[2],>>#subres,v2[2]	;v2[2] (x3-x1)(y2-y1)
	abs	v2[0]				;Set c if <
       }
	addwc	r0,r0				;Set bit if CW
       {
	rts					;Done
	sub	v2[2],v2[3]			;Signed Area
       }
	abs	v2[3]				;Set c if <
	addwc	r0,r0				;Set bit if CW
       ;----------------------------------------;rts


;* _mdClip
	.export	_mdClip
;* Input:
;* r0 mdP3* input
_mdClip:
       {
	ld_v	(_MPT_ScaleX),v1		;v1[2] XClip/v1[3] YClip
	copy	r0,r2				;Ptr source
       }
       {
	ld_v	(_MPT_NearZ),v2			;v2[0] NearZ/v2[1] FarZ
	sub	r0,r0				;Clear return value
       }
       {
	add	v1[2],v1[2]			;XClip*2
       }
       {
	ld_s	(r2),v1[0]			;Fetch X
	add	#4,r2 				;Increase Ptr
	addm	v1[3],v1[3]			;YClip*2
       }
       {
	ld_s	(r2),v1[1]			;Fetch Y
	add	#4,r2 				;Increase Ptr
       }
       {
	subm	v1[0],v1[2],v2[2]		;Right Clip
	abs	v1[0]				;Set C if LeftClip
       }
	addwc	r0,r0				;Insert LeftClip
	abs	v2[2]				;Set C if RightClip
	addwc	r0,r0				;Insert RightClip
       {
	subm	v1[1],v1[3],v2[2]		;Bottom Clip
	abs	v1[1]				;Set C if TopClip
       }
       {
	ld_s	(r2),v1[0]			;Fetch Z
	addwc	r0,r0				;Insert TopClip
       }
	abs	v2[2]				;Set C if BottomClip
       {
	addwc	r0,r0				;Insert BottomClip
	subm	v1[0],v2[1],v2[2]		;Far Clip
       }
       {
	subm	v2[0],v1[0]			;Near Clip
	abs	v2[2]				;Set C if FarClip
       }
       {
	rts					;Done
	addwc	r0,r0				;Far Clip
       }
	abs	v1[0]				;Set C if NearClip
	addwc	r0,r0				;Near Clip
       ;----------------------------------------;rts


;* _mdClip3
	.export	_mdClip3
	.export	_mdClip4
	.export	_mdClipN
;* Input:
;* r0 mdP3* input
;* r1 N
;* Output:
;* r0 Clipcodes


_mdClip3:
       {
	ld_s	(rc0),r3			;Backup rc0
	bra	ClipCore
       }
       {
	ld_v	(_MPT_ScaleX),v1		;v1[2] XClip/v1[3] YClip
	sub	r1,r1				;Clear r1
       }
       {
	ld_v	(_MPT_NearZ),v2			;v2[0] NearZ/v2[1] FarZ
	add	#3,r1
       }
       ;----------------------------------------;bra ClipCore
_mdClip4:
       {
	ld_s	(rc0),r3			;Backup rc0
	bra	ClipCore
       }
       {
	ld_v	(_MPT_ScaleX),v1		;v1[2] XClip/v1[3] YClip
	sub	r1,r1				;Clear r1
       }
       {
	ld_v	(_MPT_NearZ),v2			;v2[0] NearZ/v2[1] FarZ
	add	#4,r1
       }
       ;----------------------------------------;bra ClipCore
_mdClipN:
	ld_s	(rc0),r3			;Backup rc0
	ld_v	(_MPT_ScaleX),v1		;v1[2] XClip/v1[3] YClip
	ld_v	(_MPT_NearZ),v2			;v2[0] NearZ/v2[1] FarZ
ClipCore:
       {
	st_s	r1,(rc0)			;Set Counter
	copy	r0,r2				;Ptr source
	subm	r0,r0				;Clear return value
       }
       {
	mv_s	#0,r1				;Logical Or
	sub	#1,r0				;Logical And
	addm	v1[2],v1[2]			;XClip*2
       }
       {
	ld_s	(r2),v1[0]			;Fetch X
	add	#4,r2 				;Increase Ptr
	addm	v1[3],v1[3]			;YClip*2
       }
       {
	ld_s	(r2),v1[1]			;Fetch Y
	add	#4,r2 				;Increase Ptr
	subm	v2[3],v2[3]			;Clear code
       }

`ClipLp:
       {
	subm	v1[0],v1[2],v2[2]		;Right Clip
	abs	v1[0]				;Set C if LeftClip
       }
	addwc	v2[3],v2[3]			;Insert LeftClip
	abs	v2[2]				;Set C if RightClip
	addwc	v2[3],v2[3]			;Insert RightClip
       {
	subm	v1[1],v1[3],v2[2]		;Bottom Clip
	abs	v1[1]				;Set C if TopClip
       }
       {
	ld_s	(r2),v1[0]			;Fetch Z
	addwc	v2[3],v2[3]			;Insert TopClip
       }
	abs	v2[2]				;Set C if BottomClip
       {
	addwc	v2[3],v2[3]			;Insert BottomClip
	subm	v1[0],v2[1],v2[2]		;Far Clip
       }
       {
	subm	v2[0],v1[0]			;Near Clip
	abs	v2[2]				;Set C if FarClip
       }
       {
	mv_s	#4,v2[2]			;Cte 4
	addwc	v2[3],v2[3]			;Far Clip
       }
       {
	abs	v1[0]				;Set C if NearClip
	addm	v2[2],r2			;Increase Ptr
	dec	rc0				;Decrement Counter
       }
       {
	bra	c0ne,`ClipLp
	addwc	v2[3],v2[3]			;Near Clip
	ld_s	(r2),v1[0]			;Fetch X
	addm	v2[2],r2			;Increase Ptr
       }
       {
	ld_s	(r2),v1[1]			;Fetch Y
	addm	v2[2],r2			;Increase Ptr
	or	v2[3],r1			;Insert logical or
	rts					;Done
       }
       {
	and	v2[3],r0			;Insert logical and
	subm	v2[3],v2[3]			;Clear code
       }
       ;----------------------------------------;bra c0ne,`ClipLp
       {
	or	r1,>>#-6,r0			;Insert logical or
	st_s	r3,(rc0)			;Restore rc0
       }
       ;----------------------------------------;rts


;* _mdRTPSBoard
	.export	_mdRTPSBoard
;* Input:
;* r0 mdSBoard* input
;* r1 mdScrRECT* output

_mdRTPSBoard:
	push	v3				;Backup v3
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
	add	#8,r1,r3			;Ptr Destination Z
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
	as	v1[2],v1[0],v1[2]		;IndexOffset
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
       {
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	nop					;Delay slot
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mv_s	v1[0],v2[0]			;Set Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	mul	v3[1],v2[1],>>#tmsft,v2[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
       {
	ld_s	(_MPT_TransformMatrix+4),v3[0]	;r01
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v2[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v2[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1] 	  	;result Fracbits
       }
       {
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	ld_s	(_MPT_OffY),v2[1]		;OffsetY
	mul	v2[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
       }
       {
	mul	v1[0],r2,>>#sclsft+xyzsft-subres,r2	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),v1[1]		;OffsetX
       }
       {
	mul	v1[2],r3,>>#sclsft+xyzsft-subres,r3	;(Y*ScaleY)/Z
	ld_s	(r0),v2[2]			;Read Width as 16.16
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[3]			;Read Height as 16.16
	add	v1[1],r2			;((X*ScaleX)/Z) + OffsetX
       }
       {
	mul	v1[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(Width*ScaleX)/Z
	add	v2[1],r3			;((Y*ScaleY)/Z) + OffsetY
       }
       {
	pop	v3				;Restore v3
	mul	v1[2],v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Height*ScaleY)/Z
       }
       {
	sub	v2[2],>>#1,r2			;Transformed X - Width/2
       }
       {
	st_s	r2,(r1)				;Set ScrRECT.x
	add	#4,r1				;Increase Ptr
	subm	v2[3],r3			;Transformed Y - Height
       }
       {
	st_s	r3,(r1)				;Set ScrRECT.y
	add	#4,r1				;Increase Ptr
       }
       {
	rts					;rts
	st_s	v2[0],(r1)			;Set ScrRECT.z
	add	#4,r1				;Increase Ptr
       }
       {
	or	v2[2],>>#-16,v2[3]		;ScrRECT.w | ScrRECT.h
       }
       {
	st_s	v2[3],(r1)			;Set ScrRECT WH
	sub	r0,r0				;Clear r0
       }
       ;----------------------------------------;rts
`CannotRecip0:
       {
	rts
	sub	r0,r0				;Invalid Return Code
       }
	pop	v3				;Restore v3
	sub	#1,r0				;(Cannot Recip)
       ;----------------------------------------;rts


;* _mdRTPDpqSBoard
	.export	_mdRTPDpqSBoard
;* Input:
;* r0 mdSBoard* input
;* r1 mdScrRECT* output
;* r2 mdCOLOR* rgba

_mdRTPDpqSBoard:
	push	v4				;Backup v4
       {
	push	v3				;Backup v3
	copy	r2,v4[2]			;Ptr RGBa
       }
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
	add	#8,r1,r3			;Ptr Destination Z
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	ld_s	(_MPT_FogNZ),v4[1]		;Read FogNZ
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	ld_s	(_MPT_FogMulZ),v4[0]		;Read FogMul
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
	sub	v4[1],v1[0],v4[1] 		;Z - FogNearZ
       }
       {
	bra	pl,`alphanotzero
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	ld_s	(v4[2]),v4[3]			;Read GRBa
       ;----------------------------------------;bra pl,`alphanotzero
	sub	v4[1],v4[1]			;Clear Alpha
`alphanotzero:
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mv_s	v1[0],v2[0]			;Set Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	mul	v3[1],v2[1],>>#tmsft,v2[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
       {
	ld_s	(_MPT_TransformMatrix+4),v3[0]	;r01
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v2[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v2[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1]	   	;result Fracbits
       }
       {
	mul	v1[0],v4[1],>>v1[1],v4[1]	;(Z - NearZ) / Z
	and	#0xFFFFFF00,v4[3]		;Isolate GRB
       }
       {
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	ld_s	(_MPT_OffY),v2[1]		;OffsetY
	mul	v2[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
       }
       {
	mul	v1[0],r2,>>#sclsft+xyzsft-subres,r2	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),v1[1]		;OffsetX
	copy	v4[2],v1[3]			;Backup Color Ptr
       }
       {
	mul	v1[2],r3,>>#sclsft+xyzsft-subres,r3	;(Y*ScaleY)/Z
	ld_s	(r0),v2[2]			;Read Width as 16.16
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[3]			;Read Height as 16.16
	add	v1[1],r2			;((X*ScaleX)/Z) + OffsetX
	mul	v4[1],v4[0],>>#vecsft*2,v4[0]	;((Z-NearZ)/Z)*FogMul
       }
       {
	mul	v1[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(Width*ScaleX)/Z
	add	v2[1],r3			;((Y*ScaleY)/Z) + OffsetY
       }
       {
	pop	v3				;Restore v3
	mul	v1[2],v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Height*ScaleY)/Z
	sat	#9,v4[0]			;Fix Alpha
       }
       {
	bra	ne,`dodpq
	pop	v4				;Restore v4
	or	v4[0],v4[3],v2[1]		;GRBa value
       }
	sub	r0,r0				;Clear r0
       {
	st_s	v2[1],(v1[3])			;Store GRBa value
	sub	v2[2],>>#1,r2			;Transformed X - Width/2
	subm	v2[3],r3			;Transformed Y - Height
       }
       ;----------------------------------------;bra eq,`nodpq
	bset	#6,r0				;Set DPQ not needed
`dodpq:
       {
	mul	#1,v2[2],>>#-16,v2[2]		;Shift width
	st_s	r2,(r1)				;Set ScrRECT.x
	add	#4,r1				;Increase Ptr
       }
       {
	rts					;Done
	st_s	r3,(r1)				;Set ScrRECT.y
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v2[0],(r1)			;Set ScrRECT.z
	add	#4,r1				;Increase Ptr
	addm	v2[2],v2[3]			;ScrRECT.w | ScrRECT.h
       }
       {
	st_s	v2[3],(r1)			;Set ScrRECT WH
       }
       ;----------------------------------------;rts
`CannotRecip0:
       {
	rts
	sub	r0,r0				;Invalid Return Code
	pop	v3				;Restore v3
       }
	pop	v4				;Restore v4
	sub	#1,r0				;(Cannot Recip)
       ;----------------------------------------;rts


;* _mdRTPClipSBoard
	.export	_mdRTPClipSBoard
;* Input:
;* r0 mdSBoard* input
;* r1 mdScrRECT* output

_mdRTPClipSBoard:
	push	v3				;Backup v3
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
	add	#8,r1,r3			;Ptr Destination Z
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
	as	v1[2],v1[0],v1[2]		;IndexOffset
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
       {
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	nop					;Delay slot
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mv_s	v1[0],v2[0]			;Set Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	mul	v3[1],v2[1],>>#tmsft,v2[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
       {
	ld_s	(_MPT_TransformMatrix+4),v3[0]	;r01
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v2[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v2[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1] 	  	;result Fracbits
       }
       {
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	ld_s	(_MPT_OffY),v2[1]		;OffsetY
	mul	v2[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
       }
       {
	mul	v1[0],r2,>>#sclsft+xyzsft-subres,r2	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),v1[1]		;OffsetX
       }
       {
	mul	v1[2],r3,>>#sclsft+xyzsft-subres,r3	;(Y*ScaleY)/Z
	ld_s	(r0),v2[2]			;Read Width as 16.16
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[3]			;Read Height as 16.16
	add	v1[1],r2			;((X*ScaleX)/Z) + OffsetX
       }
       {
	mul	v1[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(Width*ScaleX)/Z
	add	v2[1],r3			;((Y*ScaleY)/Z) + OffsetY
       }
       {
	mul	v1[2],v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Height*ScaleY)/Z
	ld_v	(_MPT_NearZ),v3			;Read NearZ/FarZ
	sub	r0,r0				;Clear r0
       }
       {
	sub	v2[2],>>#1,r2			;TransformedX - Width/2 = LeftX
       }
       {
	mv_s	#4,v1[2]			;Constant 4
	addm	v1[1],v1[1]			;RightClipX
	add	v2[2],r2,v1[0]			;RightX
       }
       {
	st_s	r2,(r1) 			;Set ScrRECT.x
	addm	v2[1],v2[1]			;BottomClipY
	abs	v1[0]				;Check RightX > ClipLeftX
       }
       {
	addwc	r0,r0				;Insert LeftX Clip
	subm	r2,v1[1]			;RightClipX - LeftX
       }
       {
	addm	v1[2],r1			;Increase Ptr
	abs	v1[1]				;Check LeftX < RightClipX
       }
       {
	addwc	r0,r0				;Insert RightX Clip
	mv_s	r3,v1[1]			;v1[1] BottomY
	subm	v2[3],r3			;TopY - Height
       }
       {
	st_s	r3,(r1)				;Set ScrRECT.y
	addm	v1[2],r1			;Increase Ptr
	abs	v1[1]				;Check BottomY > ClipTopY
       }
       {
	addwc	r0,r0				;Insert TopY Clip
	subm	r3,v2[1]			;BottomClipY - TopY
       }
       {
	st_s	v2[0],(r1)			;Set ScrRECT.z
	addm	v1[2],r1			;Increase Ptr
	abs	v2[1]				;Check TopY < ClipBottomY
       }
       {
	addwc	r0,r0				;Insert BottomY Clip
	subm	v2[0],v3[1]			;FarZ - Z
       }
       {
	subm	v3[0],v2[0]			;Z - NearZ
	abs	v3[1]				;Check FarZ Clip
       }
	addwc	r0,r0				;Insert FarZ Clip
	or	v2[2],>>#-16,v2[3]              ;ScrRECT.w | ScrRECT.h
       {
	rts					;Done
	abs	v2[0]				;Check NearZ Clip
	pop	v3				;Restore v3
       }
	addwc	r0,r0				;Insert NearZ Clip
	st_s	v2[3],(r1)			;Set ScrRECT WH
       ;----------------------------------------;rts
`CannotRecip0:
       {
	rts
	sub	r0,r0				;Invalid Return Code
       }
	pop	v3				;Restore v3
	sub	#1,r0				;(Cannot Recip)
       ;----------------------------------------;rts


;* _mdRTPDpqClipSBoard
	.export	_mdRTPDpqClipSBoard
;* Input:
;* r0 mdSBoard* input
;* r1 mdScrRECT* output
;* r2 mdCOLOR* rgba

_mdRTPDpqClipSBoard:
	push	v4				;Backup v4
       {
	push	v3				;Backup v3
	copy	r2,v4[2]			;Ptr RGBa
       }
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
	add	#8,r1,r3			;Ptr Destination Z
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	ld_s	(_MPT_FogNZ),v4[1]		;Read FogNZ
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	ld_s	(_MPT_FogMulZ),v4[0]		;Read FogMul
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
	sub	v4[1],v1[0],v4[1] 		;Z - FogNearZ
       }
       {
	bra	pl,`alphanotzero
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	ld_s	(v4[2]),v4[3]			;Read GRBa
       ;----------------------------------------;bra pl,`alphanotzero
	sub	v4[1],v4[1]			;Clear Alpha
`alphanotzero:
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mv_s	v1[0],v2[0]			;Set Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	mul	v3[1],v2[1],>>#tmsft,v2[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
       {
	ld_s	(_MPT_TransformMatrix+4),v3[0]	;r01
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v2[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v2[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1]	   	;result Fracbits
       }
       {
	mul	v1[0],v4[1],>>v1[1],v4[1]	;(Z - NearZ) / Z
	and	#0xFFFFFF00,v4[3]		;Isolate GRB
       }
       {
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	ld_s	(_MPT_OffY),v2[1]		;OffsetY
	mul	v2[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
       }
       {
	mul	v1[0],r2,>>#sclsft+xyzsft-subres,r2	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),v1[1]		;OffsetX
       }
       {
	mul	v1[2],r3,>>#sclsft+xyzsft-subres,r3	;(Y*ScaleY)/Z
	ld_s	(r0),v2[2]			;Read Width as 16.16
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[3]			;Read Height as 16.16
	add	v1[1],r2			;((X*ScaleX)/Z) + OffsetX
	mul	v4[1],v4[0],>>#vecsft*2,v4[0]	;((Z-NearZ)/Z)*FogMul
       }
       {
	mul	v1[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(Width*ScaleX)/Z
	add	v2[1],r3			;((Y*ScaleY)/Z) + OffsetY
       }
       {
	mul	v1[2],v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Height*ScaleY)/Z
	ld_v	(_MPT_NearZ),v3			;Read NearZ/FarZ
	sat	#9,v4[0]			;Fix Alpha
       }
       {
	bra	ne,`dodpq
	or	v4[0],v4[3]			;GRBa value
       }
       {
	mv_s	#4,v1[2]			;Constant 4
	addm	v1[1],v1[1]			;RightClipX
	add	v2[2],r2,v1[0]			;RightX
       }
       {
	st_s	v4[3],(v4[2])			;Store GRBa value
	sub	v2[2],>>#1,r2			;Transformed X - Width/2
	subm	r0,r0				;Clear r0
       }
       ;----------------------------------------;bra ne,`nodpq
	bset	#0,r0				;Set DPQ not needed
`dodpq:
       {
	st_s	r2,(r1) 			;Set ScrRECT.x
	addm	v2[1],v2[1]			;BottomClipY
	abs	v1[0]				;Check RightX > ClipLeftX
       }
       {
	addwc	r0,r0				;Insert LeftX Clip
	subm	r2,v1[1]			;RightClipX - LeftX
       }
       {
	addm	v1[2],r1			;Increase Ptr
	abs	v1[1]				;Check LeftX < RightClipX
       }
       {
	addwc	r0,r0				;Insert RightX Clip
	mv_s	r3,v1[1]			;v1[1] BottomY
	subm	v2[3],r3			;TopY - Height
       }
       {
	st_s	r3,(r1)				;Set ScrRECT.y
	addm	v1[2],r1			;Increase Ptr
	abs	v1[1]				;Check BottomY > ClipTopY
       }
       {
	addwc	r0,r0				;Insert TopY Clip
	subm	r3,v2[1]			;BottomClipY - TopY
       }
       {
	st_s	v2[0],(r1)			;Set ScrRECT.z
	addm	v1[2],r1			;Increase Ptr
	abs	v2[1]				;Check TopY < ClipBottomY
       }
       {
	addwc	r0,r0				;Insert BottomY Clip
	subm	v2[0],v3[1]			;FarZ - Z
       }
       {
	subm	v3[0],v2[0]			;Z - NearZ
	abs	v3[1]				;Check FarZ Clip
       }
	addwc	r0,r0				;Insert FarZ Clip
       {
	or	v2[2],>>#-16,v2[3]              ;ScrRECT.w | ScrRECT.h
	pop	v3				;Restore v3
       }
       {
	rts					;Done
	abs	v2[0]				;Check NearZ Clip
	pop	v4				;Restore v4
       }
	addwc	r0,r0				;Insert NearZ Clip
	st_s	v2[3],(r1)			;Set ScrRECT WH
       ;----------------------------------------;rts
`CannotRecip0:
       {
	rts
	sub	r0,r0				;Invalid Return Code
	pop	v3				;Restore v3
       }
	pop	v4				;Restore v4
	sub	#1,r0				;(Cannot Recip)
       ;----------------------------------------;rts


;* _mdRTPTBoard
;* _mdRTPQBoard
	.export	_mdRTPTBoard
	.export	_mdRTPQBoard
;* Input:
;* r0 mdSBoard* input
;* r1 mdScrV3* output
_mdRTPTBoard:
       {
	mv_s	#3,v2[3]			;3 Offset Points
	bra	RTPBoardCore
       }
	push	v3				;Backup v3
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       ;----------------------------------------;bra `RTPCore
	nop
_mdRTPQBoard:
	mv_s	#4,v2[3]			;4 Offset Points
	push	v3				;Backup v3
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
RTPBoardCore:
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
	as	v1[2],v1[0],v1[2]		;IndexOffset
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
       {
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	nop					;Delay slot
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mv_s	v1[0],v2[0]			;Set Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	mul	v3[1],v2[1],>>#tmsft,v2[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
       {
	ld_s	(_MPT_TransformMatrix+4),v3[0]	;r01
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v2[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v1[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1] 	  	;result Fracbits
       }
       {
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	ld_s	(_MPT_OffY),v2[1]		;OffsetY
	mul	v1[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
       }
       {
	mul	v1[0],r2,>>#sclsft+xyzsft-subres,r2	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),v1[1]		;OffsetX
       }
       {
	sub	v3[0],#0,v1[3]			;Set Xy
	mul	v1[2],r3,>>#sclsft+xyzsft-subres,r3	;(Y*ScaleY)/Z
       }
       {
	mv_s	v3[1],v1[1]			;Set Xx
	add	v1[1],r2			;((X*ScaleX)/Z) + OffsetX
       }
       {
	mul	v1[2],v1[3],>>#sclsft+tmsft-xyzsft,v1[3] ;(Xy*ScaleY)/Z
	add	v2[1],r3			;((Y*ScaleY)/Z) + OffsetY
       }
	mul	v1[0],v1[1],>>#sclsft+tmsft-xyzsft,v1[1]	;(Xx*ScaleX)/Z
	mul	v3[0],v1[0],>>#sclsft+tmsft-xyzsft,v1[0]	;(Yx*ScaleX)/Z
	mul	v3[1],v1[2],>>#sclsft+tmsft-xyzsft,v1[2]	;(Yy*ScaleY)/Z

`BoardLp:
       {
	ld_s	(r0),v3[0]			;Read OffSet X as 16.16
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v3[1]			;Read Offset Y as 16.16
	add	#4,r0				;Increase Ptr
       }
       {
	copy	v3[0],v3[2]			;Offset X
	mul	v1[1],v3[0],>>#xyzsft+xyzsft-subres,v3[0]	;OffsetX * Xx
       }
       {
	copy	v3[1],v3[3]			;Offset Y
	mul	v1[0],v3[1],>>#xyzsft+xyzsft-subres,v3[1]	;OffsetY * Yx
       }
       {
	add	r2,v3[0]
	mul	v1[3],v3[2],>>#xyzsft+xyzsft-subres,v3[2]	;OffsetX * Xy
       }
       {
	add	v3[0],v3[1]
	mul	v1[2],v3[3],>>#xyzsft+xyzsft-subres,v3[3]	;OffsetY * Yy
       }
	add	r3,v3[2]			;Final X
       {
	addm	v3[2],v3[3]			;Final Y
	sub	#1,v2[3]			;Decrease Counter
       }
       {
	bra	ne,`BoardLp
	st_s	v3[1],(r1)			;Store ScrX
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v3[3],(r1)			;Store ScrY
	add	#4,r1				;Increase Ptr
       }
       {
	rts					;Done
	st_s	v2[0],(r1)			;Store ScrZ
	add	#4,r1				;Increase Ptr
       }
       ;----------------------------------------;bra ne,`BoardLp
	pop	v3				;Restore v3
	sub	r0,r0				;Clear r0
       ;----------------------------------------;rts
`CannotRecip0:
       {
	rts
	sub	r0,r0				;Clear Return Code
       }
	pop	v3				;Restore v3
	sub	#1,r0				;Set CannotRecip
       ;----------------------------------------;rts


;* _mdRTPDpqTBoard
;* _mdRTPDpqQBoard
	.export	_mdRTPDpqTBoard
	.export	_mdRTPDpqQBoard
;* Input:
;* r0 mdSBoard* input
;* r1 mdScrV3* output
_mdRTPDpqTBoard:
       {
	mv_s	#3,v2[3]			;3 Offset Points
	bra	RTPDpqBoardCore
       }
	push	v4				;Backup v4
	push	v3				;Backup v3
       ;----------------------------------------;bra `RTPCore
_mdRTPDpqQBoard:
	mv_s	#4,v2[3]			;4 Offset Points
	push	v4				;Backup v4
	push	v3				;Backup v3
RTPDpqBoardCore:
       {
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
	copy	r2,v4[2]			;Ptr RGBa
       }
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	ld_s	(_MPT_FogNZ),v4[1]		;Read FogNZ
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	ld_s	(_MPT_FogMulZ),v4[0]		;Read FogMul
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
	sub	v4[1],v1[0],v4[1]		;Z - FogNearZ
       }
       {
	bra	pl,`alphanotzero		;
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	nop					;Delay slot
       ;----------------------------------------;bra pl,`alphanotzero
	sub	v4[1],v4[1]			;Clear Alpha
`alphanotzero:
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mv_s	v1[0],v2[0]			;Set Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	mul	v3[1],v2[1],>>#tmsft,v2[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
       {
	ld_s	(_MPT_TransformMatrix+4),v3[0]	;r01
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v2[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v1[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1]	   	;result Fracbits
       }
       {
	mul	v1[0],v4[1],>>v1[1],v4[1]	;(Z - FogNearZ) / Z
       }
       {
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	ld_s	(_MPT_OffY),v2[1]		;OffsetY
	mul	v1[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
       }
       {
	mul	v1[0],r2,>>#sclsft+xyzsft-subres,r2	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),v1[1]		;OffsetX
       }
       {
	sub	v3[0],#0,v1[3]			;Set Xy
	mul	v1[2],r3,>>#sclsft+xyzsft-subres,r3	;(Y*ScaleY)/Z
       }
       {
	mv_s	v3[1],v1[1]			;Set Xx
	add	v1[1],r2			;((X*ScaleX)/Z) + OffsetX
	mul	v4[1],v4[0],>>#vecsft*2,v4[0]	;((Z - NearZ)/Z)*FogMul
       }
       {
	mul	v1[2],v1[3],>>#sclsft+tmsft-xyzsft,v1[3] ;(Xy*ScaleY)/Z
	add	v2[1],r3			;((Y*ScaleY)/Z) + OffsetY
       }
       {
	mv_s	#4,v2[1]			;Cte 4
	mul	v1[0],v1[1],>>#sclsft+tmsft-xyzsft,v1[1]	;(Xx*ScaleX)/Z
       }
       {
	mul	v3[0],v1[0],>>#sclsft+tmsft-xyzsft,v1[0]	;(Yx*ScaleX)/Z
	sat	#9,v4[0]			;Saturate result
       }
	mul	v3[1],v1[2],>>#sclsft+tmsft-xyzsft,v1[2]	;(Yy*ScaleY)/Z

`BoardLp:
       {
	ld_s	(r0),v3[0]			;Read OffSet X as 16.16
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v3[1]			;Read Offset Y as 16.16
	add	#4,r0				;Increase Ptr
       }
       {
	copy	v3[0],v3[2]			;Offset X
	mul	v1[1],v3[0],>>#xyzsft+xyzsft-subres,v3[0]	;OffsetX * Xx
       }
       {
	copy	v3[1],v3[3]			;Offset Y
	mul	v1[0],v3[1],>>#xyzsft+xyzsft-subres,v3[1]	;OffsetY * Yx
       }
       {
	add	r2,v3[0]
	mul	v1[3],v3[2],>>#xyzsft+xyzsft-subres,v3[2]	;OffsetX * Xy
       }
       {
	add	v3[0],v3[1]
	mul	v1[2],v3[3],>>#xyzsft+xyzsft-subres,v3[3]	;OffsetY * Yy
       }
       {
	ld_s	(v4[2]),v2[2]			;Read GRB
	add	r3,v3[2]			;Final X
       }
       {
	addm	v3[2],v3[3]			;Final Y
       }
       {
	st_s	v3[1],(r1)			;Store ScrX
	addm	v2[1],r1 			;Increase Ptr
	sub	#1,v2[3]			;Decrease Counter
       }
       {
	bra	ne,`BoardLp
	st_s	v3[3],(r1)			;Store ScrY
	addm	v2[1],r1 			;Increase Ptr
	and	#0xFFFFFF00,v2[2]		;Isolate GRB
       }
       {
	st_s	v2[0],(r1)			;Store ScrZ
	addm	v2[1],r1 			;Increase Ptr
	or	v4[0],v2[2]			;Insert DPQval
       }
       {
	st_s	v2[2],(v4[2])			;Store GRBa
	addm	v2[1],v4[2]			;Increase Ptr
	cmp	#0,v4[0]			;Check DPQ value
       }
       ;----------------------------------------;bra ne,`BoardLp
       {
	rts	ne				;Done
	pop	v3				;Restore v3
       }
       {
	rts					;Done
	pop	v4				;Restore v4
       }
	sub	r0,r0				;Clear r0
       ;----------------------------------------;rts ne
	bset	#6,r0				;DPQ not used bit
       ;----------------------------------------;rts
`CannotRecip0:
       {
	rts
	sub	r0,r0				;Clear Return Code
	pop	v3				;Restore v3
       }
	pop	v4				;Restore v4
	sub	#1,r0				;Set CannotRecip
       ;----------------------------------------;rts


;* _mdRTPClipTBoard
;* _mdRTPClipQBoard
	.export	_mdRTPClipTBoard
	.export	_mdRTPClipQBoard
;* Input:
;* r0 mdSBoard* input
;* r1 mdScrV3* output
_mdRTPClipTBoard:
       {
	push	v3				;Backup v3
	bra	RTPClipBoardCore
	sub	r3,r3				;Clear r2
       }
       {
	ld_s	(rc0),v2[3]			;Backup rc0
	add	#3,r3				;Insert #of Vertices
       }
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       ;----------------------------------------;bra `RTPCore
	nop
_mdRTPClipQBoard:
       {
	push	v3				;Backup v3
	sub	r3,r3				;Clear r2
       }
       {
	ld_s	(rc0),v2[3]			;Backup rc0
	add	#4,r3				;Insert #of Vertices
       }
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
RTPClipBoardCore:

       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
	as	v1[2],v1[0],v1[2]		;IndexOffset
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
       {
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	nop					;Delay slot
       {
	push	v4				;Backup v4
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mv_s	v1[0],v2[0]			;Set Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	st_s	r3,(rc0)			;Set #of Vertices
	mul	v3[1],v2[1],>>#tmsft,v2[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
       {
	ld_s	(_MPT_TransformMatrix+4),v3[0]	;r01
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v2[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v1[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1]	   	;result Fracbits
       }
       {
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	ld_s	(_MPT_OffY),v4[3]		;OffsetY
	mul	v1[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
	sub	v4[0],v4[0]			;Clear Return code
       }
       {
	mul	v1[0],r2,>>#sclsft+xyzsft-subres,r2	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),v4[2]		;OffsetX
	copy	v3[1],v1[1]			;Set Xx
       }
       {
	ld_s	(_MPT_FarZ),v2[1]		;Read FarZ
	sub	v3[0],#0,v1[3]			;Set Xy
	mul	v1[2],r3,>>#sclsft+xyzsft-subres,r3	;(Y*ScaleY)/Z
       }
       {
	ld_s	(_MPT_NearZ),v2[2]		;Read NearZ
	add	v4[2],r2			;((X*ScaleX)/Z) + OffsetX
	mul	#1,v4[2],>>#-1,v4[2]		;RightClipX
       }
       {
	add	v4[3],r3			;((Y*ScaleY)/Z) + OffsetY
	mul	#1,v4[3],>>#-1,v4[3]		;BottomClipY
       }
       {
	mul	v1[2],v1[3],>>#sclsft+tmsft-xyzsft,v1[3] ;(Xy*ScaleY)/Z
	sub	v2[0],v2[1]			;FarZ - Z
       }
       {
	mul	v1[0],v1[1],>>#sclsft+tmsft-xyzsft,v1[1]	;(Xx*ScaleX)/Z
	abs	v2[1]				;Set FarZ ClipCode
       }
       {
	addwc	v4[0],v4[0]			;Insert FarZ Clip
	mul	v3[0],v1[0],>>#sclsft+tmsft-xyzsft,v1[0]	;(Yx*ScaleX)/Z
	mv_s	#4,v2[1]			;v2[1] Ct 4
       }
       {
	mul	v3[1],v1[2],>>#sclsft+tmsft-xyzsft,v1[2]	;(Yy*ScaleY)/Z
	sub	v2[2],v2[0],v3[1]		;Z - NearZ
	mv_s	#0xF,v2[2]			;And Code
       }
       {
	ld_s	(r0),v3[0]			;Read OffSet X as 16.16
	abs	v3[1]				;Set NearZ ClipCode
       }
       {
	addwc	v4[0],v4[0]			;Insert NearZ Clip
	addm	v2[1],r0			;Increase Ptr
       }
	ld_s	(r0),v3[1]			;Read OffSet Y as 16.16

`BoardLp:
       {
	copy	v3[0],v3[2]			;Offset X
	mul	v1[1],v3[0],>>#xyzsft+xyzsft-subres,v3[0]	;OffsetX * Xx
       }
       {
	copy	v3[1],v3[3]			;Offset Y
	mul	v1[0],v3[1],>>#xyzsft+xyzsft-subres,v3[1]	;OffsetY * Yx
       }
       {
	add	r2,v3[0]
	mul	v1[3],v3[2],>>#xyzsft+xyzsft-subres,v3[2]	;OffsetX * Xy
       }
       {
	add	v3[0],v3[1]                     ;Final X
	mul	v1[2],v3[3],>>#xyzsft+xyzsft-subres,v3[3]	;OffsetY * Yy
       }
       {
	mv_s	v3[1],v3[0]			;Clear Clipcode
	add	r3,v3[2]
       }
       {
	st_s	v3[1],(r1)			;Store ScrX
	subm	v3[1],v4[2],v3[1]		;RightClipX - ScrX
	abs	v3[0]				;Check Clip LeftX
       }
       {
	addm	v2[1],r1 			;Increase Ptr
	addwc	v3[0],v3[0]			;Set Clip RightX
       }
       {
	abs	v3[1]				;Check Clip Left X
	addm	v2[1],r0			;Increase Ptr
       }
       {
	addwc	v3[0],v3[0]			;Set Clip LeftX
	addm	v3[2],v3[3]			;Final Y
       }
       {
	st_s	v3[3],(r1)			;Store ScrY
	subm	v3[3],v4[3],v3[2]		;BottomClipY - ScrY
	abs	v3[3]				;Check Clip Top Y
       }
       {
	addwc	v3[0],v3[0],v3[3]		;Set Clip TopY
	addm	v2[1],r1 			;Increase Ptr
       }
       {
	st_s	v2[0],(r1)			;Store ScrZ
	addm	v2[1],r1 			;Increase Ptr
	dec	rc0
       }
       {
	bra	c0ne,`BoardLp
	ld_s	(r0),v3[0]			;Read OffSet X as 16.16
	addm	v2[1],r0			;Increase Ptr
	abs	v3[2]				;Check Clip Bottom Y
       }
       {
	ld_s	(r0),v3[1]			;Read OffSet Y as 16.16
	addwc	v3[3],v3[3]			;Set Clip BottomY
       }
	and	v3[3],v2[2]			;And Clipcode
       ;----------------------------------------;bra ne,`BoardLp
	st_s	v2[3],(rc0)			;Restore rc0
       {
	rts					;Done
	pop	v4				;Restore v4
	copy	v4[0],r0			;Return ClipCode
       }
	pop	v3				;Restore v3
	or	v2[2],>>#-2,r0			;Clipcode
       ;----------------------------------------;rts
`CannotRecip0:
       {
	rts
	sub	r0,r0				;Clear Return Code
       }
	pop	v3				;Restore v3
	sub	#1,r0				;Set CannotRecip
       ;----------------------------------------;rts


;* _mdRTPDpqClipTBoard
;* _mdRTPDpqClipQBoard
	.export	_mdRTPDpqClipTBoard
	.export	_mdRTPDpqClipQBoard
;* Input:
;* r0 mdSBoard* input
;* r1 mdScrV3* output
_mdRTPDpqClipTBoard:
       {
	ld_s	(rc0),v2[3]			;Backup rc0
	bra	RTPDpqClipBoardCore
	sub	r3,r3				;Clear r3
       }
       {
	push	v3				;Backup v3
	add	#3,r3				;r3 3
       }
	push	v4				;Backup v4
       ;----------------------------------------;bra `RTPCore
_mdRTPDpqClipQBoard:
       {
	ld_s	(rc0),v2[3]			;Backup rc0
	sub	r3,r3				;Clear r3
       }
       {
	push	v3				;Backup v3
	add	#4,r3				;r3 4
       }
	push	v4				;Backup v4
RTPDpqClipBoardCore:
	ld_v	(_MPT_TransformMatrix+0x20),v3	;Read r20 r21 r22 r23
       {
	ld_s	(r0),v2[0]			;Read X
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read Y
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r20*X
	ld_s	(r0),v2[2]			;Read Z
	add	#4,r0				;Increase Ptr
       }
       {
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r21*Y
	copy	r2,v4[2]			;Ptr GRBa
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r22*Z
	add	v3[3],v3[0],v1[0]		;Tz + r20*X
	ld_s	(_MPT_TransformMatrix+0),v3[0]	;Read r00
       }
       {
	add	v3[1],v1[0]			;Tz + r20*X + r21*Y
	ld_s	(_MPT_TransformMatrix+4),v3[1]	;Read r01
       }
       {
	add	v3[2],v1[0]			;Tz + r20*X + r21*Y + r22*Z
	ld_s	(_MPT_TransformMatrix+8),v3[2]	;Read r02
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r00*X
       }
       {
	msb	v1[0],v1[1]			;sigbits of z
	mul	v2[1],v3[1],>>#tmsft,v3[1]	;r01*Y
	ld_s	(_MPT_TransformMatrix+12),r2	;Read r03
       }
       {
	ld_s	(_MPT_FogNZ),v4[1]		;Read FogNZ
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r02*Z
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	ld_s	(_MPT_FogMulZ),v4[0]		;Read FogMul
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	addm	v3[0],v3[1]			;r00*X + r01*Y
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
       }
       ;----------------------------------------;bra le,`CannotRecip0
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
	sub	v4[1],v1[0],v4[1]		;Z - FogNearZ
       }
       {
	bra	pl,`alphanotzero		;
 	addm	v3[1],v3[2]			;r00*X + r01*Y + r02*Z
	copy	v1[0],v1[3]			;Z
       }
       {
	add	v3[2],r2			;Transformed X
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
	nop					;Delay slot
       ;----------------------------------------;bra pl,`alphanotzero
	sub	v4[1],v4[1]			;Clear Alpha
`alphanotzero:
       {
	push	v5				;Backup v5
	mul	v2[0],v3[0],>>#tmsft,v3[0]	;r10*X
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mv_s	v1[0],v2[0]			;Set Z
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	st_s	r3,(rc0)			;Set #of Vertices
	mul	v3[1],v2[1],>>#tmsft,v2[1]	;r11*Y
	add	v3[0],v3[3],r3			;Ty + r10*X
       }
       {
	ld_s	(_MPT_TransformMatrix+4),v3[0]	;r01
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	mul	v2[2],v3[2],>>#tmsft,v3[2]	;r12*Z
	add	v2[1],r3			;Ty + r10*X + r11*Y
       }
	sub	v1[0],#fix(2,iPrec),v1[0]	;refine
       {
	ld_s	(_MPT_ScaleX),v2[2]		;ScaleX
	mul	v1[2],v1[0],>>#iPrec,v1[0]	;result 1/Z
	add	v3[2],r3			;Ty + r10*X + r11*Y + r12*Z
       }
       {
	ld_s	(_MPT_ScaleY),v1[3]		;ScaleY
	add	#iPrec-xyzsft,v1[1]	   	;result Fracbits
       }
	mul	v1[0],v4[1],>>v1[1],v4[1]	;(Z - NearZ) / Z
       {
	copy	v1[0],v1[2]			;Backup 1/Z
	mul	v2[2],v1[0],>>v1[1],v1[0]	;ScaleX/Z as 12.20
       }
       {
	ld_s	(_MPT_OffY),v5[3]		;OffsetY
	mul	v1[3],v1[2],>>v1[1],v1[2]	;ScaleY/Z as 12.20
	sub	v5[0],v5[0]			;Clear Return code
       }
       {
	mul	v1[0],r2,>>#sclsft+xyzsft-subres,r2	;(X*ScaleX)/Z
	ld_s	(_MPT_OffX),v5[2]		;OffsetX
	copy	v3[1],v1[1]			;Set Xx
       }
       {
	ld_s	(_MPT_FarZ),v2[1]		;Read FarZ
	sub	v3[0],#0,v1[3]			;Set Xy
	mul	v1[2],r3,>>#sclsft+xyzsft-subres,r3	;(Y*ScaleY)/Z
       }
       {
	ld_s	(_MPT_NearZ),v2[2]		;Read NearZ
	add	v5[2],r2			;((X*ScaleX)/Z) + OffsetX
	mul	#1,v5[2],>>#-1,v5[2]		;RightClipX
       }
       {
	add	v5[3],r3			;((Y*ScaleY)/Z) + OffsetY
	mul	#1,v5[3],>>#-1,v5[3]		;BottomClipY
       }
       {
	mul	v1[2],v1[3],>>#sclsft+tmsft-xyzsft,v1[3] ;(Xy*ScaleY)/Z
	sub	v2[0],v2[1]			;FarZ - Z
       }
       {
	mul	v1[0],v1[1],>>#sclsft+tmsft-xyzsft,v1[1]	;(Xx*ScaleX)/Z
	abs	v2[1]				;Set FarZ ClipCode
       }
       {
	addwc	v5[0],v5[0]			;Insert FarZ Clip
	mul	v4[1],v4[0],>>#vecsft*2,v4[0]	;((Z - NearZ)/Z)*FogMul
	mv_s	#4,v2[1]			;v2[1] Ct 4
       }
       {
	mul	v3[0],v1[0],>>#sclsft+tmsft-xyzsft,v1[0]	;(Yx*ScaleX)/Z
	sub	v2[2],v2[0],v3[2]		;Z - NearZ
       }
       {
	mv_s	#0xF,v2[2]			;And Code
	sat	#9,v4[0]			;Fix Alpha
       }
       {
	bra	ne,`BoardLp
	ld_s	(r0),v3[0]			;Read OffSet X as 16.16
	abs	v3[2]				;Set NearZ ClipCode
       }
       {
	addwc	v5[0],v5[0]			;Insert NearZ Clip
	addm	v2[1],r0			;Increase Ptr
       }
       {
	mul	v3[1],v1[2],>>#sclsft+tmsft-xyzsft,v1[2]	;(Yy*ScaleY)/Z
	ld_s	(r0),v3[1]			;Read OffSet Y as 16.16
       }
       ;----------------------------------------;bra ne,`BoardLp
	bset	#6,v5[0]			;Set DPQ not used bit

`BoardLp:
       {
	copy	v3[0],v3[2]			;Offset X
	mul	v1[1],v3[0],>>#xyzsft+xyzsft-subres,v3[0]	;OffsetX * Xx
       }
       {
	ld_s	(v4[2]),v4[3]			;Fetch GRBa
	copy	v3[1],v3[3]			;Offset Y
	mul	v1[0],v3[1],>>#xyzsft+xyzsft-subres,v3[1]	;OffsetY * Yx
       }
       {
	add	r2,v3[0]
	mul	v1[3],v3[2],>>#xyzsft+xyzsft-subres,v3[2]	;OffsetX * Xy
       }
       {
	add	v3[0],v3[1]                     ;Final X
	mul	v1[2],v3[3],>>#xyzsft+xyzsft-subres,v3[3]	;OffsetY * Yy
       }
	and	#0xFFFFFF00,v4[3]		;Isolate GRBa
       {
	mv_s	v3[1],v3[0]			;Clear Clipcode
	add	r3,v3[2]
	addm	v4[0],v4[3]			;Insert DPQ value
       }
       {
	st_s	v3[1],(r1)			;Store ScrX
	subm	v3[1],v5[2],v3[1]		;RightClipX - ScrX
	abs	v3[0]				;Check Clip LeftX
       }
       {
	addm	v2[1],r1 			;Increase Ptr
	addwc	v3[0],v3[0]			;Set Clip RightX
       }
       {
	st_s	v4[3],(v4[2])			;Store GRBa
	abs	v3[1]				;Check Clip Left X
	addm	v2[1],r0			;Increase Ptr
       }
       {
	addwc	v3[0],v3[0]			;Set Clip LeftX
	addm	v3[2],v3[3]			;Final Y
       }
       {
	st_s	v3[3],(r1)			;Store ScrY
	subm	v3[3],v5[3],v3[2]		;BottomClipY - ScrY
	abs	v3[3]				;Check Clip Top Y
       }
       {
	addwc	v3[0],v3[0],v3[3]		;Set Clip TopY
	addm	v2[1],r1 			;Increase Ptr
       }
       {
	st_s	v2[0],(r1)			;Store ScrZ
	addm	v2[1],r1 			;Increase Ptr
	dec	rc0
       }
       {
	bra	c0ne,`BoardLp
	ld_s	(r0),v3[0]			;Read OffSet X as 16.16
	addm	v2[1],r0			;Increase Ptr
	abs	v3[2]				;Check Clip Bottom Y
       }
       {
	ld_s	(r0),v3[1]			;Read OffSet Y as 16.16
	addwc	v3[3],v3[3]			;Set Clip BottomY
	addm	v2[1],v4[2]			;Increase Ptr
       }
	and	v3[3],v2[2]			;And Clipcode
       ;----------------------------------------;bra ne,`BoardLp
	st_s	v2[3],(rc0)			;Restore rc0
       {
	pop	v5				;Restore v5
	copy	v5[0],r0			;Return ClipCode
       }
       {
	rts					;Done
	pop	v4				;Restore v4
       }
	pop	v3				;Restore v3
	or	v2[2],>>#-2,r0			;Clipcode
       ;----------------------------------------;rts
`CannotRecip0:
       {
	rts
	sub	r0,r0				;Clear Return Code
	pop	v4				;Restore v4
       }
	pop	v3				;Restore v3
	sub	#1,r0				;Set CannotRecip
       ;----------------------------------------;rts


;* _mdSetMatrixStack
	.export	_mdSetMatrixStack
;* Input:
;* r0 mdUINT32* msp

_mdSetMatrixStack:
       {
	rts					;Done
	add	#0xF,r0				;Align up
	mv_s	#_MPT_MatrixStack,r1		;ptr Matrix Stack
       }
	and	#-0x10,r0			;Vector Align
	st_s	r0,(r1)				;Store Ptr
       ;----------------------------------------;rts


;* _mdPushMatrix
	.export	_mdPushMatrix
;* Input:
;* None

_mdPushMatrix:
       {
	ld_v	(_MPT_TransformMatrix),v1	;Read row 0
	sub	r2,r2
       }
       {
	ld_v	(_MPT_TransformMatrix+0x10),v2	;Read row 1
	add	#_MPT_MatrixStack,r2		;Ptr Matrix Stack
       }
	ld_s	(r2),r0				;Fetch Matrix Stack Ptr
	nop					;avoid cache bug
       {
	st_v	v1,(r0)				;Store row 1
	add	#0x10,r0			;Increase Stack Ptr
       }
       {
	st_v	v2,(r0)				;Store row 2
	add	#0x10,r0			;Increase Stack Ptr
       }
       {
	rts					;Done
	ld_v	(_MPT_TransformMatrix+0x20),v1	;Read row 3
	add	#0x10,r0,r1			;End Ptr
       }
	st_s	r1,(r2)				;Store new Matrix Stack Ptr
       {
	st_v	v1,(r0)				;Store row 3
	sub	r0,r0				;Clear return value
       }
       ;----------------------------------------;rts


;* _mdPopMatrix
	.export	_mdPopMatrix
;* Input:
;* None

_mdPopMatrix:
	mv_s	#_MPT_MatrixStack,r3		;Ptr Matrix Stack
	ld_s	(r3),r1				;Fetch Matrix Stack Ptr
	sub	r0,r0				;Clear Return Value
	sub	#3*0x10,r1			;Decrement
       {
	ld_v	(r1),v1				;Read row 1
	add	#0x10,r1,r2			;Ptr row 2
       }
	ld_v	(r2),v2				;Read row 2
	add	#0x10,r2			;Ptr row 3
	st_v	v1,(_MPT_TransformMatrix)	;Store row 1
	st_v	v2,(_MPT_TransformMatrix+0x10)	;Store row 2
	ld_v	(r2),v1				;Read row 3
	rts					;Done
	st_s	r1,(r3)				;Store new Matrix Stack Ptr
	st_v	v1,(_MPT_TransformMatrix+0x20)	;Store row 3
       ;----------------------------------------;rts


;* _mdDotProduct
	.export	_mdDotProduct
	.export	_mdDotProductSFT
;* Input:
;* r0 mdVECTOR* input0
;* r1 mdVECTOR* input1
;* r2 mdINT32 Shift value
;* r3 mdINT32* dotp

_mdDotProduct:
       {
	copy	r2,r3				;Destination addr
	mv_s	#vecsft,r2			;Set shift value
       }
_mdDotProductSFT:
       {
	ld_s	(r0),v1[0]			;Read X0
	add	#4,r0				;Increase ptr
       }
	ld_s	(r0),v1[1]			;Read Y0
	add	#4,r0				;Increase ptr
       {
	ld_s	(r1),v2[0]			;Read X1
	add	#4,r1				;Increase ptr
       }
       {
	ld_s	(r1),v2[1]			;Read Y1
	add	#4,r1				;Increase ptr
       }
       {
	ld_s	(r1),v2[2]			;Read Z1
	mul	v2[0],v1[0],>>r2,v1[0] 		;X0*X1
       }
	nop					;Multiply Delay Slot
       {
	rts	mvs,nop				;Multiply Overflow
	mul	v2[1],v1[1],>>r2,v1[1]		;Y0*Y1
	ld_s	(r0),v1[2]			;Read Z0
       }
	nop
       {
	rts	mvs				;Multiply Overflow
	mul	v2[2],v1[2],>>r2,v1[2]		;Z0*Z1
	mv_s	#1,r0				;Set Overflow Return Code
	add	v1[1],v1[0]			;X0*X1 + Y0*Y1
       }
       ;----------------------------------------;rts mvs
	rts	vs				;Addition Overflow
       {
	rts	mvs				;Multiply Overflow
	add	v1[2],v1[0]			;X0*X1 + Y0*Y1 + Z0*Z1
       }
       ;----------------------------------------;rts mvs
	rts	vc				;Addition Ok
       ;----------------------------------------;rts vs
	rts					;Done (Addition Overflow)
       ;----------------------------------------;rts mvs
       {
	sub	r0,r0				;Clear Return code
	st_s	v1[0],(r3)			;Store Result
       }
       ;----------------------------------------;rts vc
	mv_s	#1,r0				;Set Addition Overflow
       ;----------------------------------------;rts


;* _mdCrossProduct
	.export	_mdCrossProduct
	.export	_mdCrossProductSFT
;* Input:
;* r0 mdV3* input0
;* r1 mdV3* input1
;* r2 mdINT32 shift value
;* r3 mdV3* output

_mdCrossProduct:
       {
	copy	r2,r3				;Destination addr
	mv_s	#vecsft,r2			;Set shift value
       }
_mdCrossProductSFT:
       {
	ld_s	(r0),v1[0]			;Read X0
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[1]			;Read Y0
	add	#4,r0				;Increase ptr
       }
	ld_s	(r0),v1[2]			;Read Z0
	copy	v1[0],v1[3]			;X0 Backup
       {
	ld_s	(r1),v2[0]			;Read X1
	add	#4,r1				;Increase ptr
       }
       {
	ld_s	(r1),v2[1]			;Read Y1
	add	#4,r1				;Increase ptr
       }
       {
	ld_s	(r1),v2[2]			;Read Z1
	copy	v2[0],v2[3]			;X1 Backup
	mul	v1[2],v2[0],>>r2,v2[0]		;v2[0] Z0*X1
       }
	nop
       {
	rts	mvs,nop				;Multiply Overflow
	mul	v2[1],v1[2],>>r2,v1[2]		;v1[2] Z0*Y1
       }
	mv_s	#1,r0				;Set Return value
       {
	rts	mvs,nop				;Multiply Overflow
	mul	v2[2],v1[3],>>r2,v1[3]		;v1[3] X0*Z1
       }
       ;----------------------------------------;rts mvs
	nop
       {
	rts	mvs,nop				;Multiply Overflow
	mul	v1[1],v2[2],>>r2,v2[2]		;v2[2] Y0*Z1
	sub	v1[3],v2[0]			;v2[0] Z0*X1 - X0*Z1
       }
       ;----------------------------------------;rts mvs
	rts	vs				;Sub Overflow
       {
	rts	mvs,nop				;Multiply Overflow
	mul	v2[1],v1[0],>>r2,v1[0]		;v1[0] X0*Y1
	sub	v1[2],v2[2]			;v2[2] Y0*Z1 - Z0*Y1
       }
       ;----------------------------------------;rts mvs
	rts	vs				;Sub Overflow
       ;----------------------------------------;rts vs
       {
	rts	mvs				;Multiply Overflow
	mul	v2[3],v1[1],>>r2,v1[1]		;v1[1] X1*Y0
       }
       ;----------------------------------------;rts mvs
       {
	st_s	v2[2],(r3)			;Store Cross X
	add	#4,r3				;Increase Ptr
       }
       ;----------------------------------------;rts vs
       {
	rts	mvs				;Multiply Overflow
	sub	v1[1],v1[0]			;v1[0] X0*Y1 - Y0*X1
       }
       ;----------------------------------------;rts mvs
       {
	rts	vc				;Sub Ok
	st_s	v2[0],(r3)			;Store Cross Y
	add	#4,r3				;Increase Ptr
       }
	rts					;Done
       ;----------------------------------------;rts mvs
       {
	st_s	v1[0],(r3)			;Store Cross Z
	sub	r0,r0				;Clear Return value
       }
       ;----------------------------------------;rts vc
	mv_s	#1,r0				;Set Return value
       ;----------------------------------------;rts


;* _mdVectorNormal
	.export	_mdVectorNormal
;* Input:
;* r0 mdV3* input
;* r1 mdV3* output

_mdVectorNormal:
       {
	ld_s	(r0),v1[0]			;Read X
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[1]			;Read Y
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[2]			;Read Z
	abs	v1[0]				;abs(X)
       }
       {
	abs	v1[1]                           ;abs(Y)
       }
	cmp	v1[0],v1[1]			;X >= Y
       {
	bra	le,`nomodif
	sub	#8,r0				;Ptr Vin
       }
	abs	v1[2]                           ;abs(Z)
       {
	mv_s	v1[0],r2			;max = X
	cmp	v1[0],v1[2]			;X >= Z
       }
       ;----------------------------------------;bra le,`nomodif
       {
	mv_s	v1[1],r2			;max = Y
	cmp	v1[1],v1[2]			;Y >= Z
       }
`nomodif:
	bra	le,`nomodif2
	msb	r2,r3				;msb(Max)
	addm	r3,r3				;msb(Max)*2
       ;----------------------------------------;bra le,`nomodif2
	msb	v1[2],r3 			;msb(Max)
	addm	r3,r3				;msb(Max)*2
`nomodif2:
	sub	#29,r3				;max msb(x*x+y*y+z*z)
	bra	ge,`nomodif3,nop		;shift value positive ?
       ;----------------------------------------;bra ge,`nomodif3,nop
	sub	r3,r3				;clear r3
`nomodif3:
	mul	v1[0],v1[0],>>r3,v1[0]		;x*x
	mul	v1[1],v1[1],>>r3,v1[1]		;y*y
       {
	mul	v1[2],v1[2],>>r3,v1[2]		;z*z
	sub	r3,#(vecsft*2),r3    		;#of fracbits
       }
	add	v1[1],v1[0]			;x*x+y*y
	add	v1[2],v1[0]                     ;x*x+y*y+z*z

       ;Calculate 1/Sqrt(x*x+y*y+z*z)
       {
	bra	eq,`finished,nop		;if ZERO, finished!
	msb	v1[0],v1[3]			;sigbits msb()
       }
       ;----------------------------------------;bra eq,`finished,nop
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
	ld_s	(r0),v1[1]			;X
	add	#4,r0
       }
	mul	v2[1],v1[0],>>#(29+1),v1[0]	;answer
       {
	ld_s	(r0),v1[2]			;Y
	add	#4,r0
       }
	sub	v1[0],v2[2],v1[0]		;answer
	mul	v2[1],v1[0],>>#(29),v1[0]	;answer
	ld_s	(r0),v1[3]			;Z
	mul	v1[0],v1[1],>>r2,v1[1]		;X / sqrt(X*X+Y*Y+Z*Z)
	mul	v1[0],v1[2],>>r2,v1[2]		;Y / sqrt(X*X+Y*Y+Z*Z)
`finished:
       {
	rts					;Done
	mul	v1[0],v1[3],>>r2,v1[3]		;Z / sqrt(X*X+Y*Y+Z*Z)
	st_s	v1[1],(r1)			;Store X
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[2],(r1)			;Store Y
	add	#4,r1				;Increase Ptr
       }
	st_s	v1[3],(r1)			;Store Z
       ;----------------------------------------;rts


;* _mdVectorNormalSFT
	.export	_mdVectorNormalSFT
;* Input:
;* r0 mdV3* input
;* r1 mdV3* output
;* r2 SHIFT value

_mdVectorNormalSFT:
       {
	ld_s	(r0),v1[0]			;Read X
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[1]			;Read Y
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[2]			;Read Z
	abs	v1[0]				;abs(X)
       }
       {
	abs	v1[1]                           ;abs(Y)
	addm	r2,r2,v1[3]			;VecShift*2
       }
	cmp	v1[0],v1[1]			;X >= Y
       {
	bra	le,`nomodif
	sub	#8,r0				;Ptr Vin
       }
	abs	v1[2]                           ;abs(Z)
       {
	mv_s	v1[0],r2			;max = X
	cmp	v1[0],v1[2]			;X >= Z
       }
       ;----------------------------------------;bra le,`nomodif
       {
	mv_s	v1[1],r2			;max = Y
	cmp	v1[1],v1[2]			;Y >= Z
       }
`nomodif:
	bra	le,`nomodif2
	msb	r2,r3				;msb(Max)
	addm	r3,r3				;msb(Max)*2
       ;----------------------------------------;bra le,`nomodif2
	msb	v1[2],r3 			;msb(Max)
	addm	r3,r3				;msb(Max)*2
`nomodif2:
	sub	#29,r3				;max msb(x*x+y*y+z*z)
	bra	ge,`nomodif3,nop		;shift value positive ?
       ;----------------------------------------;bra ge,`nomodif3,nop
	sub	r3,r3				;clear r3
`nomodif3:
	mul	v1[0],v1[0],>>r3,v1[0]		;x*x
	mul	v1[1],v1[1],>>r3,v1[1]		;y*y
       {
	mul	v1[2],v1[2],>>r3,v1[2]		;z*z
	sub	r3,v1[3],r3 	   		;#of fracbits
       }
	add	v1[1],v1[0]			;x*x+y*y
	add	v1[2],v1[0]                     ;x*x+y*y+z*z

       ;Calculate 1/Sqrt(x*x+y*y+z*z)
       {
	bra	eq,`finished,nop		;if ZERO, finished!
	msb	v1[0],v1[3]			;sigbits msb()
       }
       ;----------------------------------------;bra eq,`finished,nop
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
	ld_s	(r0),v1[1]			;X
	add	#4,r0
       }
	mul	v2[1],v1[0],>>#(29+1),v1[0]	;answer
       {
	ld_s	(r0),v1[2]			;Y
	add	#4,r0
       }
	sub	v1[0],v2[2],v1[0]		;answer
	mul	v2[1],v1[0],>>#(29),v1[0]	;answer
	ld_s	(r0),v1[3]			;Z
	mul	v1[0],v1[1],>>r2,v1[1]		;X / sqrt(X*X+Y*Y+Z*Z)
	mul	v1[0],v1[2],>>r2,v1[2]		;Y / sqrt(X*X+Y*Y+Z*Z)
`finished:
       {
	rts					;Done
	mul	v1[0],v1[3],>>r2,v1[3]		;Z / sqrt(X*X+Y*Y+Z*Z)
	st_s	v1[1],(r1)			;Store X
	add	#4,r1				;Increase Ptr
       }
       {
	st_s	v1[2],(r1)			;Store Y
	add	#4,r1				;Increase Ptr
       }
	st_s	v1[3],(r1)			;Store Z
       ;----------------------------------------;rts


;* _mdVectorMagnitude
	.export	_mdVectorMagnitude
;* Input:
;* r0 mdV3* input

_mdVectorMagnitude:
       {
	ld_s	(r0),v1[0]			;Read X
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[1]			;Read Y
	add	#4,r0				;Increase ptr
       }
       {
	ld_s	(r0),v1[2]			;Read Z
	abs	v1[0]				;abs(X)
       }
	abs	v1[1]                           ;abs(Y)
	cmp	v1[0],v1[1]			;X >= Y
	bra	le,`nomodif
	abs	v1[2]                           ;abs(Z)
       {
	mv_s	v1[0],r2			;max = X
	cmp	v1[0],v1[2]			;X >= Z
       }
       ;----------------------------------------;bra le,`nomodif
       {
	mv_s	v1[1],r2			;max = Y
	cmp	v1[1],v1[2]			;Y >= Z
       }
`nomodif:
	bra	le,`nomodif2
	msb	r2,r3				;msb(Max)
	addm	r3,r3				;msb(Max)*2
       ;----------------------------------------;bra le,`nomodif2
	msb	v1[2],r3 			;msb(Max)
	addm	r3,r3				;msb(Max)*2
`nomodif2:
	sub	#29,r3				;max msb(x*x+y*y+z*z)
	bra	ge,`nomodif3,nop		;shift value positive ?
       ;----------------------------------------;bra ge,`nomodif3,nop
	sub	r3,r3				;clear r3
`nomodif3:
	mul	v1[0],v1[0],>>r3,v1[0]		;x*x
	mul	v1[1],v1[1],>>r3,v1[1]		;y*y
       {
	mul	v1[2],v1[2],>>r3,v1[2]		;z*z
	sub	r3,#(vecsft*2),r3    		;#of fracbits
       }
	add	v1[1],v1[0]			;x*x+y*y
       {
	add	v1[2],v1[0]                     ;x*x+y*y+z*z
       }

       ;Calculate 1/Sqrt(x*x+y*y+z*z)
       {
	rts	eq				;quit if zero
	msb	v1[0],v1[3]			;sigbits msb()
       }
	sub	r3,v1[3]			;
       {
	mv_s	#0,r0  				;r0 ZERO
	add	#1,v1[3]			;shift1
       }
       ;----------------------------------------;rts eq
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
	copy	v1[0],r0			;r0 X*X+Y*Y+Z*Z
	mul	v2[1],v2[3],>>#(29+1),v2[3]	;temp
	mv_s	#fix(1.5,29),v2[2]		;threehalves
	sub	v2[3],v2[2],v2[3]		;temp
	mul	v2[3],v2[1],>>#(29),v2[1]	;y
	add	r3,r2
	mul	v2[1],v1[0],>>v2[0],v1[0]	;answer
	sub	#vecsft,r2
	mul	v2[1],v1[0],>>#(29+1),v1[0]	;answer
	nop
	sub	v1[0],v2[2],v1[0]		;answer
	mul	v2[1],v1[0],>>#(29),v1[0]	;answer
	rts					;Done
	mul	v1[0],r0,>>r2,r0		;r0 Sqrt(X*X+Y*Y+Z*Z)
	nop					;Delay Slot Mul
       ;----------------------------------------;rts


;* _mdApplyMatrix
	.export	_mdApplyMatrix

;* Input:
;* r0 mdMATRIX *input
;* r1 mdV3* input
;* r2 mdV3* output

_mdApplyMatrix:
	;PETER
       {
	ld_s	(acshift),v1[3]			;Read acshift
	and	#-0x10,csp,r3	 		;usp Vector align
       }
       {
	st_s	#tmsft,(acshift)		;Set new Acshift
	sub	#0x10,r3			;1 Vector Storage
       }
       {
	ld_s	(r1),v1[0]			;read X
	add	#4,r1				;Y
       }
       {
	ld_s	(r1),v1[1]			;read Y
	add	#4,r1				;Z
       }
	ld_s	(r1),v1[2]			;read Z
	nop
	st_v	v3,(r3)				;Backup v3
       {
	ld_s	(r0),v2[0]			;read A[0][0]
	add	#4,r0				;A[0][1]
       }
       {
	ld_s	(r0),v2[1]			;read A[0][1]
	add	#4,r0				;A[0][2]
       }
       {
	ld_s	(r0),v2[2]			;read A[0][2]
	add	#8,r0				;A[1][0]
	mul	v2[0],v1[0],>>acshift,v3[0]	;X*A[0][0]
       }
       {
	ld_s	(r0),v2[0]			;read A[1][0]
	sub	#4,r0				;A[0][3]
	mul	v2[1],v1[1],>>acshift,v3[1]	;Y*A[0][1]
       }
       {
	ld_s	(r0),v3[3]			;read A[0][3]
	add	#8,r0				;A[1][1]
	mul	v2[2],v1[2],>>acshift,v3[2]	;Z*A[0][2]
       }
       {
	ld_s	(r0),v2[1]			;read A[1][1]
	add	v3[0],v3[1]			;a[0][0]x+ay[0][1]
	mul	v2[0],v1[0],>>acshift,v3[0]	;X*A[1][0]
       }
	add	v3[1],v3[2]			;ax+ay+az [0]
       {
	addm	v3[2],v3[3]			;tx +ax+ay+az [0]
	add	#4,r0				;A[1][2]
       }
       {
	st_s    v3[3],(r2)	    		;store B[0]
	add	#4,r2				;B[1]
	mul	v2[1],v1[1],>>acshift,v3[1]	;Y*A[1][1]
       }
       {
	ld_s	(r0),v2[2]			;read A[1][2]
	add	#4,r0				;A[1][3]
       }
       {
	addm	v3[0],v3[1]			;ax+ay [1]
	ld_s	(r0),v3[3]			;read A[1][3]
	add	#4,r0				;A[2][0]
       }
       {
	ld_s	(r0),v2[0]			;read A[2][0]
	add	#4,r0				;A[2][1]
	mul     v2[2],v1[2],>>acshift,v3[2]	;Z*A[1][2]
       }
       {
	add	v3[1],v3[3]			;ty+ax+ay [1]
	ld_s	(r0),v2[1]			;read A[2][1]
       }
       {
	addm	v3[2],v3[3]			;ty+ax+ay+az [1]
	add	#4,r0				;A[2][2]
       }
       {
	st_s	v3[3],(r2)			;store B[1]
	add	#4,r2				;B[2]
	mul	v2[0],v1[0],>>acshift,v3[0]	;ax [2]
       }
       {
	ld_s	(r0),v2[2]			;read A[2][2]
	add	#4,r0				;A[2][3]
	mul	v2[1],v1[1],>>acshift,v3[1]	;ay [2]
       }
	ld_s	(r0),v3[3]			;read A[2][3]
       {
	mul	v2[2],v1[2],>>acshift,v3[2]	;az [2]
	add	v3[0],v3[1]			;ax+ay [2]
       }
	add	v3[1],v3[3]			;tz +ax+ay [2]
       {
	add	v3[2],v3[3]			;tz +ax+ay+az [2]
	st_s	v1[3],(acshift)			;Restore acshift
       }
       {
	st_s	v3[3],(r2)			;store B[2]
	rts					;Done
       }
	ld_v	(r3),v3				;Restore v3
	sub	r0,r0				;Clear return Value
       ;----------------------------------------;rts


;* _mdGetTransformMatrixTrans
	.export	_mdGetTransformMatrixTrans
	.export	_mdGetMatrixTrans

;* Input:
;* r0 mdMATRIX *input
;* r1 mdV3* output

_mdGetTransformMatrixTrans:
       {
	mv_s	#_MPT_TransformMatrix,r0
	copy	r0,r1				;Ptr Output
       }
_mdGetMatrixTrans:
	add	#3*4,r0				;Ptr Tx
       {
	ld_s	(r0),r2				;Read Tx
	add	#4*4,r0
       }
       {
	ld_s	(r0),r3				;Read Ty
	add	#4*4,r0
       }
       {
	ld_s	(r0),r4				;Read Tz
       }
	sub	r0,r0				;Clear return value
       {
	rts
	st_s	r2,(r1)				;Store Tx
	add	#4,r1				;Increase ptr
       }
       {
	st_s	r3,(r1)				;Store Ty
	add	#4,r1				;Increase ptr
       }
       {
	st_s	r4,(r1)				;Store Tz
       }
       ;----------------------------------------;rts


	.export _mdBreak
_mdBreak:
	breakpoint


       ;----------------------------------------;Recip Code
	.align	32
_Recip:
	.include	"recip.s"
       ;----------------------------------------;Recip Code End

	.data
	.include "M3DL/rsqrtlut.i"

