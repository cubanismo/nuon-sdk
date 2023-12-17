/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

#include "mpedefs.h"

.nocache
.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this overlay is installed on every rendering MPE

.overlay Manager
.origin MANAGER_OVERLAY_ORIGIN
.module Manager
.import _MPETextureCache
.import _MPETextureInfo

; _EventHandler is, of course, the event loop

_EventHandler::
	jsr		COMM_OVERLAY_ORIGIN, nop				; Do comm bus I/O; see "Comm modules" section below
	cmp		#MPE_TASK_RENDER, r5
	bra		ne, `next0, nop							; Task is not rendering; move on
	mv_s	#_MPETextureInfo, r4					; Task is rendering
	ld_s	(r4), r5								; See if texture registers are current
	st_s	#_MPETextureCache, (uvbase)
	{
	st_s	#_MPETextureCache, (xybase)
	cmp		#0, r5
	}
	bra		eq, VERTEX_LOADER_OVERLAY_ORIGIN, nop	; uvctl, xyxtl, clutbase are current; go render
	mv_s	#0, r6									; uvctl, xyxtl, clutbase are not current
	{
	st_s	r6, (r4)
	add		#4, r4
	}
	ld_s	(r4), r6
	{
	bra		VERTEX_LOADER_OVERLAY_ORIGIN			; Go render
	st_s	r5, (uvctl)
	}
	st_s	r6, (clutbase)
	st_s	r5, (xyctl)
`next0:
	; unknown task designator... shouldn't happen
	mv_s	#$deadbeef, r31
	halt


; _FloorDivMod performs Bresenham edge division

; Affects r0-r6
; Input parameters
;
        numer = r0
        denom = r1

; Results

	quot = r0
	rem = r1
	error = r2

; Working registers

	a = numer
	b = r2
	q = r3
	sig_n = r2
	sig_d = r3
	temp = r2
        
_FloorDivMod::

	// Insure numerator is positive
	{		
	mv_s	numer, r5
	abs		numer
	}

	// test first to see if numer < denom; if so, job is short
	{
	mv_s	denom, r6
	cmp     numer,denom             ; compute denom - numer
	}

	// compute the significant bits for numer and denom and compute their difference
	{
	bra     gt,`simple
    msb     numer,sig_n
	}
    msb     denom,sig_d
    sub     sig_d,sig_n,temp	; temp = 1 + sig_n - sig_d

	// set up the basic loop to run "temp" times
	{
	st_s   temp,(rc0)		; rc0 = loop count
    neg     temp			; temp = sig_d - sig_n
	}
	{
	mv_s    #0,q			; q = 0
    as		temp,denom,b	; b = denom<<count
	}

`loop:
	cmp	a,b			; compare b to a
	{
	bra	gt,`dont_sub,nop		; if b > a, don't subtract
	asl	#1,q			; q <<= 1 (done whether branch or not)
	}

	{
	subm	b,a,a			; a -= b
	or      #1,q
	}

`dont_sub:
	{
	dec     rc0
	bra     c0ne,`loop
	}
	asr     #1,b			; b >>= 1
    nop

; now finish up
	bra		`finish
	mv_s    a,rem
	mv_s    q,quot

`simple:
	; here we know numer < denom, so quot = 0 and rem = numer
	{
	mv_s    #0,quot
	copy    numer,rem
 	}

	; Account for correct negative behavior if needed
`finish:
	cmp		#00, r5			; Check for positive numerator
	{
	sub		r6, #1, r2		; Set error term to 1-height
;	mv_s	#-1, r2
	rts		ge				; RTS if so
	}
	cmp		#00, rem
	rts		eq
	neg		quot
	nop
	{
	rts		nop
	sub		#01, quot
	subm	rem, r6, rem
	}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Comm modules

; Module Comm is installed on a rendering MPE not running the minibios. It sends an MPE_TASK_COMPLETE comm bus packet
; to the controlling MPE, then waits to receive a comm bus packet from the controlling MPE. Note that the commctl
; register already contains the comm bus ID of the controlling MPE, and that the comminfo register already contains
; MPE_TASK_COMPLETE. The received comm bus packet will be returned in v0, and the received task designator will be
; returned in r5. No other registers are affected.

.overlay Comm
.origin COMM_OVERLAY_ORIGIN
.module Comm
.import _MPETaskCounterAddress
`SendLoop:
	ld_s	(commctl), r1
	ld_s	(_MPETaskCounterAddress), r0	; v0 is comm bus packet
	btst	#15, r1
	bra		ne, `SendLoop, nop
	st_v	v0, (commxmit)
`ReceiveLoop:
	ld_s	(commctl), r0
	ld_s	(comminfo), r5
	btst	#31, r0
	bra		eq, `ReceiveLoop, nop
	rts
	ld_v	(commrecv), v0
	bits	#7, >>#16, r5


; Module Comm0 is installed on a rendering MPE running the minibios. It sends an MPE_TASK_COMPLETE comm bus packet
; to the controlling MPE, then waits to receive a comm bus packet from the controlling MPE. Note that _MPEController
; contains the comm bus ID of the controlling MPE. The received comm bus packet will be returned in v0, and the
; received task designator will be returned in r5. No other registers are affected.

.overlay Comm0
.origin COMM_OVERLAY_ORIGIN
.import _MPEController
.import _MPETaskCounterAddress
	ld_s	intvec1, r6
	ld_s	(_MPETaskCounterAddress), r0	; v0 is comm bus packet
	{
	ld_s	(_MPEController), r4			; r4 is comm bus target
	sub		#16, r6
	}
	nop
	mv_s	#MPE_TASK_COMPLETE, r5			; r5 is comminfo
	{
	jsr		(r6), nop
	push	v7, rz
	}
	{
	pop		v7, rz
	add		#8, r6
	}
	jmp		(r6), nop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

