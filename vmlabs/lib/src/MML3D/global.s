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
	; 3D pipeline global data definitions
	;
	; this file should be linked after `param.s'

	; all of these are global variables
	.module

	.segment m3dram	
	.align.v

	
	; and one for a bilinear (pixel) DMA command; the
	; polygon draw initialization code may want to set
	; this up once
pixdmacmd:
	.ds.s	5

	; storage for C <-> pipeline interface
save_rz:
	.ds.s	1
save_r31:
	.ds.s	1	
save_sp:
	.ds.s	1
	
	.align.v
	.export INPBUFSIZ
	INPBUFSIZ = 112
	; input buffers for "loadpoly_func"
load_inpbuf1:
	.ds.s	INPBUFSIZ/4
load_inpbuf2:
	.ds.s	INPBUFSIZ/4

	; polygon buffer
	; each point is 8 long words
	; the polygon header occupies 1 vector (4 long words)
	; we provide room for 9 points; this is enough for a triangle clipped
	; against every one of 6 clipping planes, or a quadrilateral clipped
	; against 5 planes (no back plane provided)
	; so storage required is up to: 4 + 9*8 == 76 longs
	;

	PTSIZE = (8*4)

	.align.v
inp_polygon:
	.ds.s	76

	; pixel output buffer storage
	PIXBUF_LEN = 16
pix_linebuf1:
	.ds.s	PIXBUF_LEN
pix_linebuf2:
	.ds.s	PIXBUF_LEN


	;
	; local storage for the pixel functions
	;
loadpoly_data:
	.ds.s	16
xform_data:
	.ds.s	16
doclip_data:
	.ds.s	16
persp_data:
	.ds.s	16
polygon_data:
	.ds.s	32		; the polygon routine gets extra space -- 128 bytes, in fact
pixel_data:
	.ds.s	16
	
	; a buffer for a linear DMA command
	; also leaves room for a pixel mode command, too
dmacmd:
	.ds.s	5
	.ds.s	2		; currently unused

	; extra data storage + stack
	; functions can allocate from here by updating
	; `extra_data_ptr'
	
	; the stack goes here, too. As a rough rule of
	; thumb: allow for 2 levels of subroutine call, each
	; pushing all 32 registers == 64 long words of storage
	; for the stack

extra_data_ptr:
	.ds.s	1

	.align.v
extra_data:
	.ds.s	80+128		// WAS: 80
top_of_stack:

	; storage for texture data (2K + a 16 byte header)
TEXTURE:
	.ds.s	4 + 1024/4	// WAS: 4+2048/4


