/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
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
	; 3D pipeline parameter block
	; TESTING VERSION -- parameters are fixed
	; to some predefined values!
	;
	; Version 1.0 for C
	;
	.include "defines.i"
	
	; all of these are global variables
	.module testparam_s

	; this file should be the first one containing data that
	; is linked
	
.if !defined(STANDALONE)
	.data
.endif
	.align.v

	.export _initparam
_initparam:

	; the first part of the parameter block is designed
	; to look like Jeff's stuff
	
	; destination bitmap description
dest_info:

dest_dma_flags:
	.dc.s	(DMA_FLAGS) | ((SCREEN_WIDTH>>3)<<16)	; DMA flags for destination screen
dest_base_addr:
	.dc.s	SCREEN_BASE	; destination screen base address
dest_clip_info:
.if 1
	.dc.s	SCREEN_WIDTH	; X clip (min X in high word, max X in low word)
	.dc.s	SCREEN_HEIGHT	; Y clip (min Y in high word, max Y in low word)
.else
	.dc.s	((0) << 16) | (SCREEN_WIDTH/2)
	.dc.s	((0) << 16) | (SCREEN_HEIGHT/2)
.endif
	
	; rendering info
render_info:

cur_mpe:
	.dc.s	0	; which MPE this is
	.dc.s	0	; reserved (could be number of tris per MPE?)
total_mpes:
	.dc.s	1	; total rendering MPEs
	.dc.s	0	; reserved
	

	;
	; 3D pipeline specific stuff
	;
	
	; current transformation matrix: 4x4
	; (must be vector aligned)
cur_matrix:
	.dc.s	fix(cos_b*cos_c,30)
	.dc.s	fix(-cos_b*sin_c,30)
	.dc.s	fix(-sin_b,30)
	.dc.s	fix(INIT_X,16)

	.dc.s	fix(cos_a*sin_c - sin_a*sin_b*cos_c,30)
	.dc.s	fix(cos_a*cos_c + sin_a*sin_b*sin_c,30)
	.dc.s	fix(-sin_a*cos_b,30)
	.dc.s	fix(INIT_Y,16)

	.dc.s	fix(sin_a*sin_c + cos_a*sin_b*cos_c,30)
	.dc.s	fix(sin_a*cos_c - cos_a*sin_b*sin_c,30)
	.dc.s	fix(cos_a*cos_b,30)
	.dc.s	fix(INIT_Z,16)

	.dc.s	0, 0, 0, 0

camera:
camera_focal_length:
	.dc.s	fix(FOCAL*SCREEN_WIDTH/2,16) ; focal length for camera (16.16 fixed point)
camera_back_clip:
	.dc.s	fix(1024,16)	; distance to back clipping plane (16.16 fixed point)
camera_center_x:
	.dc.s	fix(SCREEN_WIDTH/2,16)	; center of viewpoint (16.16 fixed point)
camera_center_y:
	.dc.s	fix(256/2,16)	; center of viewpoint (16.16 fixed point)

	; pointer to triangle data
model_data:
	.dc.s	0
reserved2:
	.dc.s	0		; reserved for future expansion
	
	;
	; pointers to pipeline pieces
	;
	.import _loadpoly_init, _xformlo_init, _calcclip_init, _doclip_init
	.import	_light_init, _persp_init
	.import	_drawpoly_init, _pixel_init

	.import _reciphi
pipeline_funcs:
	
loadpoly_func:
	.dc.s	_loadpoly_init	; function to load a polygon in standard form
xform_func:
	.dc.s	_xformlo_init	; function to transform a point
persp_func:
	.dc.s	_persp_init	; function to do perspective projection
calcclip_func:
	.dc.s	_calcclip_init	; function to calculate clipping coordinates
doclip_func:
	.dc.s	_doclip_init	; function to clip a polygon to the viewing frustum
light_func:
	.dc.s	_light_init	; lighting function
polygon_func:
	.dc.s	_drawpoly_init	; top level polygon drawing function
pixel_func:
	.dc.s	_pixel_init	; pixel generating function

	;; standard "assistance" functions
recip_func:
	.dc.s	_reciphi	; reciprocal function
reserved3:
	.dc.s	0		; reserved for future expansion

light_data:
	.dc.s	0,0,0,0
	.dc.s	0,0,0,0
	.dc.s	0,0,0,0
	.dc.s	0,0,0,0

clip_data:
	.dc.s	0,0,0,0
	.dc.s	0,0,0,0
	.dc.s	0,0,0,0
	.dc.s	0,0,0,0

RecipLUT:
	.include "reciplut.i"
	

	