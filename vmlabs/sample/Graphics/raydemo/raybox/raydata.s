	;;
	;; data for ray trace application
	;;
	;; Copyright (c) 1997-2001 VM Labs, Inc.
	;; All rights reserved.
	;; Confidential and Proprietary Information of VM Labs, Inc.
	;; 
 	;; NOTICE: VM Labs permits you to use, modify, and distribute this file
 	;; in accordance with the terms of the VM Labs license agreement
 	;; accompanying it. If you have received this file from a source other
	;; than VM Labs, then your use, modification, or distribution of it
 	;; requires the prior written permission of VM Labs.

	;;
	;; texture mapping defines
	;;
	uv_width = 8
	u_tile = $d
	v_tile = u_tile
	
	TEXTURE_WIDTH = 128
	TEXTURE_HEIGHT = 128
	TEXTURE_WBITS = log2(TEXTURE_WIDTH)
	TEXTURE_HBITS = log2(TEXTURE_HEIGHT)

	CACHE_WIDTH = 8
	CACHE_HEIGHT = 4
		
	;; stack goes at top of local ram, so stack overflow
	;; gets noticed by the emulator

	.segment ray2d

_raydata_s:
	
	; the first part of the parameter block is designed
	; to look like Jeff's 2D stuff (although it probably
	; doesn't need to!)
	
	; destination bitmap description
dest_info:

dest_dma_flags:
	.dc.s	dmaFlags
dest_base_addr:
	.dc.s	dmaScreen	; destination screen base address
dest_clip_info:
	.dc.s	SCRNWIDTH	; X clip (min X in high word, max X in low word)
	.dc.s	SCRNHEIGHT	; Y clip (min Y in high word, max Y in low word)
	
	; rendering info
render_info:

cur_mpe:
	.dc.s	0	; which MPE this is
	.dc.s	0	; reserved (could be number of tris per MPE?)
total_mpes:
	.dc.s	TOTAL_MPES	; total rendering MPEs
	.dc.s	0	; reserved


	;;
	;; buffer for DMA commands
	;;
	.align.v
dmabuf:
	.dc.s	dmaFlags	; flags
	.dc.s	dmaScreen	; SDRAM memory address
dmaxptr:
	.dc.s	(4<<16)		; X pointer/length
dmayptr:
	.dc.s	(1<<16)		; Y pointer/length
	.dc.s	pixbuffer

	;;
	;; last ray direction
	;;
	.align.v
last_ray_direction:
	.ds.s	4

	;; some useful constants

	ANGLE_PREC = 16
	.align.v
ANGLE_VEC:
	.dc.s	fix((1<<XSHIFT)*SCRNWIDTH/2, ANGLE_PREC)	; X center
	.dc.s	fix(SCRNWIDTH*ASPECT_RATIO/2/(tan(AOV/114.5915590261)),ANGLE_PREC)
	.dc.s	fix((1<<YSHIFT)*SCRNHEIGHT/2,ANGLE_PREC)	; Y center
	.dc.s	0

INITIALIZE_1:
	.dc.s	pixbuffer	; initial value for xybase
	.dc.s	width | (bilinearMode << 20) | (1<<28)	 ; initial value for xyctl
	.dc.s	30		; initial value for acshift
	.dc.s	0		; unused
INITIALIZE_2:
	.dc.s	texturebuffer	; initial value for uvbase
	.dc.s	(u_tile<<16)|(v_tile<<12)|(uv_width)|(1<<28)|(2<<20) ; 16 bit pixels
	.dc.s	(CACHE_WIDTH<<16)|CACHE_HEIGHT		; initial value for uvrange
	.dc.s	0
texture_xinfo:
	.dc.s	fix(TEXTURE_WIDTH/(BOXSIZE*2),16)
	.dc.s	0
	.dc.s	0
	.dc.s	fix(TEXTURE_WIDTH/2,16)
texture_yinfo:
	.dc.s	0
	.dc.s	0
	.dc.s	fix(-TEXTURE_HEIGHT/(BOXSIZE*2),16)
	.dc.s	fix(TEXTURE_HEIGHT/2,16)

#if 0
cache_info:
	.dc.s	fix(1000,16)		; initial x offset
	.dc.s	fix(1000,16)		; initial y offset
	.dc.s	0
	.dc.s	0
cache_dma:
	.dc.s	(1<<13)|(3<<14)|((TEXTURE_WIDTH/8)<<16)|(2<<4)	; dma 16 bit pixels
	.dc.s	picture						; SDRAM address
cache_dma_xinfo:
	.dc.s	0						; xinfo
cache_dma_yinfo:
	.dc.s	0						; yinfo
	.dc.s	texturebuffer
#endif
	
	;
	; fixed constants used for perturbing normal
	; for water effect
	;
	.align.v
water_mask:
.if 0
        .dc.s   0x00ffffff
        .dc.s   0x007fffff
        .dc.s   0x001fffff
        .dc.s   0
.else
        .dc.s   0x00ffffff
        .dc.s   0x00ffffff
        .dc.s   0x003fffff
        .dc.s   0
.endif
	
        .align.v
water_pos:
	.dc.s	0x0
	.dc.s	0x0
	.dc.s	0x01020304
	.dc.s	0
water_vel:
	.dc.s	0x002f3456/SPEED
	.dc.s	0x002f4456/SPEED
	.dc.s	0x0031718f/SPEED
	.dc.s	0

	.include "rsqrtlut.i"
	.include "scene.s"

	;; here is a pixel buffer used to accumulate pixels
	;; to send to coldfire

	.align.v
pixbuffer:
	.ds.s	32
pixbuffer2:
	.ds.s	32
	
texturebuffer:
	.ds.s	64
	
	