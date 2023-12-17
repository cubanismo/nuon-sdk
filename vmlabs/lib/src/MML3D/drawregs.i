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
; Register definitions for 3D drawing functions
;
; All of these registers are prefixed with _D_
; Vector registers are prefixed by _D_V
;

; v0 holds calculated pixel values
_D_Vpix		=	v0
_D_Vpixz	=	r3

; v1 is reserved for scratch registers
_D_Vtemp	=	v1
_D_temp0	=	r4
_D_temp1	=	r5
_D_linelen	=	r6		; length of current scan line
_D_maxdmalen	=	r7		; maximum DMA amount

; v2 is not needed while rendering a scanline
_D_Vmisc	=	v2
_D_topy		=	r8		; Y value of top pixel (16.16)
_D_boty		=	r9		; Y value of bottom pixel (16.16)
_D_trapfn	=	r10		; pointer to trapezoid function
_D_pixelfn 	=	r11		; pointer to per-pixel function

; nor is v3
; but note: v3 is used by the high level polygon stuff;
; it needs to be preserved across calls

; DMA registers (also scratch registers, sometimes)
_D_Vdma		=	v3
_D_dmaxlen	=	r12
_D_dmax		=	r13
_D_dmaylen	=	r14
_D_dmay		=	r15


; values interpolated across scanlines
_D_VX		=	v4
_D_lx		=	r16		; left X
_D_rx		=	r17		; right X
_D_u		=	r18		; left U (texture value, usually)
_D_v		=	r19		; left V (texture value, usually)

_D_VI		=	v5		; intensity values
_D_i0		=	r20		; shading value (e.g. diffuse intensity)
_D_i1		=	r21		; shading value (e.g. specular intensity)
_D_i2		=	r22		; shading value (e.g. some other shader value)
_D_z		=	r23		; Z (kept here because pixel color+Z are saved together in st_p)

; delta values across scanlines
; also: step values from scanline to scanline
; (these are never needed at the same time as the deltas, and so we can re-use
; the delta registers to hold them)
_D_VdX		=	v6
_D_dlx		=	r24		; delta left X (only useful for steps)
_D_drx		=	r25		; delta right X (only useful for steps)
_D_du		=	r26		; delta U	(i.e. dU/dX)
_D_dv		=	r27		; delta V	(i.e. dV/dX)

_D_VdI		=	v7
_D_di0		=	r28		; delta i0 (i.e. dI0/dX)
_D_di1		=	r29
_D_di2		=	r30
_D_dz		=	r31


