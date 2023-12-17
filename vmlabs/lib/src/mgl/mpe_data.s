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

; this overlay is installed on every rendering MPE

.overlay Data
.origin DATA_OVERLAY_ORIGIN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align 1024							; see mglNewTexture()

_MPETextureCache::
	.ds.s	MAX_TEX_MEM				; pixmap + clut

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align.s							; requirement for linear DMA

_MPETextureInfo::
	.dc.s	0						; uvctl, xyctl; cleared after uvctl, xyctl, and clutbase registers are updated
	.ds.s	1						; clutbase
_MPETextureParameter::
	.ds.b	1						; unused
	.ds.b	1						; unused
	.ds.b	1						; s shift
	.ds.b	1						; t shift

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; WARNING: BEWARE WHEN MOVING THIS BLOCK!

; DMA buffers are flipped by exclusive-or-ing an address with the immediate value DMA_CACHE_EOR. When moving this
; block, set DMA_CACHE_EOR = _MPEDMACache1 ^ _MPEDMACache2 in mpedefs.h. As a precaution, the C function mglInit()
; asserts that MPEDMACache1 ^ MPEDMACache2 == DMA_CACHE_EOR.

.align.v							; requirement for DMA command buffers
_MPEMDMACmdBuf::
	.ds.s	5						; MDMA command buffer

.align.v							; requirement for DMA command buffers
_MPEODMACmdBuf::
	.ds.s	4						; ODMA command buffer; one scalar larger than necessary to accomodate st_v

.align.v							; requirement for ld_v
_MPEDMACache1::						; DMA data
	.ds.s	64
	
.align.v							; requirement for ld_v
_MPEDMACache2::						; DMA data
	.ds.s	64

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align.s

_MPEFogParameter::
	.ds.s	2						; 22.10 end		   2.30 1 / (start - end)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align 8							; requirement for ld_sv

_MPELights::
	.ds.w	8*MAX_LIGHTS			; dir x, dir y, dir z		3 words
									; spec x, spec y, spec z	3 words
									; diff color, spec color	2 words
_MPENormalPointer::
	.ds.s	1
_MPENormalStride::
	.ds.s	1
_MPEConstantColor::
	.ds.w	1
_MPELightCount::
	.ds.w	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align.s							; requirement for linear DMA

_MPESpecularLUT::
	.ds.w	2*SPECULAR_LUT_SIZE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align.s							; requirement for linear DMA

_MPEDMAFlags::						; DMA flags for current SDRAM destination display pixmap
	.ds.s	1
_MPESDRAMPointer::					; Pointer to SDRAM destination display pixmap
	.ds.s	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align.v							; requirement for ld_v

_MPEMatrix::
	.ds.s	16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align.v							; requirement for ld_v

_MPEViewport::						; Viewport parameters
	.ds.s	2						; (zFar - zNear) / 2	(zNear + zFar) / 2		(2 scalars)
	.ds.s	2						; vWidth / 2	v0x		vHeight	/ 2		v0y 	(small vector)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is loaded as a unit

.align.s							; requirement for linear DMA

_MPEController::					; Comm bus ID of controlling MPE
	.ds.s	1
_MPETaskCounterAddress::			; Address in memory of controlling MPE of task counter for this MPE
	.ds.s	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.align.v							; requirement for ld_v
_MPEPolygonColorGradient::			; Polygon color gradient quantities
	.dc.s	0, 0, 0, 0
	.dc.s	0, 0, 0, 0	

									; c|YG|		  c|CR|		     c|BB| 		  c|Af|
_MPEPolygonScanlineColorValues::
	.dc.s	0, 0, 0, 0				; Trashed during viewport transform

_MPEPolygonPixelPointer::			; Output pixel pointer for subdivided scanlines
	.ds.s	1
_MPEPolygonDMASize::				; Size of the next bilinear DMA in long words
	.ds.s	1

.align.v							; requirement for ld_v
_MPEPolygonLeftEdge::				; Polygon current left edge data
	.ds.s	12

									; c|YG|		   c|CR|		  c|BB|		   c|Af|
									; c|YG|Step	   c|CR|Step	  c|BB|Step	   c|Af|step	
									;
									; or
									; dI/dX        dI/dY          I            Istep
									; dI/dX        dI/dY          Isave        empty
									; for white lighting data
