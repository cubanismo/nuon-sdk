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

; _LightI:

; per-vertex intensity lighting
; input per-vertex intensities, if any, are ignored
; input per-vertex normals have 16-bit components
; directional lights only
; GL_LOCAL_VIEWER disabled
;
; outputs 2.30 intensities at _MPENormalPointer, _MPENormalPointer + _MPENormalStride, ...
; TEMPORARY: the intensities are not actually 2.30; see temporary code below

; rc0	=	vertex counter (INPUT/OUTPUT)
; rc1	=	light counter

; v0[0]	=	saved vertex count
; v0[1]	=	normal pointer
; v0[2]	=	normal stride
; v0[3] =	unused

; v1[0]	=	light count
; v1[1]	=	light pointer
; v1[2] =	scratch for diffuse term
; v1[3] =	scratch for specular term

; v2[0]	=	normal x-component
; v2[1]	=	normal y-component
; v2[2]	=	normal z-component
; v2[3]	=	0

; v3[0]	=	light direction x-component
; v3[1]	=	light direction y-component
; v3[2]	=	light direction z-component
; v3[3]	=	scratch for diffuse term

; v4[0]	=	specular vector x-component
; v4[1]	=	specular vector y-component
; v4[2]	=	specular vector z-component
; v4[3]	=	scratch for specular term

; v5[0]	=	diffuse intensity
; v5[1]	=	unused
; v5[2]	=	unused
; v5[3] =	scratch for specular term

; v6[0]	=	specular intensity
; v6[1]	=	unused
; v6[2]	=	unused
; v6[3] =	scratch for specular term

; v7[0]	=	total intensity
; v7[1]	=	unused
; v7[2]	=	unused
; v7[3] =	unused

.align.sv
.module Light1
.export _LightI
.export _LightI_size
.import _MPELights
.import _MPENormalPointer
.import _MPENormalStride
.import _MPEConstantColor
.import _MPELightCount
.import _MPESpecularLUT
_LightI:
	ld_w		(_MPELightCount), v1[0]					; load light count
	ld_s		(rc0), v0[0]							; save vertex count
	ld_s		(_MPENormalPointer), v0[1]				; initialize normal pointer
	{
	ld_s		(_MPENormalStride), v0[2]				; initialize normal pointer increment
	lsr			#16, v1[0]								; shift light count into lower 16 bits
	}
`VertexLoop:
	{
	ld_sv		(v0[1]), v2								; load normal
	dec			rc0										; decrement vertex counter
	}
	ld_w		(_MPEConstantColor), v7[0]				; initialize total intensity
	{
	sub			v2[3], v2[3]							; zero normal w-component
	st_s		v1[0], (rc1)							; initialize light counter
	}
	mv_s		#_MPELights, v1[1]						; initialize light pointer
`LightLoop:
	{
	ld_sv		(v1[1]), v3								; load light direction
	add			#6, v1[1]								; increment light pointer
	}
	{
	ld_sv		(v1[1]), v4								; load light specular vector
	add			#6, v1[1]								; increment light pointer
	}
	{
	ld_w		(v1[1]), v5[0]							; load diffuse intensity
	add			#2, v1[1]								; increment light pointer
	dotp		v2, v3, >>#30, v3[3]					; compute diffuse dot product
	}
	{
	ld_w		(v1[1]), v6[0]							; load specular intensity
	add			#2, v1[1]								; increment light pointer
	dotp		v2, v4, >>#30, v4[3]					; compute specular dot product
	}
	asr			#31, v3[3], v1[2]						; compute mask for diffuse dot product
	asr			#31, v4[3], v1[3]						; compute mask for specular dot product
	not			v1[2]									; compute mask for diffuse dot product
	not			v1[3]									; compute mask for specular dot product
	and			v1[2], v3[3]							; clamp diffuse dot product
	and			v1[3], v4[3]							; clamp specular dot product
	sat			#31, v4[3]								; clamp specular dot product
	{
	mv_s		v4[3], v6[3]							; save specular dot product
	lsr			#(29-SPECULAR_LUT_BITS), v4[3]			; get byte offset into specular LUT; least significant bit
														;	will be ignored by ld_w
	}
	add			#_MPESpecularLUT, v4[3]					; get pointer into specular LUT
	{
	ld_w		(v4[3]), v5[3]							; get specular LUT entry
	add			#2, v4[3]
	}
	{
	ld_w		(v4[3]), v4[3]							; get specular LUT entry
	bits		#15, >>#(14-SPECULAR_LUT_BITS), v6[3]	; get 16.16 fraction for specular amplitude lerp
	}
	nop
	sub			v5[3], v4[3]							; work on specular amplitude lerp
	mul			v6[3], v4[3], >>#16, v4[3]				; work on specular amplitude lerp
	mul			v3[3], v5[0], >>#30, v5[0]				; multiply diffuse dot product by diffuse intensity
	add			v5[3], v4[3]							; specular amplitude lerp complete
	mul			v4[3], v6[0], >>#30, v6[0]				; multiply specular amplitude by specular intensity
	{
	add			v5[0], v7[0]							; add diffuse intensity to total intensity
	dec			rc1										; decrement light counter
	}
	{
	bra			c1ne, `LightLoop						; loop back for more lights
	sat			#31, v7[0]								; clamp total intensity
	}
	add			v6[0], v7[0]							; add specular intensity to total intensity
	sat			#31, v7[0]								; clamp total intensity


	; begin TEMPORARY code
	;
	; Some code further down the pipeline (probably a rasterizer) wants the intensity right-shifted by 8.
	; Further, intensities greater than about $38000000 seem to cause some flashing effects in amaze.
	; This needs to be fixed.
	;
	cmp			#$38000000, v7[0]
	bra			lt, `foo
	lsr			#8, v7[0]
	nop
	mv_s		#$380000, v7[0]
`foo:
	;
	;end TEMPORARY code


	bra			c0ne, `VertexLoop						; loop back for more vertices
	st_s		v7[0], (v0[1])							; store total intensity at location of normal
	add			v0[2], v0[1]							; increment normal pointer
	bra			_LightI_end								; branch to end
	st_s		v0[0], (rc0)							; restore vertex count
	nop
.align.sv
_LightI_end:

_LightI_size = _LightI_end - _LightI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; _LightGRB:

; per-vertex GRB lighting
; input per-vertex colors, if any, are ignored
; input per-vertex normals are in packed 32-bit format
; directional lights only
; GL_LOCAL_VIEWER disabled
;
; outputs eGRB888Alpha colors at _MPENormalPointer, _MPENormalPointer + _MPENormalStride, ...; alphas are garbage

; rc0	=	vertex counter (INPUT/OUTPUT)
; rc1	=	light counter

; v0[0]	=	saved vertex count
; v0[1]	=	normal pointer
; v0[2]	=	normal stride
; v0[3] =	saved linpixctl

; v1[0]	=	light count
; v1[1]	=	light pointer
; v1[2] =	scratch for diffuse term
; v1[3] =	scratch for specular term

; v2[0]	=	normal x-component
; v2[1]	=	normal y-component
; v2[2]	=	normal z-component
; v2[3]	=	0

; v3[0]	=	light direction x-component
; v3[1]	=	light direction y-component
; v3[2]	=	light direction z-component
; v3[3]	=	scratch for diffuse term

; v4[0]	=	specular vector x-component
; v4[1]	=	specular vector y-component
; v4[2]	=	specular vector z-component
; v4[3]	=	scratch for specular term

; v5[0]	=	diffuse G
; v5[1]	=	diffuse R
; v5[2]	=	diffuse B
; v5[3] =	scratch for specular term

; v6[0]	=	specular G
; v6[1]	=	specular R
; v6[2]	=	specular B
; v6[3] =	scratch for specular term

; v7[0]	=	total G
; v7[1]	=	total R
; v7[2]	=	total B
; v7[3] =	unused

.align.sv
.module Light2
.export _LightGRB
.export _LightGRB_size
.import _MPELights
.import _MPENormalPointer
.import _MPENormalStride
.import _MPEConstantColor
.import _MPELightCount
.import _MPESpecularLUT
_LightGRB:
	ld_w		(_MPELightCount), v1[0]					; load light count
	ld_s		(rc0), v0[0]							; save vertex count
	ld_s		(_MPENormalPointer), v0[1]				; initialize normal pointer
	{
	ld_s		(_MPENormalStride), v0[2]				; initialize normal pointer increment
	lsr			#16, v1[0]								; shift light count into lower 16 bits
	}
	add			#96, v0[1]
	ld_s		(linpixctl), v0[3]						; save linpixctl
`VertexLoop:
	{
	ld_s		(v0[1]), v2[0]							; load normal x-component
	dec			rc0										; decrement vertex counter
	}
	st_s		#$200000, (linpixctl)					; set linpixctl for 16-bit pixel load
	ld_p		(_MPEConstantColor), v7					; initialize total color
	asl			#11, v2[0], v2[1]						; extract normal y-component
	{
	asl			#11, v2[1], v2[2]						; extract normal z-component
	subm		v2[3], v2[3]							; zero normal w-component
	st_s		v1[0], (rc1)							; initialize light counter
	}
	mv_s		#_MPELights, v1[1]						; initialize light pointer
`LightLoop:
	{
	ld_sv		(v1[1]), v3								; load light direction
	add			#6, v1[1]								; increment light pointer
	}
	{
	ld_sv		(v1[1]), v4								; load light specular vector
	add			#6, v1[1]								; increment light pointer
	}
	{
	ld_p		(v1[1]), v5								; load diffuse color
	add			#2, v1[1]								; increment light pointer
	dotp		v2, v3, >>#30, v3[3]					; compute diffuse dot product
	}
	{
	ld_p		(v1[1]), v6								; load specular color
	add			#2, v1[1]								; increment light pointer
	dotp		v2, v4, >>#30, v4[3]					; compute specular dot product
	}
	asr			#31, v3[3], v1[2]						; compute mask for diffuse dot product
	asr			#31, v4[3], v1[3]						; compute mask for specular dot product
	not			v1[2]									; compute mask for diffuse dot product
	not			v1[3]									; compute mask for specular dot product
	and			v1[2], v3[3]							; clamp diffuse dot product
	and			v1[3], v4[3]							; clamp specular dot product
	sat			#31, v4[3]								; clamp specular dot product
	{
	mv_s		v4[3], v6[3]							; save specular dot product
	lsr			#(29-SPECULAR_LUT_BITS), v4[3]			; get byte offset into specular LUT; least significant bit
														;	will be ignored by ld_w
	}
	add			#_MPESpecularLUT, v4[3]					; get pointer into specular LUT
	{
	ld_w		(v4[3]), v5[3]							; get specular LUT entry
	add			#2, v4[3]
	}
	{
	ld_w		(v4[3]), v4[3]							; get specular LUT entry
	bits		#15, >>#(14-SPECULAR_LUT_BITS), v6[3]	; get 16.16 fraction for specular amplitude lerp
	}
	nop
	sub			v5[3], v4[3]							; work on specular amplitude lerp
	mul			v6[3], v4[3], >>#16, v4[3]				; work on specular amplitude lerp
	mul_p		v3[3], v5, >>#30, v5					; multiply diffuse dot product by diffuse color
	add			v5[3], v4[3]							; specular amplitude lerp complete
	mul_p		v4[3], v6, >>#30, v6					; multiply specular amplitude by specular color
	add_p		v5, v7									; add diffuse color to total color
	sat			#31, v7[0]								; clamp total G
	sat			#31, v7[1]								; clamp total R
	sat			#31, v7[2]								; clamp total B
	{
	add_p		v6, v7									; add specular color to total color
	dec			rc1										; decrement light counter
	}
	{
	bra			c1ne, `LightLoop						; loop back for more lights
	sat			#31, v7[0]								; clamp total G
	}
	sat			#31, v7[1]								; clamp total R
	sat			#31, v7[2]								; clamp total B
	{
	bra			c0ne, `VertexLoop						; loop back for more vertices
	st_s		#$400000, (linpixctl)					; set linpixctl for 32-bit pixel store
	}
	st_p		v7, (v0[1])								; store total color at location of normal
	add			v0[2], v0[1]							; increment normal pointer
	bra			_LightGRB_end							; branch to end
	st_s		v0[0], (rc0)							; restore vertex count
	st_s		v0[3], (linpixctl)						; restore linpixctl

.align.sv
_LightGRB_end:

_LightGRB_size = _LightGRB_end - _LightGRB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
