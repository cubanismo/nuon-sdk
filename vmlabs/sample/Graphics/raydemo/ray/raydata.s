/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/	
	;;
	;; data for ray trace application
	;;
	;;
	;; stack goes at top of local ram, so stack overflow
	;; gets noticed by the emulator

	.segment rayd

_raydata_s:
	
	; the first part of the parameter block is designed
	; to look like Jeff's 2D stuff (although it probably
	; doesn't need to!)
	
	; destination bitmap description
dest_info:

dest_dma_flags:
	.dc.s	0	        ; destination DMA flags: filled in later 
dest_base_addr:
	.dc.s	0		; destination screen base address: filled in later
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
	.dc.s	0		; flags
	.dc.s	0		; SDRAM memory address
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

INITIALIZE:
	.dc.s	StackTop	; initial value for sp
	.dc.s	pixbuffer	; initial value for xybase
.if RGB
	.dc.s	width | (bilinearMode << 20)	 ; initial value for xyctl
.else
	.dc.s	width | (bilinearMode << 20) | (1<<28)	 ; initial value for xyctl
.endif
	.dc.s	30		; initial value for acshift

	;
	; fixed constants used for perturbing normal
	; for water effect
	;
	.align.v
water_mask:
        .dc.s   0x00ffffff
        .dc.s   0x007fffff
        .dc.s   0x001fffff
        .dc.s   0

        .align.v
water_pos:
	.dc.s	0x0
	.dc.s	0x0
	.dc.s	0x01020304
	.dc.s	0
water_vel:
	.dc.s	0x001f3456/SPEED
	.dc.s	0x00113456/SPEED
	.dc.s	0
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
	
	.align.v
StackBot:
	.ds.s	0x100	;; 1K stack
StackTop:

_raydata_e:
