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
	; 3D pipeline -- transformation routines
	; Version 1.0 for C
	;
	; local storage required:
	;	standard amount
	; stack required:
	;	8 long words


	;*
	;* 3D Geometry Functions for Merlin MPE ROM
	;*


	.module		xform
	.export		_xformlo_init, _xformlo_end

;************************************************************************
;*
;* Point transformation (low precision version)
;* Inputs:
;* r0 = pointer to output vertex in standard format
;*		i.e.:
;*		X,Y,Z,U		(16.16)
;*		Nx,Ny,Nz	(2.30)
;*		V			(16.16)
;*
;* r1 = pointer to input vertex (same format)
;* r2 = pointer to 4x3 transformation matrix
;*
;* Outputs:
;* area of memory pointed to by r0 is modified
;*
;* Notes: it is OK if r0 == r1
;*
;************************************************************************

;* parameters
_Tovp	=	r0		; output vertex pointer
_Tivp	=	r1		; input vertex pointer
_Tmp	=	r2		; matrix pointer

;* internal register usage:
_Tinp	=	v1		; input vertex
_Tinpw	=	_Tinp[3]	; last element of input vertex
	
_Tout	=	v2		; output vertex
_Toutx	=	_Tout[0]
_Touty	=	_Tout[1]
_Toutz	=	_Tout[2]
_Toutw	=	_Tout[3]
	
_Tmat	=	v3		; matrix row

	.align	CODEALIGN

_xformlo_init:
	rts
	mv_s	#xformlo - _xformlo_init,r1
	add	r1,r0
	
xformlo:
	push	_Tout
{	ld_v	(_Tivp),_Tinp
	add	#16,_Tivp		; skip to next part of input vertex
}
	push	_Tmat
{	ld_v	(_Tmp),_Tmat		; get first row of matrix
	add	#16,_Tmp		; move to next row of matrix
}
	copy	_Tinpw,_Toutw		; save last element of output vector
	mv_s	#(1<<30),_Tinpw		; set last element of input vector to 1 (in 2.30 format)


;* transform point

{	dotp	_Tmat,_Tinp,>>#30,_Toutx ; do product of first row
	ld_v	(_Tmp),_Tmat		; load second matrix row
}
	add	#16,_Tmp		; wait for ld_v to complete

{	dotp	_Tmat,_Tinp,>>#30,_Touty ; do products of second row
	ld_v	(_Tmp),_Tmat		; fetch third matrix row
}
	sub	#32,_Tmp		; go back to start of matrix, wait for ld_v
{	dotp	_Tmat,_Tinp,>>#30,_Toutz
	ld_v	(_Tmp),_Tmat		; re-load first matrix row
	add	#16,_Tmp
}
{	ld_v	(_Tivp),_Tinp		; fetch second part of input vertex, wait for dotp
}
{	st_v	_Tout,(_Tovp)		; save first part of output vertex
	add	#16,_Tovp
}
{	mv_s	#0,_Tinpw		; clear last part of input vertex
	copy	_Tinpw,_Toutw		; *after* saving it in the output vertex
}

;* transform normal

{	dotp	_Tmat,_Tinp,>>#30,_Toutx		; do product of first row
	ld_v	(_Tmp),_Tmat		; load second matrix row
}
	add	#16,_Tmp		; and let the load complete
{	dotp	_Tmat,_Tinp,>>#30,_Touty		; do products of second row
	ld_v	(_Tmp),_Tmat		; load third matrix row
}
	nop				; let the load complete
	dotp	_Tmat,_Tinp,>>#30,_Toutz	; do products of third row
	
	pop	_Tmat

{	st_v	_Tout,(_Tovp)		; save last part of output vertex
	rts
}
	pop	_Tout			; branch delay slot #1
	nop				; branch delay slot #2

_xformlo_end:
	