/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

#include "mpedefs.h"

.cache
.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; int GetCommBusId(void)
; returns comm bus ID of current MPE

.align 32
_GetCommBusId::
	{
	rts
	ld_s	configa, r0
	}
	nop
	bits	#7, >>#8, r0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; comm bus receive interrupt

.align 32
_CommRecvInterrupt::
	cmp		#$3f, r0					; Check to see if packet came from an MPE
	{
	rts		gt, nop						; Return to BIOS if packet is not from an MPE
	cmp		#MPE_TASK_COMPLETE, r1		; Check for mGL packet
	}
	rts		ne, nop						; Return to BIOS if packet is not an mGL packet
	ld_s	(r4), r1					; Load address of task counter
	rts									; Return to BIOS
	{
	sub		#1, r1						; Decrement task counter
	mv_s	#-1, r0						; Signal packet reception to BIOS
	}
	st_s	r1, (r4)					; Store task counter

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; unsigned long tile(unsigned long length)
; returns tile register value

.align 32
_tile::
	{	
	rts
	mv_s	#15, r0						; Set tile value to max
	lsr		#2, r0, r1					; Divide tile width by 4
	}	
	msb		r1, r1						; Calculate bitcount of length
	sub		r1, r0						; Return tile value

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; unsigned long textureShift(unsigned long width)
; returns texture shift

.align 32
_textureShift::
	msb		r0, r0
	rts		eq
	rts
	nop
	sub		#1, r0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
