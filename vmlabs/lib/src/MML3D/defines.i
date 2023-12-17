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

; GLOBAL DEFINES FOR POLYGON DRAW TEST
; NOTE: THIS FILE IS OBSOLETE; THE REAL VALUES
; USED WILL BE FILLED IN AT RUN TIME, SO ANYTHING
; YOU DO HERE WILL BE IGNORED!!!
;
;
;
; a flag to determine whether we're running on real hardware (1) or not (0)

real = 0

; flag for adding timing code (in before methods)
TIMING = 1

; where the textures and geometry data live
; this is old kruft, the actual values will be stuffed in
; at run time
MODEL_BASE      = 0
LIGHT_BASE	= 0

; where the screen is
SCREEN_BASE     =  0

; screen width and height
.if defined(EMULATOR)
SCREEN_WIDTH    =   352
SCREEN_HEIGHT   =   240
CLUSTER_BIT	=   0

.else
SCREEN_WIDTH    =   352
SCREEN_HEIGHT   =   240
CLUSTER_BIT	=   (1<<11)

.endif

;
; information on pixel data
;

MPE_PIXEL_TYPE = 5

.if !defined(DMA_XFER_TYPE)
.if defined(EMULATOR)
DMA_XFER_TYPE = 9
.else
DMA_XFER_TYPE = 5
.endif
.endif

; Z comparison mode for DMA
; inhibit if target > transfer
; i.e. write if new pixel > old pixel
; this means we should clear the Z buffer to 0, and
; actually write 1/Z into the buffer rather than Z itself
;
DMA_ZMODE       =   4


;;; variables that should work automatically (i.e. you shouldn't
;;; need to modify them

;;; PIXSIZE == pixel size in 16 bit words

.if (MPE_PIXEL_TYPE == 4)
        PIXSIZE = 2
        RSHIFT = 3
.else
  .if (MPE_PIXEL_TYPE == 5)
        PIXSIZE = 2
        RSHIFT = 4
  .else
    .if (MPE_PIXEL_TYPE == 6)
        PIXSIZE = 4
        RSHIFT = 3
    .else
        PIXSIZE = 1
        RSHIFT = 4
    .end
  .end
.end

.if defined(ALPHA)
    XSIZE_ADJUST    =   RSHIFT
.else
    XSIZE_ADJUST = 3
.endif

; how a write command gets built
DMA_FLAGS       =   (6<<13)|(DMA_XFER_TYPE<<4)|(DMA_ZMODE<<1)|CLUSTER_BIT

; line buffer length in pixels
; the longer the better, but alas we can only really fit 16 longs = 32 words here...
;
LBUFLEN	=	32/PIXSIZE

; texture buffer size in long words
TBUFLEN = (32*32)/2

;
; a useful macro to work around the .ds.s bug
;

.if defined(LLAMA_VERSION)
.macro storage count
.ds.s count
.mend
.else
.macro storage count
 _ii = @count
 .while _ii--
  .dc.s 0
 .end
.mend
.end

;
; and here we define which include file we want
; select only one!!
;
.if !defined(INCLUDE_BINARY)
INCLUDE_BINARY = 0
.endif


;
; define ONE of these to set the pixel rendering type
; if none are defined, then it defaults to "plain texture mapping"
;

; gouraud shaded pixels with specular highlights
PIXEL_GSPEC = 1

; bilinear pixels with gouraud shading
;PIXEL_BILERP = 1

INIT_X = 0
INIT_Y = 0
INIT_Z = 100
FOCAL = 1.0
cos_a = 1.0
sin_a = 0.0
cos_b = 1.0
sin_b = 1.0
cos_c = 1.0
sin_c = 1.0