_MPEPolygonLeftEdgeColor::
	.ds.s	8

.align.v							; requirement for ld_v
									; xStep        numerator      errorTerm    x
_MPEPolygonRightEdge::				; Polygon current right edge data
	.ds.s	4						; Trashed during vertex transform


.align.v							; requirement for ld_v
									; height	   denominator
_MPEPolygonEdgeExtra::				; Left and right edge extra parameters									
_MPEPolygonLeftEdgeExtra::			; Left edge extra parameters (alignment maintained)
	.ds.s	2						; Trashed during vertex transform	
									; height	   denominator	
_MPEPolygonRightEdgeExtra::			; Right edge extra parameters
	.ds.s	2						; Trashed during vertex transform


.align.v							; requirement for ld_v
_MPEVertexCache::					; Space for 8 8 long word vertices, each vector aligned
	.ds.s	64

.align.v							; requirement for ld_v
									; d(z/w)/dX d(s/w)/dX d(t/w)/dX d(1/w)/dX
									; d(z/w)/dY d(s/w)/dY d(t/w)/dY d(1/w)/dY
_MPEPolygonGradient::				; Polygon gradient quantities
	.ds.s	8						; Trashable during texture loads and viewport transform

.align.v							; requirement for ld_v
									; z/w          s/w            t/w          1/w
_MPEPolygonScanlineValues::			; Mid-scanline stuff
	.ds.s	4						; Trashed during viewport transform

.align.v							; requirement for ld_v
									; For each vertex
									; xs(x/w)      ys(y/w)           zs(z/w)          1/w
									; s            t                 c				  f
_MPEPolygonVertexList::				; Space for up to 8 8 longword clipped vertices
	.ds.s	64						; The previous 8 scalars get trashed during
									; perspective division/viewport transformation
									; in clip.s (SML 9/20/98)

_MPEPolygonNextLeftVertexPointer::	; Pointer to next left vertex
	.ds.s	1
_MPEPolygonNextRightVertexPointer::	; Pointer to next right vertex
	.ds.s	1
_MPEPolygonX::						; Polygon current X for DMA
	.ds.s	1
_MPEPolygonY::						; Polygon current Y for DMA/scanline advance
	.ds.s	1						; Touched during viewport transform (must be non-negative)
									

_MPEPolygonVertices::				; Number of vertices in current polygon
	.ds.s	1
_MPEPolygonScanlineRemainder::		; Polygon scanline pixel remainder
	.ds.s	1
_MPEPolygonDMASourcePointer::		; Source pointer for polygon DMAs
	.dc.s	_MPEDMACache1			; Flips between _MPEDMACache1 and _MPEDMACache2
	
_MPEVertexCacheVertices::			; Number of vertices in cache
	.ds.s	1
_MPEVertexCacheVertex::				; Pointer to first unrendered vertex
	.ds.s	1
_MPEPolygonVertex::					; Pointer to current polygon vertex
	.ds.s	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.align.s

_MPEScratch::						; scratch space
	.ds.s	2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is static

; 1/x 8 bit lookup table, see reciphi.s and reciplo.s in the
; math library to see how these values are used.  The only
; change here is the compression of 16 bit quantities down to
; 8 bits (SML 7/09/98)

_MPERecipLUT::
 .dc.b 0b11111111
 .dc.b 0b11111010
 .dc.b 0b11110110
 .dc.b 0b11110010
 .dc.b 0b11101111
 .dc.b 0b11101011
 .dc.b 0b11100111
 .dc.b 0b11100100
 .dc.b 0b11100000
 .dc.b 0b11011101
 .dc.b 0b11011001
 .dc.b 0b11010110
 .dc.b 0b11010010
 .dc.b 0b11001111
 .dc.b 0b11001100
 .dc.b 0b11001001
 .dc.b 0b11000110
 .dc.b 0b11000010
 .dc.b 0b10111111
 .dc.b 0b10111100
 .dc.b 0b10111001
 .dc.b 0b10110110
 .dc.b 0b10110011
 .dc.b 0b10110001
 .dc.b 0b10101110
 .dc.b 0b10101011
 .dc.b 0b10101000
 .dc.b 0b10100101
 .dc.b 0b10100011
 .dc.b 0b10100000
 .dc.b 0b10011101
 .dc.b 0b10011011
 .dc.b 0b10011000
 .dc.b 0b10010110
 .dc.b 0b10010011
 .dc.b 0b10010001
 .dc.b 0b10001110
 .dc.b 0b10001100
 .dc.b 0b10001010
 .dc.b 0b10000111
 .dc.b 0b10000101
 .dc.b 0b10000011
 .dc.b 0b10000000
 .dc.b 0b01111110
 .dc.b 0b01111100
 .dc.b 0b01111010
 .dc.b 0b01111000
 .dc.b 0b01110101
 .dc.b 0b01110011
 .dc.b 0b01110001
 .dc.b 0b01101111
 .dc.b 0b01101101
 .dc.b 0b01101011
 .dc.b 0b01101001
 .dc.b 0b01100111
 .dc.b 0b01100101
 .dc.b 0b01100011
 .dc.b 0b01100001
 .dc.b 0b01011111
 .dc.b 0b01011110
 .dc.b 0b01011100
 .dc.b 0b01011010
 .dc.b 0b01011000
 .dc.b 0b01010110
 .dc.b 0b01010100
 .dc.b 0b01010011
 .dc.b 0b01010001
 .dc.b 0b01001111
 .dc.b 0b01001110
 .dc.b 0b01001100
 .dc.b 0b01001010
 .dc.b 0b01001001
 .dc.b 0b01000111
 .dc.b 0b01000101
 .dc.b 0b01000100
 .dc.b 0b01000010
 .dc.b 0b01000000
 .dc.b 0b00111111
 .dc.b 0b00111101
 .dc.b 0b00111100
 .dc.b 0b00111010
 .dc.b 0b00111001
 .dc.b 0b00110111
 .dc.b 0b00110110
 .dc.b 0b00110100
 .dc.b 0b00110011
 .dc.b 0b00110010
 .dc.b 0b00110000
 .dc.b 0b00101111
 .dc.b 0b00101101
 .dc.b 0b00101100
 .dc.b 0b00101011
 .dc.b 0b00101001
 .dc.b 0b00101000
 .dc.b 0b00100111
 .dc.b 0b00100101
 .dc.b 0b00100100
 .dc.b 0b00100011
 .dc.b 0b00100001
 .dc.b 0b00100000
 .dc.b 0b00011111
 .dc.b 0b00011110
 .dc.b 0b00011100
 .dc.b 0b00011011
 .dc.b 0b00011010
 .dc.b 0b00011001
 .dc.b 0b00010111
 .dc.b 0b00010110
 .dc.b 0b00010101
 .dc.b 0b00010100
 .dc.b 0b00010011
 .dc.b 0b00010010
 .dc.b 0b00010000
 .dc.b 0b00001111
 .dc.b 0b00001110
 .dc.b 0b00001101
 .dc.b 0b00001100
 .dc.b 0b00001011
 .dc.b 0b00001010
 .dc.b 0b00001001
 .dc.b 0b00001000
 .dc.b 0b00000111
 .dc.b 0b00000110
 .dc.b 0b00000101
 .dc.b 0b00000100
 .dc.b 0b00000011
 .dc.b 0b00000010
 .dc.b 0b00000001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is static

; 1/dX reciprocal look-up, each entry is calculated as 65536 * 1/x,
; reporting only the bottom 16 bits to save space.  This gives us
; a range of 16-13 sigBits going from a dX of 2-16.  Expanding this
; table to a range of 1-32 will of course cost another sigbit (SML 8/18/98)

.align.w

_MPEPolygonScanlineRecipLUT::
	.dc.w	0						; 1
	.dc.w	65535					; 2
	.dc.w	43691					; 3
	.dc.w	32768					; 4
	.dc.w	26215					; 5
	.dc.w	21846					; 6
	.dc.w	18725					; 7
	.dc.w	16384					; 8
	.dc.w	14564					; 9
	.dc.w	13108					; 10
	.dc.w	11916					; 11
	.dc.w	10923					; 12
	.dc.w	10083					; 13
	.dc.w	9363					; 14
	.dc.w	8739					; 15
	.dc.w	8192					; 16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this block is static

.align 8							; requirement for ld_sv

_MPEGRBtoYCB::
	.dc.w	$2023, $105f, $063e, $0420
	.dc.w	$e889, $1c00, $fb77, $0020
	.dc.w	$ed77, $f68a, $1c00, $0020

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
